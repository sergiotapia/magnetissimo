defmodule Magnetissimo.Crawlers.TorrentDownloadsTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.TorrentDownloadsFixtures
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes every item, converting the offset to UTC and downcasing the hash" do
    # Every category's answer carries the same two items, which index once.
    Req.Test.stub(TorrentDownloads, fn conn ->
      assert %{"type" => "search"} = Plug.Conn.fetch_query_params(conn).query_params
      Plug.Conn.send_resp(conn, 200, TorrentDownloadsFixtures.rss_body())
    end)

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(TorrentDownloads, "Fixture")

    assert [newest, older] = Torrents.list_latest_torrents()

    assert newest.name == "Kill Jackie S01 2160p WEBRip HDR x265-KONTRAST"
    assert category(newest) == "TV"
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
    assert category(older) == "Audio"
  end

  test "entities in a title are decoded once" do
    body =
      String.replace(
        TorrentDownloadsFixtures.rss_body(),
        "L’Officina della Camomilla",
        "Fire &amp; Ice &amp;lt;3 &#233;"
      )

    stub(body)
    assert {:ok, %{inserted: 2}} = Crawlers.search(TorrentDownloads, "Fixture")

    assert [_newest, older] = Torrents.list_latest_torrents()
    assert older.name == "Fire & Ice &lt;3 é - VM 18 [FLAC 24-44]"
  end

  test "an item with no usable date is skipped, not crashed on" do
    stub(TorrentDownloadsFixtures.malformed_rss_body())

    assert {:ok, %{found: 0}} = Crawlers.search(TorrentDownloads, "Fixture")
    assert Torrents.count_torrents() == 0
  end

  test "search asks once per category, and a hit keeps its categorised copy" do
    test = self()

    Req.Test.stub(TorrentDownloads, fn conn ->
      params = Plug.Conn.fetch_query_params(conn).query_params
      assert %{"type" => "search", "search" => "Fixture Search"} = params
      send(test, {:asked, params["cid"]})

      # The unnarrowed search leaves the hit's category out; the one narrowed
      # to Software names it.
      body =
        case params["cid"] do
          nil -> TorrentDownloadsFixtures.search_rss_body()
          "7" -> categorised(TorrentDownloadsFixtures.search_rss_body(), "Software")
          _other -> "<rss><channel></channel></rss>"
        end

      Plug.Conn.send_resp(conn, 200, body)
    end)

    assert {:ok, %{inserted: 1, found: 1}} = Crawlers.search(TorrentDownloads, "Fixture Search")

    assert [torrent] = Torrents.list_latest_torrents()
    assert category(torrent) == "PC"

    # Every category on the site's menu, and the unnarrowed search ("").
    asked =
      for _ <- 1..9 do
        assert_received {:asked, cid}
        to_string(cid)
      end

    assert Enum.sort(asked) == ["", "1", "2", "3", "4", "5", "7", "8", "9"]
  end

  test "a hit a narrowed search leaves blank takes the category it was narrowed to" do
    Req.Test.stub(TorrentDownloads, fn conn ->
      body =
        case Plug.Conn.fetch_query_params(conn).query_params["cid"] do
          "3" -> TorrentDownloadsFixtures.search_rss_body()
          _other -> "<rss><channel></channel></rss>"
        end

      Plug.Conn.send_resp(conn, 200, body)
    end)

    assert {:ok, %{found: 1}} = Crawlers.search(TorrentDownloads, "Fixture Search")
    assert [torrent] = Torrents.list_latest_torrents()
    assert category(torrent) == "PC/Games"
  end

  test "a search the feed answers only in part still answers, and says so" do
    Req.Test.stub(TorrentDownloads, fn conn ->
      case Plug.Conn.fetch_query_params(conn).query_params["cid"] do
        "3" -> Plug.Conn.send_resp(conn, 500, "nope")
        nil -> Plug.Conn.send_resp(conn, 200, TorrentDownloadsFixtures.search_rss_body())
        _other -> Plug.Conn.send_resp(conn, 200, "<rss><channel></channel></rss>")
      end
    end)

    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:ok, %{found: 1}} = Crawlers.search(TorrentDownloads, "Fixture Search")
      end)

    assert log =~ "partly failed"
    assert [torrent] = Torrents.list_latest_torrents()
    assert category(torrent) == "Other"
  end

  test "a swarm the feed does not know is indexed as none, not as the biggest" do
    body =
      String.replace(
        TorrentDownloadsFixtures.rss_body(),
        "<seeders>6</seeders>",
        "<seeders>16777215</seeders>"
      )

    stub(body)
    assert {:ok, %{inserted: 2}} = Crawlers.search(TorrentDownloads, "Fixture")

    assert [newest, _older] = Torrents.list_latest_torrents()
    assert newest.seeders == 0
  end

  test "a search that fails says why" do
    Req.Test.stub(TorrentDownloads, fn conn -> Plug.Conn.send_resp(conn, 500, "nope") end)

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, {:http_status, 500}} = Crawlers.search(TorrentDownloads, "Anything")
    end)
  end

  defp category(torrent), do: Taxonomy.fetch!(torrent.category_id).name

  defp categorised(body, category) do
    String.replace(
      body,
      "<category><![CDATA[]]></category>",
      "<category><![CDATA[#{category}]]></category>"
    )
  end

  defp stub(body) do
    Req.Test.stub(TorrentDownloads, fn conn -> Plug.Conn.send_resp(conn, 200, body) end)
  end
end
