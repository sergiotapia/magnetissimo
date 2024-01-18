defmodule MagnetissimoWeb.TorrentController do
  use MagnetissimoWeb, :controller

  alias Magnetissimo.Torrents

  def latest(conn, _params) do
    IO.inspect("HERE =====")
    torrents = Torrents.list_torrents(50)
    render(conn, :latest, torrents: torrents)
  end

  def latest_torznab(conn, _params) do
    torrents = Torrents.list_torrents(50)

    conn
    |> put_resp_content_type("text/xml")
    |> render("latest_torznab.xml", torrents: torrents)
  end

  # Torznab API handlers.

  # def search(conn, %{"search_term" => search_term} = _params) do
  #   torrents = Torrents.search_torrents(search_term)
  #   render(conn, :index, torrents: torrents)
  # end

  # def search_torznab(conn, %{"search_term" => search_term} = _params) do
  #   torrents = Torrents.search_torrents(search_term)

  #   conn
  #   |> put_resp_content_type("text/xml")
  #   |> render("search_torznab.xml", torrents: torrents)
  # end
end
