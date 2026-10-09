defmodule Magnetissimo.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MagnetissimoWeb.Telemetry,
      Magnetissimo.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:magnetissimo, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:magnetissimo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Magnetissimo.PubSub},
      # One scheduler per crawl source. Add the next source to this list.
      # The scheduler module is the same for each, so each needs its own id.
      Supervisor.child_spec({Magnetissimo.Crawlers.Scheduler, crawler: Magnetissimo.Crawlers.Yts},
        id: :yts_scheduler
      ),
      Supervisor.child_spec(
        {Magnetissimo.Crawlers.Scheduler, crawler: Magnetissimo.Crawlers.Nyaa},
        id: :nyaa_scheduler
      ),
      Supervisor.child_spec(
        {Magnetissimo.Crawlers.Scheduler, crawler: Magnetissimo.Crawlers.Sukebei},
        id: :sukebei_scheduler
      ),
      Supervisor.child_spec(
        {Magnetissimo.Crawlers.Scheduler, crawler: Magnetissimo.Crawlers.TorrentDownloads},
        id: :torrent_downloads_scheduler
      ),
      # Start to serve requests, typically the last entry
      MagnetissimoWeb.Endpoint
    ]

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
