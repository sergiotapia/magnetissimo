defmodule Magnetissimo.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    children = [
      {Magnetissimo.Repo, []},
      {MagnetissimoWeb.Endpoint, []},
      {Magnetissimo.Crawler.Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Magnetissimo.Supervisor]

    if Code.ensure_loaded?(Sentry.Logger), do:
        :ok = :error_logger.add_report_handler(Sentry.Logger)
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MagnetissimoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
