defmodule MagnetissimoWeb.TorrentsController do
  use MagnetissimoWeb, :controller

  alias Magnetissimo.Torrents

  def search(conn, _params) do
    torrents = Torrents.search_torrents("red dwarf")
    render(conn, :index, torrents: torrents)
  end

  def latest(conn, _params) do
    torrents = Torrents.list_torrents()
    render(conn, :index, torrents: torrents)
  end
end
