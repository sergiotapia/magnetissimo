defmodule Magnetissimo.Crawlers.ThePirateBayTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.ThePirateBay
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.ThePirateBayFixtures
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes every hit, with the hash downcased and the name unescaped" do
    Req.Test.stub(ThePirateBay, fn conn ->
      assert conn.request_path == "/q.php"

      assert %{"q" => "Fixture", "cat" => ""} =
               Plug.Conn.fetch_query_params(conn).query_params

      Req.Test.json(conn, ThePirateBayFixtures.api_response())
    end)

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(ThePirateBay, "Fixture")
    assert Torrents.count_search_torrents("fixture") == 2

    assert [film, book] = Torrents.list_latest_torrents()

    assert film.name == "Fixture Movie 2024 1080p WEB-DL"
    assert film.source.name == "The Pirate Bay"
    assert film.canonical_url == "https://thepiratebay.org/description.php?id=1001"
    assert Taxonomy.fetch!(film.category_id).name == "Movies/HD"
    assert film.magnet_hash == String.downcase(ThePirateBayFixtures.hash_hd())
    assert film.seeders == 25
    assert film.leechers == 4
    assert film.size_in_bytes == 1_621_350_154
    assert DateTime.to_unix(film.published_at) == 1_791_568_547

    assert String.starts_with?(
             film.magnet_url,
             "magnet:?xt=urn:btih:#{String.downcase(ThePirateBayFixtures.hash_hd())}" <>
               "&dn=Fixture+Movie+2024+1080p+WEB-DL" <>
               "&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce"
           )

    assert book.name == "Fixtures & Factories, 2nd Edition"
    assert Taxonomy.fetch!(book.category_id).name == "Books/EBook"
  end

  test "a search with no matches is an empty answer, not a placeholder torrent" do
    Req.Test.stub(ThePirateBay, &Req.Test.json(&1, ThePirateBayFixtures.empty_response()))

    assert {:ok, %{inserted: 0, found: 0}} = Crawlers.search(ThePirateBay, "xqzvbnm")
    assert Torrents.count_torrents() == 0
  end

  test "a hit with no usable upload time is dropped rather than crashed on" do
    [film, book] = ThePirateBayFixtures.api_response()
    broken = Map.delete(film, "added")

    Req.Test.stub(ThePirateBay, &Req.Test.json(&1, [broken, book]))

    assert {:ok, %{found: 1}} = Crawlers.search(ThePirateBay, "Fixture")
    assert [only] = Torrents.list_latest_torrents()
    assert only.magnet_hash == String.downcase(ThePirateBayFixtures.hash_book())
  end

  test "a rate limit says why the search failed" do
    Req.Test.stub(ThePirateBay, &Plug.Conn.send_resp(&1, 429, "Too Many Requests"))

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, {:http_status, 429}} = Crawlers.search(ThePirateBay, "Fixture")
    end)
  end

  test "an answer that is not a list of torrents is a failure" do
    Req.Test.stub(ThePirateBay, &Req.Test.json(&1, %{"error" => "nope"}))

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, :unexpected_response} = Crawlers.search(ThePirateBay, "Fixture")
    end)
  end
end
