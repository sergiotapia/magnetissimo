defmodule Magnetissimo.Crawlers.YtsTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test, so two tests that both write cannot run at
  # the same time however long the busy timeout is.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes one torrent per quality variant, with the hashes downcased" do
    stub_api()

    assert :ok = Yts.crawl_latest()

    assert [first, second] = Torrents.list_latest_torrents()

    assert first.name == "Fixture Movie (2024)"
    assert first.category.name == "Video - Movies"
    assert first.source.name == "YTS"
    assert first.magnet_hash == String.downcase(YtsFixtures.hash_1080p())
    assert first.seeders == 25
    assert first.leechers == 4
    assert first.size_in_bytes == 1_621_350_154
    assert DateTime.to_unix(first.published_at) == 1_791_568_547

    assert String.starts_with?(
             first.magnet_url,
             "magnet:?xt=urn:btih:#{String.downcase(YtsFixtures.hash_1080p())}" <>
               "&dn=Fixture+Movie+%282024%29" <>
               "&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce"
           )

    assert second.magnet_hash == String.downcase(YtsFixtures.hash_720p())
  end

  test "crawling the same page again adds nothing" do
    stub_api()

    assert :ok = Yts.crawl_latest()
    assert :ok = Yts.crawl_latest()

    assert Torrents.count_torrents() == 2
  end

  test "an entry with no usable upload time is dropped rather than crashed on" do
    Req.Test.stub(Yts, fn conn ->
      Req.Test.json(conn, %{
        "data" => %{
          "movies" => [
            %{
              "title_long" => "Broken (2024)",
              "url" => "https://yts.test/movies/broken-2024",
              "torrents" => [%{"hash" => YtsFixtures.hash_720p(), "size_bytes" => 1_000}]
            }
          ]
        }
      })
    end)

    assert :ok = Yts.crawl_latest()
    assert Torrents.count_torrents() == 0
  end

  test "a failing API is logged, not raised" do
    Req.Test.stub(Yts, fn conn -> Plug.Conn.send_resp(conn, 503, "unavailable") end)

    log = ExUnit.CaptureLog.capture_log(fn -> assert :ok = Yts.crawl_latest() end)

    assert log =~ "crawl failed"
    assert Torrents.count_torrents() == 0
  end

  test "search indexes the API's hits and reports a movie as it lands" do
    Req.Test.stub(Yts, fn conn ->
      assert conn.query_string =~ "query_term=Fall+2+Deadpoint"
      Req.Test.json(conn, YtsFixtures.api_response())
    end)

    assert :ok = Yts.search("Fall 2 Deadpoint", notify: self())

    assert_received {:source_search, "Fall 2 Deadpoint", :updated}
    assert_received {:source_search, "Fall 2 Deadpoint", :done}

    assert [first, second] = Torrents.list_latest_torrents()
    assert first.name == "Fixture Movie (2024)"
    assert first.magnet_hash == String.downcase(YtsFixtures.hash_1080p())
    assert second.magnet_hash == String.downcase(YtsFixtures.hash_720p())
  end

  test "search reports no update for a term that is already indexed" do
    Req.Test.stub(Yts, fn conn -> Req.Test.json(conn, YtsFixtures.api_response()) end)

    assert :ok = Yts.search("Fixture Movie", notify: self())
    assert_received {:source_search, _, :updated}
    assert_received {:source_search, _, :done}

    assert :ok = Yts.search("Fixture Movie", notify: self())

    refute_received {:source_search, _, :updated}
    assert_received {:source_search, _, :done}
  end

  test "a search that fails still reports done, so no caller waits forever" do
    Req.Test.stub(Yts, fn conn -> Plug.Conn.send_resp(conn, 500, "nope") end)

    assert :ok = Yts.search("Fall 2 Deadpoint", notify: self())

    refute_received {:source_search, _, :updated}
    assert_received {:source_search, "Fall 2 Deadpoint", :done}
  end

  defp stub_api do
    Req.Test.stub(Yts, fn conn ->
      assert conn.query_string =~ "limit=50"
      assert conn.query_string =~ "sort_by=date_added"

      Req.Test.json(conn, YtsFixtures.api_response())
    end)
  end
end
