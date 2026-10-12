defmodule MagnetissimoWeb.TorznabControllerTest do
  # Not async: the search writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  alias Magnetissimo.FastCrawler
  alias Magnetissimo.SourceSearch
  alias Magnetissimo.TorrentsFixtures

  setup :stub_sources

  # One source that answers at once and reports every term it is asked for.
  setup do
    Application.put_env(:magnetissimo, SourceSearch, crawlers: [FastCrawler], ttl: 0)
    Application.put_env(:magnetissimo, :crawler_test_pid, self())
    on_exit(fn -> Application.delete_env(:magnetissimo, :crawler_test_pid) end)
  end

  # Parses the response as XML, which fails the test if it is not well formed.
  # xmerl decodes the bytes itself, as the declaration says UTF-8.
  defp xml(conn) do
    {doc, []} = conn.resp_body |> :binary.bin_to_list() |> :xmerl_scan.string(quiet: true)
    doc
  end

  defp count(doc, path), do: length(:xmerl_xpath.string(String.to_charlist(path), doc))

  # The text of every node the XPath selects, or the value of every attribute.
  defp select(doc, path) do
    for node <- :xmerl_xpath.string(String.to_charlist(path), doc) do
      case node do
        {:xmlText, _parents, _pos, _language, value, _type} -> List.to_string(value)
        attribute -> attribute |> elem(8) |> List.to_string()
      end
    end
  end

  defp api(conn, params), do: get(conn, ~p"/api?#{params}")

  test "the caps offer free-text search and every category", %{conn: conn} do
    conn = api(conn, t: "caps")
    assert response_content_type(conn, :xml)
    doc = xml(conn)

    assert select(doc, "//tv-search/@supportedParams") == ["q,season,ep"]
    assert select(doc, "//movie-search/@supportedParams") == ["q"]
    assert select(doc, "//book-search/@supportedParams") == ["q,author,title"]
    assert select(doc, "//audio-search/@available") == ["yes"]
    assert select(doc, "//limits/@max") == ["100"]
    assert select(doc, "//category[@id='3000']/subcat[@id='3030']/@name") == ["Audio/Audiobook"]
  end

  test "a poll with no text answers from the index and asks no site", %{conn: conn} do
    TorrentsFixtures.torrent_fixture(%{
      name: "Older Show",
      category: "TV",
      published_at: ~U[2026-01-01 00:00:00Z]
    })

    TorrentsFixtures.torrent_fixture(%{name: "Newer Show", category: "TV/HD"})
    TorrentsFixtures.torrent_fixture(%{name: "A Film", category: "Movies"})

    doc =
      conn |> api(t: "tvsearch", cat: "5030,5040", extended: 1, offset: 0, limit: 100) |> xml()

    # Sonarr asks for TV/SD and TV/HD; a torrent filed under TV is one too.
    assert select(doc, "//item/title/text()") == ["Newer Show", "Older Show"]
    assert select(doc, "//newznab:response/@total") == ["2"]
    refute_received {:crawled, _, _, _}
  end

  test "a poll leaves out what the DHT found, which a search still finds", %{conn: conn} do
    TorrentsFixtures.torrent_fixture(%{name: "Site Show", category: "TV/HD"})
    TorrentsFixtures.torrent_fixture(%{name: "DHT Show", category: "TV/HD", source: "DHT"})

    doc = conn |> api(t: "tvsearch", cat: "5040") |> xml()
    assert select(doc, "//item/title/text()") == ["Site Show"]
    assert select(doc, "//newznab:response/@total") == ["1"]

    doc = conn |> api(t: "search", q: "dht show") |> xml()
    assert "DHT Show" in select(doc, "//item/title/text()")
  end

  test "a poll that finds nothing gets a placeholder, not an empty feed", %{conn: conn} do
    doc = conn |> api(t: "book", cat: "3030") |> xml()

    assert [_title] = select(doc, "//item/title/text()")
    assert select(doc, "//item/torznab:attr[@name='category']/@value") == ["3030"]
    refute_received {:crawled, _, _, _}

    # A later page is past the end, and is empty.
    assert build_conn() |> api(t: "book", cat: "3030", offset: 100) |> xml() |> count("//item") ==
             0
  end

  test "a search asks the sources, rebuilt as one term, then reads the index", %{conn: conn} do
    TorrentsFixtures.torrent_fixture(%{name: "Fixture Show S01E02 1080p", category: "TV/HD"})

    doc =
      conn
      |> api(t: "tvsearch", q: "Fixture Show", season: "01", ep: "02")
      |> xml()

    assert_received {:crawled, "YTS", "fixture show s01e02", _pid}

    titles = select(doc, "//item/title/text()")
    assert "Fixture Show S01E02 1080p" in titles
    assert "fixture show s01e02 fast" in titles
  end

  test "a later page reads the index without asking the sources again", %{conn: conn} do
    for n <- 1..3, do: TorrentsFixtures.torrent_fixture(%{name: "Paged Film #{n}"})

    doc = conn |> api(t: "search", q: "Paged Film", limit: 2, offset: 2) |> xml()

    assert count(doc, "//item") == 1
    assert select(doc, "//newznab:response/@offset") == ["2"]
    assert select(doc, "//newznab:response/@total") == ["3"]
    refute_received {:crawled, _, _, _}
  end

  test "an item carries the magnet everywhere a client looks for it", %{conn: conn} do
    torrent =
      TorrentsFixtures.torrent_fixture(%{
        name: "Tom & Jerry <Uncut> \x01 トムとジェリー",
        category: "Movies/UHD",
        seeders: 7,
        leechers: 3,
        published_at: ~U[2026-10-05 14:02:11Z]
      })

    doc = conn |> api(t: "movie", q: "Tom Jerry", cat: "2000") |> xml()
    attr = &select(doc, "//item/torznab:attr[@name='#{&1}']/@value")

    assert select(doc, "//item/title/text()") == ["Tom & Jerry <Uncut>  トムとジェリー"]
    assert select(doc, "//item/guid/text()") == [torrent.magnet_hash]
    assert select(doc, "//item/link/text()") == [torrent.magnet_url]
    assert select(doc, "//item/enclosure/@url") == [torrent.magnet_url]
    assert select(doc, "//item/enclosure/@type") == ["application/x-bittorrent"]
    assert attr.("magneturl") == [torrent.magnet_url]
    assert attr.("infohash") == [torrent.magnet_hash]
    assert attr.("size") == ["1400000000"]
    assert select(doc, "//item/enclosure/@length") == ["1400000000"]
    assert attr.("seeders") == ["7"]
    assert attr.("peers") == ["10"]
    assert attr.("category") == ["2045", "2000"]
    assert select(doc, "//item/pubDate/text()") == ["Mon, 05 Oct 2026 14:02:11 +0000"]

    assert select(doc, "//item/comments/text()") == [
             "http://www.example.com/torrents/#{torrent.id}"
           ]
  end

  test "links follow the scheme a TLS-ending proxy says it was", %{conn: conn} do
    doc =
      conn
      |> put_req_header("x-forwarded-proto", "https")
      |> api(t: "book", cat: "3030")
      |> xml()

    assert select(doc, "//channel/link/text()") == ["https://www.example.com/"]
  end

  test "ids it cannot look up match nothing and ask no site", %{conn: conn} do
    TorrentsFixtures.torrent_fixture(%{name: "The Matrix"})

    doc = conn |> api(t: "movie", imdbid: "0133093") |> xml()

    assert count(doc, "//item") == 0
    refute_received {:crawled, _, _, _}
  end

  test "errors are Newznab documents with a 200", %{conn: conn} do
    conn = api(conn, t: "details", id: "1")

    assert conn.status == 200
    assert select(xml(conn), "/error/@code") == ["203"]
  end
end
