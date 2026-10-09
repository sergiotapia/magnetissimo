defmodule MagnetissimoWeb.TorrentController do
  @moduledoc """
  Keeps the two endpoints the 2.0.0 app exposed, `GET /api/latest` and
  `GET /api/search/:term`, with the same field names, so a Sonarr or Radarr
  pointed at the old app keeps working against this one.
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
