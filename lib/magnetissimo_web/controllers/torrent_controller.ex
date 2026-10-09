defmodule MagnetissimoWeb.TorrentController do
  @moduledoc """
  The JSON API: the same two endpoints the 2.0.0 app exposed, so a Sonarr or
  Radarr setup that pointed at it keeps working.

      GET /api/latest
      GET /api/search/:term
  """
  use MagnetissimoWeb, :controller

  alias Magnetissimo.Torrents

  def latest(conn, _params) do
    render(conn, :index, torrents: Torrents.list_latest_torrents())
  end

  def search(conn, %{"term" => term}) do
    render(conn, :index, torrents: Torrents.search_torrents(term))
  end
end
