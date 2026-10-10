defmodule MagnetissimoWeb.TorrentController do
  @moduledoc """
  Keeps the two endpoints the 2.0.0 app exposed, `GET /api/latest` and
  `GET /api/search/:term`, with the same field names, so scripts written
  against the old app keep working against this one. Sonarr, Radarr and the
  rest cannot read JSON; they use the Torznab API in
  `MagnetissimoWeb.TorznabController`.
  """
  use MagnetissimoWeb, :controller

  alias Magnetissimo.SourceSearch
  alias Magnetissimo.Torrents

  def latest(conn, _params) do
    render(conn, :index, torrents: Torrents.list_latest_torrents())
  end

  # A JSON client cannot be sent results later, so the sources are given
  # their full time to answer before the index is read. A term asked recently
  # answers straight from the index.
  def search(conn, %{"term" => term}) do
    _statuses = SourceSearch.await(term)
    render(conn, :index, torrents: Torrents.search_torrents(term))
  end
end
