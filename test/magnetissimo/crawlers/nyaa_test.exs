defmodule Magnetissimo.Crawlers.NyaaTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers.Nyaa
  alias Magnetissimo.Crawlers.Nyaa.Feed
  alias Magnetissimo.Crawlers.Sukebei
  alias Magnetissimo.NyaaFixtures
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes every item, decoding entities and downcasing the hash" do
    stub(NyaaFixtures.rss_body())

    assert :ok = Nyaa.crawl_latest()

    assert [newest, older] = Torrents.list_latest_torrents()

    assert newest.name == "[Group] Show & Tell - 01 (1080p)"
    assert newest.category.name == "Anime - English-translated"
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

  test "crawling the same feed again adds nothing" do
    stub(NyaaFixtures.rss_body())

    assert :ok = Nyaa.crawl_latest()
    assert :ok = Nyaa.crawl_latest()

    assert Torrents.count_torrents() == 2
  end

  test "sukebei files items under its own source, category and tracker" do
    stub(NyaaFixtures.sukebei_rss_body())

    assert :ok = Sukebei.crawl_latest()

    assert [torrent] = Torrents.list_latest_torrents()
    assert torrent.source.name == "Sukebei"
    assert torrent.category.name == "Video - XXX"
    assert torrent.magnet_url =~ "&tr=http%3A%2F%2Fsukebei.tracker.wf%3A8888%2Fannounce"
  end

  test "an item with no usable date or size is skipped, not crashed on" do
    stub(NyaaFixtures.malformed_rss_body())

    assert :ok = Nyaa.crawl_latest()
    assert Torrents.count_torrents() == 0
  end

  test "a failing site is logged, not raised" do
    Req.Test.stub(Feed, fn conn -> Plug.Conn.send_resp(conn, 503, "unavailable") end)

    log = ExUnit.CaptureLog.capture_log(fn -> assert :ok = Nyaa.crawl_latest() end)

    assert log =~ "crawl failed"
    assert Torrents.count_torrents() == 0
  end

  test "search asks the feed for the term and reports hits as they land" do
    Req.Test.stub(Feed, fn conn ->
      assert conn.query_string =~ "q=Fixture+Search"
      Plug.Conn.send_resp(conn, 200, NyaaFixtures.rss_body())
    end)

    assert :ok = Nyaa.search("Fixture Search", notify: self())
    assert_received {:source_search, "Fixture Search", :updated}
    assert_received {:source_search, "Fixture Search", :done}
    assert Torrents.count_torrents() == 2

    # The same term again adds nothing, so it only reports done.
    assert :ok = Nyaa.search("Fixture Search", notify: self())
    refute_received {:source_search, _, :updated}
    assert_received {:source_search, _, :done}
  end

  test "a search that fails still reports done, so no caller waits forever" do
    Req.Test.stub(Feed, fn conn -> Plug.Conn.send_resp(conn, 500, "nope") end)

    assert :ok = Nyaa.search("Anything", notify: self())

    refute_received {:source_search, _, :updated}
    assert_received {:source_search, "Anything", :done}
  end

  defp stub(body) do
    Req.Test.stub(Feed, fn conn -> Plug.Conn.send_resp(conn, 200, body) end)
  end
end
