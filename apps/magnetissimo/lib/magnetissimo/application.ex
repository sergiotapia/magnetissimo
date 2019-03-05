defmodule Magnetissimo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Magnetissimo.Repo,
      Magnetissimo.Crawlers.EZTV,
      Magnetissimo.Crawlers.ThePirateBay
      # Magnetissimo.Crawlers.TorrentDownloads,
      # Magnetissimo.Crawlers.Nyaa,
      # Magnetissimo.Crawlers.NyaaPantsu,
      # Magnetissimo.Crawlers.YTS,
      # Magnetissimo.Crawlers.Leetx
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Magnetissimo.Supervisor)
  end
end
