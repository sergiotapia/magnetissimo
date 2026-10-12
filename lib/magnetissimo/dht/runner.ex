defmodule Magnetissimo.DHT.Runner do
  @moduledoc """
  Keeps the crawler in line with its settings. On boot it reads them and
  starts the crawler if the DHT is on; `apply_config/1`, which
  `Magnetissimo.DHT.update_settings/1` calls, starts it, stops it, or
  restarts it at a new rate.

  The crawler it starts is `Magnetissimo.DHT.Crawler` unless config names
  another: tests set a stand-in, so switching the DHT on in a test never
  reaches the network.
  """

  use GenServer

  require Logger

  alias Magnetissimo.DHT

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Starts, stops or restarts the crawler to match `config`."
  @spec apply_config(map()) :: :ok
  def apply_config(config) do
    if Process.whereis(__MODULE__),
      do: GenServer.call(__MODULE__, {:apply, config}, 30_000),
      else: :ok
  end

  @impl true
  def init(_opts), do: {:ok, %{pid: nil, config: nil}, {:continue, :boot}}

  @impl true
  def handle_continue(:boot, state), do: {:noreply, converge(state, DHT.config())}

  @impl true
  def handle_call({:apply, config}, _from, state), do: {:reply, :ok, converge(state, config)}

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, %{pid: pid} = state) do
    {:noreply, %{state | pid: nil}}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state), do: {:noreply, state}

  defp converge(%{pid: pid, config: running} = state, config) when is_pid(pid) do
    if config.enabled and Map.delete(config, :enabled) == Map.delete(running, :enabled),
      do: state,
      else: converge(stop(state), config)
  end

  defp converge(state, %{enabled: true} = config) do
    crawler =
      :magnetissimo |> Application.get_env(__MODULE__, []) |> Keyword.get(:crawler, DHT.Crawler)

    case DynamicSupervisor.start_child(DHT.CrawlerSlot, %{
           id: crawler,
           start: {crawler, :start_link, [config]},
           type: :supervisor,
           restart: :temporary
         }) do
      {:ok, pid} ->
        Process.monitor(pid)
        %{state | pid: pid, config: config}

      {:error, reason} ->
        Logger.error("[DHT] the crawler would not start: #{inspect(reason)}")
        state
    end
  end

  defp converge(state, config), do: %{state | config: config}

  defp stop(%{pid: pid} = state) do
    _ = DynamicSupervisor.terminate_child(DHT.CrawlerSlot, pid)
    Logger.info("[DHT] crawler stopped")
    _ = DHT.broadcast({:dht_status, %{running: false, config: state.config}})
    %{state | pid: nil}
  end
end
