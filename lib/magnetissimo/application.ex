defmodule Magnetissimo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MagnetissimoWeb.Telemetry,
      # Start the Ecto repository
      Magnetissimo.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Magnetissimo.PubSub},
      # Start Finch
      {Finch, name: Magnetissimo.Finch},
      # Start the Endpoint (http/https)
      MagnetissimoWeb.Endpoint,
      {Oban, Application.fetch_env!(:magnetissimo, Oban)},
      # Start a worker by calling: Magnetissimo.Worker.start_link(arg)
      # {Magnetissimo.Worker, arg}
      Magnetissimo.Genservers.Leetx,
      Magnetissimo.Genservers.Nyaa,
      Magnetissimo.Genservers.TorrentDownloads,
      Magnetissimo.Genservers.Yts
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
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
end
