defmodule MagnetissimoWeb.TorrentController do
  @moduledoc """
  Keeps the two endpoints the 2.0.0 app exposed, `GET /api/latest` and
  `GET /api/search/:term`, with the same field names, so a Sonarr or Radarr
  pointed at the old app keeps working against this one.
  """
  use MagnetissimoWeb, :controller

  alias Magnetissimo.SourceSearch
  alias Magnetissimo.Torrents

  # Sonarr and Radarr give an indexer far longer than this, and a source that
  # has not answered by then is usually down rather than slow.
  @source_wait :timer.seconds(10)

  def latest(conn, _params) do
    render(conn, :index, torrents: Torrents.list_latest_torrents())
  end

  # A JSON client cannot be sent results later, so the sources are given a
  # moment to answer before the index is read. A term asked recently answers
  # straight from the index.
  def search(conn, %{"term" => term}) do
    _statuses = SourceSearch.await(term, @source_wait)
    render(conn, :index, torrents: Torrents.search_torrents(term))
  end
end
