defmodule Magnetissimo.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # One scheduler per crawl source. The scheduler module is the same for
    # each, so each needs its own id.
    schedulers =
      for crawler <- Magnetissimo.Crawlers.all() do
        Supervisor.child_spec({Magnetissimo.Crawlers.Scheduler, crawler: crawler},
          id: {Magnetissimo.Crawlers.Scheduler, crawler}
        )
      end

    # Flattened, so the schedulers sit in the middle of the list.
    children =
      List.flatten([
        MagnetissimoWeb.Telemetry,
        Magnetissimo.Repo,
        {Ecto.Migrator,
         repos: Application.fetch_env!(:magnetissimo, :ecto_repos), skip: skip_migrations?()},
        {DNSCluster, query: Application.get_env(:magnetissimo, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Magnetissimo.PubSub},
        schedulers,
        # Start to serve requests, typically the last entry
        MagnetissimoWeb.Endpoint
      ])

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options.
    #
    # A crawler that dies takes only its own scheduler with it, so one bad
    # source cannot stop the others from crawling.
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
  defp skip_migrations? do
    System.get_env("RELEASE_NAME") == nil
  end
end
