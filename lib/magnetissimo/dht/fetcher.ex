defmodule Magnetissimo.DHT.Fetcher do
  @moduledoc """
  Turns sampled infohashes into indexed torrents.

  `sampled/3` hands it a node's samples, of which it keeps eight at random:
  every hash from one node is fetched from that node in turn, so twenty
  would keep it busy long after it stopped answering, and the DHT has far
  more hashes than can be fetched. Hashes it saw in the last couple of
  hundred thousand are dropped at once; the rest are checked against the
  index in one query every half second, and those already indexed are
  dropped too. What is left waits in a bounded queue, newest first, which
  sheds the oldest when full: there are always more on the DHT.

  At most `fetches` jobs run at once, each its own task, and never two for
  the same node: its samples, fetched side by side, would be a burst of
  queries to one IP, which DHT nodes answer by going quiet. A job:

    1. asks the node that sampled the hash for its peers (`get_peers`), and
       if it has none, the closer nodes it names, one hop further;
    2. fetches the info dictionary from up to three peers at a time, and
       stops at the first that hands over metadata matching the hash
       (`Magnetissimo.DHT.Metadata`);
    3. reads it (`Magnetissimo.DHT.Info`), files or refuses it
       (`Magnetissimo.DHT.Classifier`), and hands it to
       `Magnetissimo.DHT.Indexer`;
    4. estimates its swarm with a scrape (BEP 33) of the nodes that answered,
       and hands that over too.

  The last hundred torrents fetched are scraped again every ten minutes, a
  few a minute, so the DHT page's numbers move while it is open. Each
  scrape is up to four packets inside the same budget, and no TCP.
  """

  use GenServer

  require Logger

  alias Magnetissimo.DHT
  alias Magnetissimo.DHT.Bloom
  alias Magnetissimo.DHT.Classifier
  alias Magnetissimo.DHT.Indexer
  alias Magnetissimo.DHT.Info
  alias Magnetissimo.DHT.Node
  alias Magnetissimo.DHT.Stats
  alias Magnetissimo.Torrents

  @check_every 500
  @rescrape_every 60_000
  @rescrape_after 10 * 60_000
  @recent 100
  @generation 200_000
  @max_queue 2_000
  @max_peers 12
  @per_sample 8
  @peers_at_once 3

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc """
  How many hashes wait to be fetched, counting those not yet checked
  against the index. `Magnetissimo.DHT.Sampler` stops sampling while this is
  high: hashes it found now would only push older ones off the queue.
  """
  @spec backlog(GenServer.server()) :: non_neg_integer()
  def backlog(server \\ __MODULE__), do: GenServer.call(server, :backlog)

  @doc "Infohashes `address` sampled."
  @spec sampled(GenServer.server(), term(), [binary()]) :: :ok
  def sampled(server \\ __MODULE__, address, hashes) do
    GenServer.cast(server, {:sampled, address, hashes})
  end

  @impl true
  def init(opts) do
    Process.send_after(self(), :check, @check_every)
    Process.send_after(self(), :rescrape, @rescrape_every)

    {:ok,
     %{
       max_running: Keyword.fetch!(opts, :fetches),
       deps: %{
         node: Keyword.get(opts, :node, Node),
         indexer: Keyword.get(opts, :indexer, Indexer),
         metadata: Keyword.get(opts, :metadata, config(:metadata, DHT.Metadata)),
         source_id: Torrents.get_source_by_name!("DHT").id
       },
       tasks: Keyword.get(opts, :task_supervisor, DHT.TaskSupervisor),
       seen: MapSet.new(),
       seen_before: MapSet.new(),
       pending: [],
       queue: [],
       running: %{},
       recent: %{}
     }}
  end

  @impl true
  def handle_call(:backlog, _from, state) do
    {:reply, length(state.queue) + length(state.pending), state}
  end

  @impl true
  def handle_cast({:sampled, address, hashes}, state) do
    {fresh, state} =
      hashes
      |> Enum.take_random(@per_sample)
      |> Enum.reduce({[], state}, fn hash, {fresh, state} ->
        if seen?(state, hash),
          do: {fresh, state},
          else: {[{hash, address} | fresh], see(state, hash)}
      end)

    {:noreply, %{state | pending: fresh ++ state.pending}}
  end

  @impl true
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @check_every)
    {:noreply, state |> check_pending() |> start_jobs()}
  end

  def handle_info(:rescrape, state) do
    Process.send_after(self(), :rescrape, @rescrape_every)
    {:noreply, rescrape(state)}
  end

  def handle_info({ref, result}, state) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    {:noreply, state |> finished(ref, result) |> start_jobs()}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    Logger.warning("[DHT] fetch crashed: #{inspect(reason)}")
    Stats.failure(:crashed)
    {:noreply, state |> finished(ref, {:error, :crashed}) |> start_jobs()}
  end

  # Two generations: a hash is remembered until the generation after the one
  # it went into fills up.
  defp seen?(state, hash),
    do: MapSet.member?(state.seen, hash) or MapSet.member?(state.seen_before, hash)

  defp see(%{seen: seen} = state, hash) do
    if MapSet.size(seen) >= @generation,
      do: %{state | seen: MapSet.new([hash]), seen_before: seen},
      else: %{state | seen: MapSet.put(seen, hash)}
  end

  defp check_pending(%{pending: []} = state), do: state

  defp check_pending(state) do
    known =
      state.pending
      |> Enum.map(fn {hash, _address} -> hex(hash) end)
      |> Torrents.known_hashes()

    fresh =
      Enum.reject(state.pending, fn {hash, _address} -> MapSet.member?(known, hex(hash)) end)

    Stats.count(:new_hashes, length(fresh))

    # Newest first: the node that just sampled a hash is the likeliest to
    # still be online and to know live peers for it. When the queue is full
    # the oldest hashes fall off the end.
    queue =
      fresh
      |> Enum.map(fn {hash, address} -> {:fetch, hash, address} end)
      |> Kernel.++(state.queue)
      |> Enum.take(@max_queue)

    Stats.put(:fetch_queue, length(queue))
    %{state | pending: [], queue: queue}
  end

  # One job per node at a time. A sample holds up to twenty hashes from one
  # node; fetched side by side they are twenty get_peers to one IP within a
  # second, past the five a second at which libtorrent nodes stop answering.
  defp start_jobs(state) do
    with true <- map_size(state.running) < state.max_running,
         {:ok, job, queue} <- next_job(state) do
      start_jobs(start(%{state | queue: queue}, job))
    else
      _ -> report(state)
    end
  end

  defp next_job(state) do
    busy = MapSet.new(state.running, fn {_ref, job} -> node_of(job) end)

    case Enum.split_while(state.queue, &MapSet.member?(busy, node_of(&1))) do
      {_busy, []} -> :none
      {skipped, [job | rest]} -> {:ok, job, skipped ++ rest}
    end
  end

  defp node_of({:fetch, _hash, address}), do: address
  defp node_of({:scrape, _hash, [address | _]}), do: address

  defp report(state) do
    Stats.put(:fetching, map_size(state.running))
    Stats.put(:fetch_queue, length(state.queue))
    state
  end

  defp start(state, job) do
    deps = state.deps
    task = Task.Supervisor.async_nolink(state.tasks, fn -> run(job, deps) end)
    %{state | running: Map.put(state.running, task.ref, job)}
  end

  defp finished(state, ref, result) do
    {job, running} = Map.pop(state.running, ref)
    state = %{state | running: running}

    case {job, result} do
      {{:fetch, hash, _address}, {:ok, nodes}} -> remember(state, hash, nodes)
      {{:scrape, hash, _nodes}, _result} -> touch(state, hash)
      _ -> state
    end
  end

  defp remember(state, hash, nodes) do
    recent = Map.put(state.recent, hash, %{nodes: nodes, scraped_at: now()})

    recent =
      if map_size(recent) > @recent,
        do:
          recent
          |> Enum.sort_by(fn {_hash, r} -> r.scraped_at end, :desc)
          |> Enum.take(@recent)
          |> Map.new(),
        else: recent

    %{state | recent: recent}
  end

  defp touch(state, hash) do
    case state.recent do
      %{^hash => recent} ->
        %{state | recent: %{state.recent | hash => %{recent | scraped_at: now()}}}

      _ ->
        state
    end
  end

  # A few a minute, whatever the queue holds: a rescrape is four packets and
  # no TCP, and the queue is never empty while the sampler keeps it topped up.
  defp rescrape(state) do
    cutoff = now() - @rescrape_after
    room = div(state.max_running, 4) + 1
    busy = MapSet.new(state.running, fn {_ref, job} -> node_of(job) end)

    state.recent
    |> Enum.filter(fn {_hash, recent} ->
      recent.scraped_at < cutoff and not MapSet.member?(busy, hd(recent.nodes))
    end)
    |> Enum.take(max(0, room))
    |> Enum.reduce(state, fn {hash, recent}, state ->
      state |> touch(hash) |> start({:scrape, hash, recent.nodes})
    end)
  end

  ## The jobs, each in its own task

  @doc """
  Runs one job in the calling process: `{:fetch, hash, address}` or
  `{:scrape, hash, nodes}`. `deps` names the node, the indexer, the metadata
  module and the DHT's source id.
  """
  def run({:fetch, hash, address}, deps) do
    Stats.count(:fetches)

    with {:ok, peers, nodes} <- find_peers(hash, address, deps),
         {:ok, metadata} <- race(hash, peers, deps),
         {:ok, info} <- read(metadata),
         {:ok, category_id} <- classify(info) do
      Stats.count(:fetched)
      Indexer.index(deps.indexer, attrs(hash, info, category_id, deps.source_id))
      scrape(hash, nodes, deps)
      {:ok, nodes}
    else
      {:error, reason} ->
        Stats.failure(reason)
        {:error, reason}
    end
  end

  def run({:scrape, hash, nodes}, deps) do
    scrape(hash, nodes, deps)
    :ok
  end

  defp find_peers(hash, address, deps) do
    case get_peers(deps, address, hash) do
      {:ok, %{values: [_ | _] = peers}} ->
        {:ok, Enum.take(Enum.uniq(peers), @max_peers), [address]}

      {:ok, %{nodes: [_ | _] = nodes}} ->
        closer(hash, Enum.take(nodes, 4), address, deps)

      {:ok, _results} ->
        {:error, :no_peers}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # One hop on: the nodes the sampling node named as closer to the hash.
  defp closer(hash, nodes, address, deps) do
    answers =
      nodes
      |> Task.async_stream(fn {_id, node} -> {node, get_peers(deps, node, hash)} end,
        max_concurrency: 4,
        timeout: :infinity
      )
      |> Enum.flat_map(fn
        {:ok, {node, {:ok, results}}} -> [{node, results.values}]
        _ -> []
      end)

    case answers |> Enum.flat_map(&elem(&1, 1)) |> Enum.uniq() do
      [] -> {:error, :no_peers}
      peers -> {:ok, Enum.take(peers, @max_peers), [address | Enum.map(answers, &elem(&1, 0))]}
    end
  end

  defp get_peers(deps, address, hash) do
    Node.query(address, "get_peers", %{"info_hash" => hash}, server: deps.node, priority: :high)
  end

  defp race(hash, peers, deps) do
    peers
    |> Task.async_stream(&deps.metadata.fetch(hash, &1),
      max_concurrency: @peers_at_once,
      ordered: false,
      timeout: 12_000,
      on_timeout: :kill_task
    )
    |> Enum.find_value({:error, :no_metadata}, fn
      {:ok, {:ok, metadata}} -> {:ok, metadata}
      _ -> nil
    end)
  end

  defp read(metadata) do
    case Info.parse(metadata) do
      {:ok, info} ->
        {:ok, info}

      {:error, reason} ->
        Stats.count(:refused)
        {:error, reason}
    end
  end

  defp classify(info) do
    case Classifier.classify(info) do
      {:ok, category_id} ->
        {:ok, category_id}

      :banned ->
        Stats.count(:banned)
        {:error, :banned}
    end
  end

  defp attrs(hash, info, category_id, source_id) do
    hex = hex(hash)
    magnet = "magnet:?xt=urn:btih:#{hex}&dn=#{URI.encode_www_form(info.name)}"

    %{
      name: info.name,
      # The DHT has no page for a torrent; the magnet is its address.
      canonical_url: magnet,
      published_at: DateTime.utc_now(),
      size_in_bytes: info.size,
      magnet_hash: hex,
      magnet_url: magnet,
      category_id: category_id,
      source_id: source_id,
      files: info.files,
      file_count: info.file_count
    }
  end

  defp scrape(hash, nodes, deps) do
    Stats.count(:scrapes)

    filters =
      nodes
      |> Enum.take(4)
      |> Task.async_stream(
        &Node.query(&1, "get_peers", %{"info_hash" => hash, "scrape" => 1},
          server: deps.node,
          priority: :high
        ),
        max_concurrency: 4,
        timeout: :infinity
      )
      |> Enum.flat_map(fn
        {:ok, {:ok, %{bfsd: seeds, bfpe: peers}}} when is_binary(seeds) and is_binary(peers) ->
          [{seeds, peers}]

        _ ->
          []
      end)

    if filters != [] do
      seeders = filters |> Enum.map(&elem(&1, 0)) |> Bloom.union() |> Bloom.estimate()
      leechers = filters |> Enum.map(&elem(&1, 1)) |> Bloom.union() |> Bloom.estimate()
      Indexer.swarm(deps.indexer, hex(hash), seeders, leechers)
    end
  end

  defp hex(hash), do: Base.encode16(hash, case: :lower)

  defp now, do: System.monotonic_time(:millisecond)

  defp config(key, default) do
    :magnetissimo |> Application.get_env(__MODULE__, []) |> Keyword.get(key, default)
  end
end
