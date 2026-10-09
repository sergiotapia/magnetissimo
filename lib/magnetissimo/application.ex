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
      # Start a worker by calling: Magnetissimo.Worker.start_link(arg)
      # {Magnetissimo.Worker, arg},
      # Start to serve requests, typically the last entry
      MagnetissimoWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
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
