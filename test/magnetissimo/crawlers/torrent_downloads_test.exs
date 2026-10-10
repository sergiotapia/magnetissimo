defmodule Magnetissimo.Crawlers.TorrentDownloadsTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.TorrentDownloadsFixtures
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes every item, converting the offset to UTC and downcasing the hash" do
    stub(TorrentDownloadsFixtures.rss_body())

    assert :ok = Crawlers.crawl_latest(TorrentDownloads)

    assert [newest, older] = Torrents.list_latest_torrents()

    assert newest.name == "Kill Jackie S01 2160p WEBRip HDR x265-KONTRAST"
    assert newest.category.name == "Video - Television"
    assert newest.source.name == "TorrentDownloads"

    assert newest.canonical_url ==
             "https://www.torrentdownloads.pro/torrent/1707208289/Kill-Jackie-S01-2160p-WEBRip-HDR-x265-KONTRAST"

    assert newest.magnet_hash == String.downcase(TorrentDownloadsFixtures.hash_upper())
    assert newest.seeders == 6
    assert newest.leechers == 34
    assert newest.size_in_bytes == 23_379_695_704
    # 01:40:07 +0200 is 23:40:07 the day before, in UTC.
    assert DateTime.to_unix(newest.published_at) == DateTime.to_unix(~U[2026-10-09 23:40:07Z])

    assert String.starts_with?(
             newest.magnet_url,
             "magnet:?xt=urn:btih:#{String.downcase(TorrentDownloadsFixtures.hash_upper())}" <>
               "&dn=Kill+Jackie+S01+2160p+WEBRip+HDR+x265-KONTRAST" <>
               "&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce"
           )

    assert older.name == "L’Officina della Camomilla - VM 18 [FLAC 24-44]"
    assert older.category.name == "Audio - Lossy"
  end

  test "entities in a title are decoded once" do
    body =
      String.replace(
        TorrentDownloadsFixtures.rss_body(),
        "L’Officina della Camomilla",
        "Fire &amp; Ice &amp;lt;3 &#233;"
      )

    stub(body)
    assert :ok = Crawlers.crawl_latest(TorrentDownloads)

    assert [_newest, older] = Torrents.list_latest_torrents()
    assert older.name == "Fire & Ice &lt;3 é - VM 18 [FLAC 24-44]"
  end

  test "crawling the same feed again adds nothing" do
    stub(TorrentDownloadsFixtures.rss_body())

    assert :ok = Crawlers.crawl_latest(TorrentDownloads)
    assert :ok = Crawlers.crawl_latest(TorrentDownloads)

    assert Torrents.count_torrents() == 2
  end

  test "an item with no usable date is skipped, not crashed on" do
    stub(TorrentDownloadsFixtures.malformed_rss_body())

    assert :ok = Crawlers.crawl_latest(TorrentDownloads)
    assert Torrents.count_torrents() == 0
  end

  test "a failing site is logged, not raised" do
    Req.Test.stub(TorrentDownloads, fn conn -> Plug.Conn.send_resp(conn, 503, "unavailable") end)

    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert :ok = Crawlers.crawl_latest(TorrentDownloads)
      end)

    assert log =~ "crawl failed"
    assert Torrents.count_torrents() == 0
  end

  test "search asks the feed for the term and files the uncategorised hit under Other" do
    Req.Test.stub(TorrentDownloads, fn conn ->
      assert conn.query_string =~ "type=search"
      assert conn.query_string =~ "search=Fixture+Search"
      Plug.Conn.send_resp(conn, 200, TorrentDownloadsFixtures.search_rss_body())
    end)

    assert {:ok, %{inserted: 1, found: 1}} = Crawlers.search(TorrentDownloads, "Fixture Search")

    assert [torrent] = Torrents.list_latest_torrents()
    assert torrent.category.name == "Other"

    # The same term again finds the same torrent and adds nothing.
    assert {:ok, %{inserted: 0, found: 1}} = Crawlers.search(TorrentDownloads, "Fixture Search")
  end

  test "a swarm the feed does not know is indexed as none, not as the biggest" do
    body =
      String.replace(
        TorrentDownloadsFixtures.rss_body(),
        "<seeders>6</seeders>",
        "<seeders>16777215</seeders>"
      )

    stub(body)
    assert :ok = Crawlers.crawl_latest(TorrentDownloads)

    assert [newest, _older] = Torrents.list_latest_torrents()
    assert newest.seeders == 0
  end

  test "a search that fails says why" do
    Req.Test.stub(TorrentDownloads, fn conn -> Plug.Conn.send_resp(conn, 500, "nope") end)

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, {:http_status, 500}} = Crawlers.search(TorrentDownloads, "Anything")
    end)
  end

  defp stub(body) do
    Req.Test.stub(TorrentDownloads, fn conn -> Plug.Conn.send_resp(conn, 200, body) end)
  end
end
