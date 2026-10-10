defmodule MagnetissimoWeb.TorznabController do
  @moduledoc """
  The Torznab API at `GET /api`, so Sonarr, Radarr, Lidarr, Prowlarr and the
  book managers can add Magnetissimo as an indexer by its base URL alone:
  `/api` is every client's default API path, and Listenarr adds it itself.

  A request with a term is a search, and goes to the sources the way a
  reader's does (`Magnetissimo.SourceSearch`), waiting for every source to
  answer or be given up on before reading the index. Clients allow far
  longer than that. Only the first page asks the sources; the pages after
  it read what the first one indexed.

  A request without a term is a client polling its RSS or pressing Test, and
  it comes every 15 to 30 minutes from every client. It is answered from the
  index alone, newest first, and never reaches a site: polling is what got
  the project blocked by Nyaa and AudioBookBay. When the index holds nothing
  in the asked categories, the answer is a placeholder item rather than an
  empty feed, which every client's Test would fail.

  Any `apikey`, or none, is accepted, so a release needs no setup. Listenarr
  will not save an indexer without one, so users type anything. Errors are
  Newznab `<error>` documents with status 200, the only status at which
  Sonarr reads them.
  """
  use MagnetissimoWeb, :controller

  alias Magnetissimo.SourceSearch
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias MagnetissimoWeb.TorznabRequest
  alias MagnetissimoWeb.TorznabXML

  def index(conn, params) do
    case TorznabRequest.parse(params) do
      {:ok, %TorznabRequest{function: :caps}} ->
        send_xml(conn, "application/xml", TorznabXML.caps())

      {:ok, request} ->
        send_xml(conn, "application/rss+xml", feed(request, base_url(conn)))

      {:error, code, description} ->
        send_xml(conn, "application/xml", TorznabXML.error(code, description))
    end
  end

  defp feed(%TorznabRequest{unsupported?: true}, base_url) do
    TorznabXML.feed([], base_url: base_url, offset: 0, total: 0)
  end

  defp feed(%TorznabRequest{term: nil} = request, base_url) do
    opts = [category_ids: request.category_ids]

    torrents =
      Torrents.list_latest_torrents(opts ++ [limit: request.limit, offset: request.offset])

    if torrents == [] and request.offset == 0 do
      TorznabXML.placeholder(base_url, List.first(request.category_ids, Taxonomy.other_id()))
    else
      total = Torrents.count_torrents(opts)
      TorznabXML.feed(torrents, base_url: base_url, offset: request.offset, total: total)
    end
  end

  defp feed(%TorznabRequest{term: term} = request, base_url) do
    _statuses = if request.offset == 0, do: SourceSearch.await(term)

    opts = [category_ids: request.category_ids]

    torrents =
      Torrents.search_torrents(term, opts ++ [limit: request.limit, offset: request.offset])

    total = Torrents.count_search_torrents(term, opts)

    TorznabXML.feed(torrents, base_url: base_url, offset: request.offset, total: total)
  end

  defp send_xml(conn, content_type, xml) do
    conn
    |> put_resp_content_type(content_type)
    |> send_resp(200, xml)
  end

  # Links point back the way the client came in. The endpoint's configured
  # host is localhost unless PHX_HOST is set, and a homelab reaches the app
  # on its LAN address. Behind a reverse proxy that ends TLS, the request
  # arrives as http, and the proxy says what it was.
  defp base_url(conn) do
    uri = %URI{scheme: Atom.to_string(conn.scheme), host: conn.host, port: conn.port}

    case get_req_header(conn, "x-forwarded-proto") do
      ["https" | _] ->
        URI.to_string(%{uri | scheme: "https", port: 443})

      _direct ->
        URI.to_string(uri)
    end
  end
end
