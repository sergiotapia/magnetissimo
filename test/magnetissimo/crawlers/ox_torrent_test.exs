defmodule Magnetissimo.Crawlers.OxTorrentTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.OxTorrent
  alias Magnetissimo.OxTorrentFixtures
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures
  alias Plug.Conn

  @search "/recherche/Fixture%20Release"
  @cabin "/detail/77524"
  @magazine "/detail/1234"

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes each release in the results from its own page" do
    serve(%{
      @search => OxTorrentFixtures.search_body(),
      @cabin => OxTorrentFixtures.cabin_body(),
      @magazine => OxTorrentFixtures.magazine_body()
    })

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(OxTorrent, "Fixture Release")
    # The cover strip's release is not a hit, and its page is never asked for.
    assert_asked([@search, @cabin, @magazine])

    assert [magazine, cabin] = Torrents.list_latest_torrents()

    assert cabin.name == "The.Woman.in.Cabin.10.2025.MULTi.2160p.WEB.H265-FW"
    assert cabin.source.name == "OxTorrent"
    assert cabin.canonical_url == "https://ww1.oxtorrent.run" <> @cabin
    assert cabin.magnet_hash == String.downcase(OxTorrentFixtures.hash_upper())
    assert Taxonomy.fetch!(cabin.category_id).name == "Movies"
    assert cabin.size_in_bytes == round(8.42 * 1024 ** 3)
    assert cabin.seeders == 16
    assert cabin.leechers == 5
    # The page says the day, day first, and no time.
    assert DateTime.to_unix(cabin.published_at) == DateTime.to_unix(~U[2025-10-26 00:00:00Z])

    assert cabin.description ==
             "La Disparue de la cabine 10 - The Woman In Cabin 10 MULTI 4K 2025 · Policier, Thriller"

    # The page's own trackers, each listed once.
    assert cabin.magnet_url ==
             "magnet:?xt=urn:btih:#{cabin.magnet_hash}" <>
               "&dn=The.Woman.in.Cabin.10.2025.MULTi.2160p.WEB.H265-FW" <>
               "&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce" <>
               "&tr=http%3A%2F%2Fatrack.pow7.com%2Fannounce"

    assert magazine.name == "Windows.&.Internet.Pratique.N.170.pdf"
    assert Taxonomy.fetch!(magazine.category_id).name == "Books/EBook"
    assert magazine.size_in_bytes == round(575.59 * 1024 ** 2)
  end

  test "a release already indexed is still a hit, with today's swarm, without fetching its page" do
    serve(%{
      @search => OxTorrentFixtures.search_body(),
      @cabin => OxTorrentFixtures.cabin_body(),
      @magazine => OxTorrentFixtures.magazine_body()
    })

    stored = indexed(@cabin)

    assert {:ok, %{inserted: 1, found: 2}} = Crawlers.search(OxTorrent, "Fixture Release")
    assert_asked([@search, @magazine])

    cabin = Torrents.get_torrent!(stored.id)
    assert cabin.name == @cabin
    assert cabin.seeders == 16
    assert cabin.leechers == 5
  end

  test "a search fetches pages for only its top fifteen new results" do
    new_releases = for n <- 1..17, do: "/detail/#{n}"

    serve(%{@search => OxTorrentFixtures.search_body(Enum.concat(new_releases, [@cabin]))})
    indexed(@cabin)

    # The new releases' pages are missing, so they are skipped; what matters
    # is which were asked for. The one already indexed, ranked last, still
    # counts.
    ExUnit.CaptureLog.capture_log(fn ->
      assert {:ok, %{found: 1}} = Crawlers.search(OxTorrent, "Fixture Release")
    end)

    assert_asked([@search | Enum.take(new_releases, 15)])
  end

  test "a page with no infohash, or one that fails, costs only that release" do
    serve(%{
      @search => OxTorrentFixtures.search_body(),
      @cabin => OxTorrentFixtures.no_hash_body(),
      @magazine => 500
    })

    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:ok, %{found: 0}} = Crawlers.search(OxTorrent, "Fixture Release")
      end)

    assert log =~ "skipped https://ww1.oxtorrent.run#{@cabin}: :no_infohash_or_date"
    assert log =~ "skipped https://ww1.oxtorrent.run#{@magazine}: {:http_status, 500}"
    assert Torrents.count_torrents() == 0
  end

  test "a search that matches nothing finds nothing" do
    serve(%{@search => OxTorrentFixtures.empty_search_body()})

    assert {:ok, %{inserted: 0, found: 0}} = Crawlers.search(OxTorrent, "Fixture Release")
    assert_asked([@search])
  end

  test "a search that fails says why" do
    serve(%{@search => 500})

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, {:http_status, 500}} = Crawlers.search(OxTorrent, "Fixture Release")
    end)
  end

  # A torrent as an earlier search would have indexed it from `path`, with
  # no swarm.
  defp indexed(path) do
    TorrentsFixtures.torrent_fixture(
      name: path,
      canonical_url: "https://ww1.oxtorrent.run" <> path,
      source: "OxTorrent",
      seeders: 0,
      leechers: 0
    )
  end

  # Answers each path with its body, or with its status for an integer, and
  # tells the test every path it was asked for, still percent-encoded.
  defp serve(pages) do
    test = self()

    Req.Test.stub(OxTorrent, fn conn ->
      send(test, {:asked, conn.request_path})

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
        assert_received {:asked, path}
        path
      end

    assert Enum.sort(asked) == Enum.sort(paths)
    refute_received {:asked, _path}
  end
end
