defmodule Magnetissimo.Crawlers.NyaaTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.Nyaa
  alias Magnetissimo.Crawlers.Nyaa.Feed
  alias Magnetissimo.Crawlers.Sukebei
  alias Magnetissimo.NyaaFixtures
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes every item, decoding entities and downcasing the hash" do
    stub(NyaaFixtures.rss_body())

    assert {:ok, %{inserted: 2}} = Crawlers.search(Nyaa, "Fixture")

    assert [newest, older] = Torrents.list_latest_torrents()

    assert newest.name == "[Group] Show & Tell - 01 (1080p)"
    assert category(newest) == "TV/Anime"
    assert newest.source.name == "Nyaa.si"
    assert newest.canonical_url == "https://nyaa.test/view/1"
    assert newest.magnet_hash == NyaaFixtures.hash_lower()
    assert newest.seeders == 12
    assert newest.leechers == 3
    assert newest.size_in_bytes == round(1.5 * 1024 ** 3)
    assert DateTime.to_unix(newest.published_at) == DateTime.to_unix(~U[2026-10-09 23:24:24Z])

    assert String.starts_with?(
             newest.magnet_url,
             "magnet:?xt=urn:btih:#{NyaaFixtures.hash_lower()}" <>
               "&dn=%5BGroup%5D+Show+%26+Tell+-+01+%281080p%29" <>
               "&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce"
           )

    assert older.name == "Café & 日本語 'quoted' - 02"
    assert older.magnet_hash == String.downcase(NyaaFixtures.hash_upper())
    assert older.size_in_bytes == round(700.5 * 1024 ** 2)
  end

  test "sukebei files items under its own source, category and tracker" do
    stub(NyaaFixtures.sukebei_rss_body())

    assert {:ok, %{inserted: 1}} = Crawlers.search(Sukebei, "Fixture")

    assert [torrent] = Torrents.list_latest_torrents()
    assert torrent.source.name == "Sukebei"
    assert category(torrent) == "XXX"
    assert torrent.magnet_url =~ "&tr=http%3A%2F%2Fsukebei.tracker.wf%3A8888%2Fannounce"
  end

  test "an item with no usable date or size is skipped, not crashed on" do
    stub(NyaaFixtures.malformed_rss_body())

    assert {:ok, %{found: 0}} = Crawlers.search(Nyaa, "Fixture")
    assert Torrents.count_torrents() == 0
  end

  test "a file small enough to be sized in bytes is indexed, not dropped" do
    stub(NyaaFixtures.bytes_size_rss_body())

    assert {:ok, %{inserted: 1}} = Crawlers.search(Sukebei, "Angel Club")

    assert [torrent] = Torrents.list_latest_torrents()
    assert torrent.name == "Angel Club 06-12.zip"
    assert torrent.size_in_bytes == 0
    # "Art - Anime": hentai, which the 2.0 mapping filed with work-safe anime.
    assert category(torrent) == "XXX"
  end

  test "search asks the feed for the term and makes its hits findable by it" do
    Req.Test.stub(Feed, fn conn ->
      assert conn.query_string =~ "q=Fixture+Search"
      Plug.Conn.send_resp(conn, 200, NyaaFixtures.rss_body())
    end)

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(Nyaa, "Fixture Search")
    assert Torrents.count_torrents() == 2

    # Neither name says "fixture search"; the site matched them, so we do too.
    assert Torrents.count_search_torrents("fixture search") == 2

    # The same term again finds the same torrents and adds nothing.
    assert {:ok, %{inserted: 0, found: 2}} = Crawlers.search(Nyaa, "Fixture Search")
  end

  test "a search that fails says why" do
    Req.Test.stub(Feed, fn conn -> Plug.Conn.send_resp(conn, 500, "nope") end)

    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:error, {:http_status, 500}} = Crawlers.search(Nyaa, "Anything")
      end)

    assert log =~ "failed"
  end

  defp category(torrent), do: Taxonomy.fetch!(torrent.category_id).name

  defp stub(body) do
    Req.Test.stub(Feed, fn conn -> Plug.Conn.send_resp(conn, 200, body) end)
  end
end
