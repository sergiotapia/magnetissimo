defmodule Magnetissimo do
  use Application

  @strategy [restart: :permanent]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Magnetissimo.Repo, [], @strategy),
      # Start the endpoint when the application starts
      supervisor(Magnetissimo.Endpoint, [], @strategy),
      # Start your own worker by calling: Magnetissimo.Worker.start_link(arg1, arg2, arg3)
      worker(Magnetissimo.Crawler.Demonoid, [], @strategy),
      worker(Magnetissimo.Crawler.EZTV, [], @strategy),
      worker(Magnetissimo.Crawler.Leetx, [], @strategy),
      worker(Magnetissimo.Crawler.NyaaSi, [], @strategy),
      # worker(Magnetissimo.Crawler.ThePirateBay, [], @strategy),
      # Broken temporarily.
      # worker(Magnetissimo.Crawler.Zooqle, [], @strategy),


      # worker(Magnetissimo.Crawler.Leetx,             []),
      # worker(Magnetissimo.Crawler.Monova,            []),
      # worker(Magnetissimo.Crawler.TorrentDownloads,  []),
      # worker(Magnetissimo.Crawler.WorldWideTorrents, []),
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
