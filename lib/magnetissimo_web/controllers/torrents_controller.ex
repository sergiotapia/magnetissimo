defmodule MagnetissimoWeb.TorrentsController do
  use MagnetissimoWeb, :controller

  alias Magnetissimo.Torrents

  def search(conn, %{"search_term" => search_term} = _params) do
    torrents = Torrents.search_torrents(search_term)
    render(conn, :index, torrents: torrents)
  end

  def latest(conn, _params) do
    torrents = Torrents.list_torrents()
    render(conn, :index, torrents: torrents)
  end
end
