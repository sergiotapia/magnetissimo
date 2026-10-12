defmodule Magnetissimo.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # A release migrates and seeds the sources before anything else starts,
    # so a fresh container or an upgrade needs no step by hand. It happens
    # here, on one connection of its own, rather than in an `Ecto.Migrator`
    # child sharing the Repo's pool: a pooled connection opened on the empty
    # file kept a stale schema, and a migration that ran on it failed about
    # one fresh boot in three.
    if release?(), do: Magnetissimo.Release.migrate()

    children = [
      MagnetissimoWeb.Telemetry,
      Magnetissimo.Repo,
      {DNSCluster, query: Application.get_env(:magnetissimo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Magnetissimo.PubSub},
      # Every site is asked through this, so none is asked too often.
      Magnetissimo.Crawlers.Pacer,
      # Each source a search asks runs as its own task under this supervisor,
      # so a source that crashes takes only its own answer with it.
      {Task.Supervisor, name: Magnetissimo.SourceSearch.TaskSupervisor},
      Magnetissimo.SourceSearch,
      # The DHT crawler's runner, which starts the crawler only once it is
      # switched on at /dht.
      Magnetissimo.DHT.Supervisor,
      # Start to serve requests, typically the last entry
      MagnetissimoWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options.
    opts = [strategy: :one_for_one, name: Magnetissimo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MagnetissimoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Migrations run from the release when there is one, and from
  # `mix ecto.migrate` otherwise.
  defp release?, do: System.get_env("RELEASE_NAME") != nil
end
