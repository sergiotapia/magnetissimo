defmodule Magnetissimo.DHT.Sampler do
  @moduledoc """
  Walks the DHT and collects infohashes.

  It asks each node it knows for a sample of the infohashes that node stores
  (BEP 51 `sample_infohashes`, with a random target), then waits as long as
  the node asked before asking it again. Every answer also names other
  nodes, which join the frontier (`Magnetissimo.DHT.Table`), so the walk
  feeds itself. When no node is due it widens the frontier with `find_node`
  to a random known node; when it knows none, to the bootstrap routers.

  Samples go to `Magnetissimo.DHT.Fetcher`. Queries in flight are capped at
  two seconds' worth of the rate budget, and they all wait in
  `Magnetissimo.DHT.Node`'s low-priority queue, behind any torrent being
  fetched.

  Sampling pauses while the fetcher has a couple of hundred hashes waiting.
  One sample answer holds up to twenty hashes and a fetch takes seconds, so
  unchecked the sampler finds hashes far faster than they can be fetched,
  and every packet it spends on them is a router table entry for nothing.
  So the rate is a ceiling: the crawler only uses what the fetches need.

  The nodes that answered are saved every five minutes and on shutdown, so
  a restart resumes the walk instead of starting over at the routers.
  """

  use GenServer

  require Logger

  alias Magnetissimo.DHT
  alias Magnetissimo.DHT.Fetcher
  alias Magnetissimo.DHT.Node
  alias Magnetissimo.DHT.Stats
  alias Magnetissimo.DHT.Table

  @tick 50
  @save_every 5 * 60_000
  @saved_nodes 1_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc "How many nodes the frontier holds."
  @spec size(GenServer.server()) :: non_neg_integer()
  def size(server \\ __MODULE__), do: GenServer.call(server, :size)

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)
    rate = Keyword.fetch!(opts, :rate)

    state = %{
      table: Table.new(max(20_000, rate * 600)),
      in_flight: %{},
      max_in_flight: max(4, rate * 2),
      backlog_limit: Keyword.get(opts, :backlog_limit, 200),
      node: Keyword.get(opts, :node, Node),
      fetcher: Keyword.get(opts, :fetcher, Fetcher),
      tasks: Keyword.get(opts, :task_supervisor, DHT.TaskSupervisor),
      bootstrap: Keyword.get(opts, :bootstrap, DHT.bootstrap_nodes()),
      persist?: Keyword.get(opts, :persist, true),
      walked_at: now() - 1_000
    }

    {:ok, state, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, state) do
    saved = if state.persist?, do: DHT.load_nodes(), else: []
    now = now()

    table =
      Enum.reduce(saved, state.table, fn {id, address}, table ->
        Table.add(table, id, address, now)
      end)

    Logger.info("[DHT] sampler starting with #{length(saved)} saved nodes")

    Process.send_after(self(), :tick, @tick)
    _ = if state.persist?, do: Process.send_after(self(), :save, @save_every)

    {:noreply, %{state | table: table}}
  end

  @impl true
  def handle_call(:size, _from, state), do: {:reply, Table.size(state.table), state}

  @impl true
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @tick)
    state = if backlogged?(state), do: state, else: state |> sample_due() |> walk()
    Stats.put(:nodes_known, Table.size(state.table))
    {:noreply, state}
  end

  def handle_info(:save, state) do
    Process.send_after(self(), :save, @save_every)
    save(state)
    {:noreply, state}
  end

  def handle_info({ref, {kind, address, result}}, state) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    state = %{state | in_flight: Map.delete(state.in_flight, ref)}
    {:noreply, handle_result(state, kind, address, result)}
  end

  # A query task that crashed never reported back, so its node was never
  # put back in the due set. Count it as a failure.
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {address, in_flight} = Map.pop(state.in_flight, ref)
    state = %{state | in_flight: in_flight}

    case address do
      nil -> {:noreply, state}
      address -> {:noreply, %{state | table: Table.failed(state.table, address, now())}}
    end
  end

  def handle_info({:bootstrap, addresses}, state) do
    {:noreply, Enum.reduce(addresses, state, &find_node(&2, &1))}
  end

  def handle_info({:EXIT, _pid, _reason}, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, state) do
    if state.persist?, do: save(state)
  end

  # Enough hashes wait to keep every fetch busy for a while: a packet spent
  # sampling now finds hashes that would only be shed.
  defp backlogged?(state) do
    Fetcher.backlog(state.fetcher) >= state.backlog_limit
  catch
    :exit, _reason -> false
  end

  defp sample_due(state) do
    with true <- map_size(state.in_flight) < state.max_in_flight,
         {:ok, address, table} <- Table.pop_due(state.table, now()) do
      args = %{"target" => :crypto.strong_rand_bytes(20)}
      sample_due(ask(%{state | table: table}, :sample, address, "sample_infohashes", args))
    else
      _ -> state
    end
  end

  # With nobody due, widen the frontier: at most a few find_nodes a tick,
  # and only while there is room in the table and in flight.
  defp walk(state) do
    now = now()
    room = state.max_in_flight - map_size(state.in_flight)

    cond do
      room <= 0 or now - state.walked_at < 200 ->
        state

      Table.size(state.table) == 0 ->
        state |> bootstrap() |> Map.put(:walked_at, now + 5_000)

      Table.due_count(state.table, now, 1) == 0 and Table.size(state.table) < state.table.max ->
        state.table
        |> Table.random(min(room, 4))
        |> Enum.reduce(state, fn address, state -> find_node(state, address) end)
        |> Map.put(:walked_at, now)

      true ->
        state
    end
  end

  # The routers are looked up in a task: DNS can take seconds, and the
  # sampler has answers to handle meanwhile.
  defp bootstrap(state) do
    sampler = self()
    hosts = state.bootstrap

    {:ok, _pid} =
      Task.Supervisor.start_child(state.tasks, fn ->
        addresses =
          for {host, port} <- hosts,
              {:ok, ip} <- [:inet.getaddr(String.to_charlist(host), :inet)],
              do: {ip, port}

        send(sampler, {:bootstrap, addresses})
      end)

    state
  end

  defp find_node(state, address) do
    ask(state, :find_node, address, "find_node", %{"target" => :crypto.strong_rand_bytes(20)})
  end

  defp ask(state, kind, address, method, args) do
    node = state.node

    task =
      Task.Supervisor.async_nolink(state.tasks, fn ->
        {kind, address, Node.query(address, method, args, server: node)}
      end)

    %{state | in_flight: Map.put(state.in_flight, task.ref, address)}
  end

  defp handle_result(state, kind, address, {:ok, results}) do
    now = now()

    table =
      Enum.reduce(results.nodes, state.table, fn {id, address}, table ->
        Table.add(table, id, address, now)
      end)

    # A bootstrap router or a find_node target may not be in the table; it
    # joins it now that it answered.
    table = Table.add(table, results.id, address, now)

    case {kind, results.samples} do
      {:sample, nil} ->
        %{state | table: Table.answered(table, address, nil, now)}

      {:sample, samples} ->
        Stats.count(:sampled, length(samples))
        if samples != [], do: Fetcher.sampled(state.fetcher, address, samples)
        %{state | table: Table.answered(table, address, results.interval || 0, now)}

      {:find_node, _samples} ->
        %{state | table: table}
    end
  end

  # An error reply means the node is alive but won't sample.
  defp handle_result(state, _kind, address, {:error, {:krpc, _code}}) do
    %{state | table: Table.answered(state.table, address, nil, now())}
  end

  defp handle_result(state, _kind, address, {:error, :busy}) do
    %{state | table: Table.later(state.table, address, now() + 1_000)}
  end

  defp handle_result(state, _kind, address, {:error, _reason}) do
    %{state | table: Table.failed(state.table, address, now())}
  end

  defp save(state) do
    DHT.save_nodes(Table.answered_nodes(state.table, @saved_nodes))
  rescue
    error -> Logger.warning("[DHT] could not save nodes: #{Exception.message(error)}")
  end

  defp now, do: System.monotonic_time(:millisecond)
end
