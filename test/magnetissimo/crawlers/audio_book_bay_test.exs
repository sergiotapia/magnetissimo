defmodule Magnetissimo.Crawlers.AudioBookBayTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.AudioBookBayFixtures
  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.AudioBookBay
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures
  alias Plug.Conn

  @mila "/abss/chasing-mila-charlotte-engel/"
  @king "/abss/king-zero-charlie-higson/"

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes each book in the feed from its own page" do
    serve(%{
      "/feed/" => AudioBookBayFixtures.feed_body(),
      @mila => AudioBookBayFixtures.chasing_mila_body(),
      @king => AudioBookBayFixtures.king_zero_body()
    })

    assert :ok = Crawlers.crawl_latest(AudioBookBay)

    assert [mila, king] = Torrents.list_latest_torrents()

    assert mila.name == "Chasing Mila - Charlotte Engel"
    assert mila.source.name == "AudioBookBay"
    assert mila.canonical_url == "https://audiobookbay.lu" <> @mila
    assert mila.magnet_hash == String.downcase(AudioBookBayFixtures.hash_upper())
    assert Taxonomy.fetch!(mila.category_id).name == "Audio/Audiobook"
    assert mila.size_in_bytes == round(686.36 * 1024 ** 2)
    assert mila.seeders == 0
    # 04:11:21 +0200 is 02:11:21 UTC.
    assert DateTime.to_unix(mila.published_at) == DateTime.to_unix(~U[2026-10-10 02:11:21Z])

    assert mila.description ==
             "Written by Charlotte Engel · Read by Lizzie Munro · M4B · 128 Kbps · " <>
               "Unabridged · Adults, Crime"

    # The page's own trackers, announce URL first and listed once.
    assert mila.magnet_url ==
             "magnet:?xt=urn:btih:#{mila.magnet_hash}&dn=Chasing+Mila+-+Charlotte+Engel" <>
               "&tr=http%3A%2F%2Ftracker2.dler.org%3A80%2Fannounce" <>
               "&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce"

    assert king.name == "King Zero: Bond’s Return & More - Charlie Higson"
    assert king.size_in_bytes == round(1.25 * 1024 ** 3)
  end

  test "a page already indexed is not fetched again" do
    serve(%{
      "/feed/" => AudioBookBayFixtures.feed_body(),
      @mila => AudioBookBayFixtures.chasing_mila_body(),
      @king => AudioBookBayFixtures.king_zero_body()
    })

    assert :ok = Crawlers.crawl_latest(AudioBookBay)
    assert_asked(["/feed/", @king, @mila])

    assert :ok = Crawlers.crawl_latest(AudioBookBay)
    assert_asked(["/feed/"])

    assert Torrents.count_torrents() == 2
  end

  test "search stamps a hit with the day it was posted" do
    serve(%{
      "/" => AudioBookBayFixtures.search_body(),
      @mila => AudioBookBayFixtures.chasing_mila_body(),
      @king => AudioBookBayFixtures.king_zero_body()
    })

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(AudioBookBay, "Fixture Book")
    assert_received {:asked, "/", %{"s" => "Fixture Book"}}

    assert [mila, king] = Torrents.list_latest_torrents()
    assert DateTime.to_unix(mila.published_at) == DateTime.to_unix(~U[2026-10-08 00:00:00Z])
    assert DateTime.to_unix(king.published_at) == DateTime.to_unix(~U[2024-01-30 00:00:00Z])
  end

  test "a book already indexed is still a hit for the term, without fetching its page" do
    serve(%{
      "/feed/" => AudioBookBayFixtures.feed_body(),
      "/" => AudioBookBayFixtures.search_body(),
      @mila => AudioBookBayFixtures.chasing_mila_body(),
      @king => AudioBookBayFixtures.king_zero_body()
    })

    assert :ok = Crawlers.crawl_latest(AudioBookBay)
    assert_asked(["/feed/", @king, @mila])

    assert {:ok, %{inserted: 0, found: 2}} = Crawlers.search(AudioBookBay, "Fixture Book")
    assert_asked(["/"])

    assert [_, _] = Torrents.search_torrents("Fixture Book")
  end

  test "a page with no infohash, or one that fails, costs only that book" do
    serve(%{
      "/feed/" => AudioBookBayFixtures.feed_body(),
      @mila => AudioBookBayFixtures.no_hash_body(),
      @king => 500
    })

    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert :ok = Crawlers.crawl_latest(AudioBookBay)
      end)

    assert log =~ "skipped https://audiobookbay.lu#{@mila}: :no_infohash_or_size"
    assert log =~ "skipped https://audiobookbay.lu#{@king}: {:http_status, 500}"
    assert Torrents.count_torrents() == 0
  end

  test "a search that matches nothing finds nothing" do
    serve(%{"/" => AudioBookBayFixtures.empty_search_body()})

    assert {:ok, %{inserted: 0, found: 0}} = Crawlers.search(AudioBookBay, "Nothing")
  end

  test "a failing feed is logged, not raised" do
    serve(%{"/feed/" => 503})

    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert :ok = Crawlers.crawl_latest(AudioBookBay)
      end)

    assert log =~ "crawl failed"
    assert Torrents.count_torrents() == 0
  end

  test "a search that fails says why" do
    serve(%{"/" => 500})

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, {:http_status, 500}} = Crawlers.search(AudioBookBay, "Anything")
    end)
  end

  # Answers each path with its body, or with its status for an integer, and
  # tells the test every request it was sent.
  defp serve(pages) do
    test = self()

    Req.Test.stub(AudioBookBay, fn conn ->
      conn = Conn.fetch_query_params(conn)
      send(test, {:asked, conn.request_path, conn.query_params})

      case Map.get(pages, conn.request_path, 404) do
        status when is_integer(status) -> Conn.send_resp(conn, status, "")
        body -> Conn.send_resp(conn, 200, body)
      end
    end)
  end

  # The pages are fetched concurrently, so the order they arrive in is not
  # fixed.
  defp assert_asked(paths) do
    asked =
      for _ <- paths do
        assert_received {:asked, path, _params}
        path
      end

    assert Enum.sort(asked) == Enum.sort(paths)
    refute_received {:asked, _path, _params}
  end
end
