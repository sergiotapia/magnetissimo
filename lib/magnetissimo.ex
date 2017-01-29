defmodule Magnetissimo do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Magnetissimo.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Magnetissimo.Endpoint, []),
      # Start your own worker by calling: Magnetissimo.Worker.start_link(arg1, arg2, arg3)
      worker(Magnetissimo.Crawler.ThePirateBay, []),
      worker(Magnetissimo.Crawler.EZTV, []),
      worker(Magnetissimo.Crawler.LimeTorrents, []),
      worker(Magnetissimo.Crawler.Leetx, []),
      worker(Magnetissimo.Crawler.TorrentDownloads, []),
      # worker(Magnetissimo.Crawler.Demonoid, []), # Down until Demonoid solve their hosting issues.
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Magnetissimo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Magnetissimo.Endpoint.config_change(changed, removed)
    :ok
  end
end
