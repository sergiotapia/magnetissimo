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

  test "indexes each book in the results from its own page" do
    serve(%{
      "/" => AudioBookBayFixtures.search_body(),
      @mila => AudioBookBayFixtures.chasing_mila_body(),
      @king => AudioBookBayFixtures.king_zero_body()
    })

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(AudioBookBay, "Fixture Book")
    assert_received {:asked, "/", %{"s" => "Fixture Book"}}

    assert [mila, king] = Torrents.list_latest_torrents()

    assert mila.name == "Chasing Mila - Charlotte Engel"
    assert mila.source.name == "AudioBookBay"
    assert mila.canonical_url == "https://audiobookbay.lu" <> @mila
    assert mila.magnet_hash == String.downcase(AudioBookBayFixtures.hash_upper())
    assert Taxonomy.fetch!(mila.category_id).name == "Audio/Audiobook"
    assert mila.size_in_bytes == round(686.36 * 1024 ** 2)
    assert mila.seeders == 0
    # The results say the day it was posted and no time.
    assert DateTime.to_unix(mila.published_at) == DateTime.to_unix(~U[2026-10-08 00:00:00Z])

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
    assert DateTime.to_unix(king.published_at) == DateTime.to_unix(~U[2024-01-30 00:00:00Z])
  end

  test "a book already indexed is still a hit for the term, without fetching its page" do
    serve(%{
      "/" => AudioBookBayFixtures.search_body(),
      @mila => AudioBookBayFixtures.chasing_mila_body(),
      @king => AudioBookBayFixtures.king_zero_body()
    })

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(AudioBookBay, "Fixture Book")
    assert_asked(["/", @king, @mila])

    assert {:ok, %{inserted: 0, found: 2}} = Crawlers.search(AudioBookBay, "Other Words")
    assert_asked(["/"])

    assert [_, _] = Torrents.search_torrents("Other Words")
  end

  test "a search fetches pages for only its top five new results" do
    new_books = for n <- 1..7, do: "/abss/book-#{n}/"

    serve(%{
      "/" => AudioBookBayFixtures.search_body(new_books ++ [@mila, @king]),
      @mila => AudioBookBayFixtures.chasing_mila_body(),
      @king => AudioBookBayFixtures.king_zero_body()
    })

    %{ids: [_, _]} =
      Torrents.index_torrents([indexed_attrs(@mila, "a"), indexed_attrs(@king, "b")])

    # The new books' pages are missing, so they are skipped; what matters is
    # which were asked for. The two already indexed, ranked last, still count.
    ExUnit.CaptureLog.capture_log(fn ->
      assert {:ok, %{found: 2}} = Crawlers.search(AudioBookBay, "Fixture Book")
    end)

    assert_asked(["/" | Enum.take(new_books, 5)])
  end

  test "a page with no infohash, or one that fails, costs only that book" do
    serve(%{
      "/" => AudioBookBayFixtures.search_body(),
      @mila => AudioBookBayFixtures.no_hash_body(),
      @king => 500
    })

    log =
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:ok, %{found: 0}} = Crawlers.search(AudioBookBay, "Fixture Book")
      end)

    assert log =~ "skipped https://audiobookbay.lu#{@mila}: :no_infohash_or_size"
    assert log =~ "skipped https://audiobookbay.lu#{@king}: {:http_status, 500}"
    assert Torrents.count_torrents() == 0
  end

  test "a search that matches nothing finds nothing" do
    serve(%{"/" => AudioBookBayFixtures.empty_search_body()})

    assert {:ok, %{inserted: 0, found: 0}} = Crawlers.search(AudioBookBay, "Nothing")
  end

  test "a search that fails says why" do
    serve(%{"/" => 500})

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, {:http_status, 500}} = Crawlers.search(AudioBookBay, "Anything")
    end)
  end

  # A torrent as an earlier search would have indexed it from `path`.
  defp indexed_attrs(path, hash_char) do
    hash = String.duplicate(hash_char, 40)

    %{
      name: path,
      canonical_url: "https://audiobookbay.lu" <> path,
      published_at: DateTime.utc_now(),
      size_in_bytes: 1_000,
      magnet_hash: hash,
      magnet_url: "magnet:?xt=urn:btih:" <> hash,
      category_id: Taxonomy.id!("Audio/Audiobook"),
      source_id: Torrents.get_source_by_name!("AudioBookBay").id
    }
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
