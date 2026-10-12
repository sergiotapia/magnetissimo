defmodule Magnetissimo.DHT.Crawler do
  @moduledoc """
  The running crawler, at one rate. `Magnetissimo.DHT.Runner` starts it when
  the DHT is switched on, and stops and restarts it when the rate changes.

  `:rest_for_one`, in the order data flows backwards: the stats and the
  socket first, then the indexer, the fetcher and the sampler. A crashed
  socket restarts everything after it, since every query in flight died
  with it; a crashed sampler restarts only itself. On a stop the sampler
  saves the nodes it knows and the indexer writes what is waiting, so a
  restart picks up where it left off.
  """

  use Supervisor

  require Logger

  alias Magnetissimo.DHT

  def start_link(config), do: Supervisor.start_link(__MODULE__, config)

  @impl true
  def init(config) do
    # A database seeded before the DHT source existed gets its row now,
    # which the fetcher files every torrent under. A release has already
    # seeded by this point; this covers `mix phx.server`.
    :ok = Magnetissimo.Seeds.run()

    Logger.info(
      "[DHT] crawling at #{config.preset}: #{config.rate} packets/s, #{config.fetches} fetches at once"
    )

    children = [
      {DHT.Stats, config: config},
      {Task.Supervisor, name: DHT.TaskSupervisor},
      {DHT.Node, rate: config.rate, port: config.port},
      DHT.Indexer,
      {DHT.Fetcher, fetches: config.fetches},
      {DHT.Sampler, rate: config.rate, backlog_limit: config.fetches * 25}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
