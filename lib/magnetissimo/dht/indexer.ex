defmodule Magnetissimo.DHT.Indexer do
  @moduledoc """
  Writes what the DHT found, in batches, and tells the DHT page.

  SQLite has one writer, and a search's sources write too, so the crawler
  never writes a torrent at a time: torrents gather here and are indexed in
  one `Magnetissimo.Torrents.index_torrents/2` call every second, or sooner
  once 25 are waiting. Swarm estimates wait for the same flush, after the
  torrents, so a torrent always exists before its numbers arrive.

  Each flush broadcasts `{:dht_indexed, torrents}` and a `{:dht_swarm, …}` per
  estimate (see `Magnetissimo.DHT.subscribe/0`).
  """

  use GenServer

  require Logger

  alias Magnetissimo.DHT
  alias Magnetissimo.DHT.Stats
  alias Magnetissimo.Torrents

  @flush_every 1_000
  @batch 25

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc "Queues a torrent's attrs for indexing."
  @spec index(GenServer.server(), map()) :: :ok
  def index(server \\ __MODULE__, attrs), do: GenServer.cast(server, {:index, attrs})

  @doc "Queues a swarm estimate for the torrent with this hex infohash."
  @spec swarm(GenServer.server(), String.t(), non_neg_integer(), non_neg_integer()) :: :ok
  def swarm(server \\ __MODULE__, hash, seeders, leechers) do
    GenServer.cast(server, {:swarm, hash, seeders, leechers})
  end

  @doc "Writes whatever is waiting now. For tests."
  @spec flush(GenServer.server()) :: :ok
  def flush(server \\ __MODULE__), do: GenServer.call(server, :flush)

  @impl true
  def init(_opts) do
    Process.flag(:trap_exit, true)
    Process.send_after(self(), :flush, @flush_every)
    {:ok, %{torrents: [], swarms: []}}
  end

  @impl true
  def handle_cast({:index, attrs}, state) do
    state = %{state | torrents: [attrs | state.torrents]}
    if length(state.torrents) >= @batch, do: {:noreply, write(state)}, else: {:noreply, state}
  end

  def handle_cast({:swarm, hash, seeders, leechers}, state) do
    {:noreply, %{state | swarms: [{hash, seeders, leechers} | state.swarms]}}
  end

  @impl true
  def handle_call(:flush, _from, state), do: {:reply, :ok, write(state)}

  @impl true
  def handle_info(:flush, state) do
    Process.send_after(self(), :flush, @flush_every)
    {:noreply, write(state)}
  end

  def handle_info({:EXIT, _pid, _reason}, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, state) do
    _ = write(state)
    :ok
  end

  defp write(state) do
    index_batch(Enum.reverse(state.torrents))
    update_swarms(Enum.reverse(state.swarms))
    %{state | torrents: [], swarms: []}
  end

  defp index_batch([]), do: :ok

  defp index_batch(attrs) do
    %{ids: ids, inserted: inserted, rejected: rejected} = Torrents.index_torrents(attrs)
    Stats.count(:indexed, inserted)

    for {attrs, errors} <- rejected do
      Stats.count(:refused)
      Logger.warning("[DHT] rejected #{inspect(attrs[:name])}: #{inspect(errors)}")
    end

    # A site may have indexed one of these hashes since the fetcher checked;
    # that torrent stays the site's, and off the DHT page.
    found = ids |> Torrents.get_torrents() |> Enum.filter(&(&1.source.name == "DHT"))
    _ = if found != [], do: DHT.broadcast({:dht_indexed, found})
    :ok
  end

  defp update_swarms(swarms) do
    Enum.each(swarms, fn {hash, seeders, leechers} ->
      case Torrents.update_swarm(hash, seeders, leechers) do
        {:ok, id} -> DHT.broadcast({:dht_swarm, %{id: id, seeders: seeders, leechers: leechers}})
        :error -> :ok
      end
    end)
  end
end
