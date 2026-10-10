defmodule Magnetissimo.Crawlers.EztvTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.Eztv
  alias Magnetissimo.EztvFixtures
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures
  alias Req.Test

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  # Answers IMDb with `suggestions` and EZTV with `pages`, keyed by IMDb id,
  # and tells the test every request it saw.
  defp stub(suggestions, pages) do
    test = self()

    Test.stub(Eztv, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      send(test, {:request, conn.host, conn.request_path, conn.query_params})

      case conn.host do
        "v3.sg.media-imdb.com" ->
          Test.json(conn, suggestions)

        "eztvx.to" ->
          %{"imdb_id" => imdb_id} = conn.query_params
          Test.json(conn, Map.get(pages, imdb_id, EztvFixtures.empty_page(imdb_id)))
      end
    end)
  end

  test "finds the term's shows on IMDb and indexes their torrents" do
    stub(EztvFixtures.suggestions(), %{
      EztvFixtures.show_id() => EztvFixtures.show_page(),
      EztvFixtures.spinoff_id() => EztvFixtures.spinoff_page()
    })

    assert {:ok, %{inserted: 4, found: 4}} = Crawlers.search(Eztv, "Fixture")

    assert_received {:request, "v3.sg.media-imdb.com", "/suggestion/x/fixture.json", _}

    show_id = EztvFixtures.show_id()
    spinoff_id = EztvFixtures.spinoff_id()

    assert_received {:request, "eztvx.to", "/api/get-torrents",
                     %{"imdb_id" => ^show_id, "limit" => "100", "page" => "1"}}

    assert_received {:request, "eztvx.to", "/api/get-torrents", %{"imdb_id" => ^spinoff_id}}
    # The movie IMDb suggested is not a show, so EZTV is not asked about it.
    refute_received {:request, "eztvx.to", _, _}

    torrents = Map.new(Torrents.list_latest_torrents(), &{&1.magnet_hash, &1})
    episode = torrents[EztvFixtures.hash_hd()]

    assert episode.name == "Fixture Show S02E01 720p WEB H264-FIX"
    assert episode.source.name == "EZTV"

    assert episode.canonical_url ==
             "https://eztvx.to/ep/2001/fixture-show-s02e01-720p-web-h264-fix/"

    assert episode.seeders == 25
    assert episode.leechers == 4
    assert episode.size_in_bytes == 1_080_141_019
    assert DateTime.to_unix(episode.published_at) == 1_791_602_777

    assert String.starts_with?(
             episode.magnet_url,
             "magnet:?xt=urn:btih:#{EztvFixtures.hash_hd()}" <>
               "&dn=Fixture+Show+S02E01+720p+WEB+H264-FIX" <>
               "&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce"
           )

    category = &Taxonomy.fetch!(torrents[&1].category_id).name
    assert category.(EztvFixtures.hash_hd()) == "TV/HD"
    assert category.(EztvFixtures.hash_sd()) == "TV/SD"
    assert category.(EztvFixtures.hash_uhd()) == "TV/UHD"
    assert category.(EztvFixtures.hash_spinoff()) == "TV"
  end

  test "an episode search asks IMDb for the show and keeps only that episode" do
    stub(EztvFixtures.suggestions(), %{EztvFixtures.show_id() => EztvFixtures.show_page()})

    assert {:ok, %{found: 1}} = Crawlers.search(Eztv, "Fixture Show S02E01 720p")

    assert_received {:request, "v3.sg.media-imdb.com", "/suggestion/x/fixture%20show.json", _}
    assert [only] = Torrents.list_latest_torrents()
    assert only.magnet_hash == EztvFixtures.hash_hd()
  end

  test "a show's torrents are read a few pages deep, newest first" do
    stub(%{"d" => [hd(EztvFixtures.suggestions()["d"])]}, %{
      EztvFixtures.show_id() => EztvFixtures.show_page(count: 250)
    })

    assert {:ok, _} = Crawlers.search(Eztv, "Fixture")
    assert pages_asked() == ["1", "2", "3"]

    stub(%{"d" => [hd(EztvFixtures.suggestions()["d"])]}, %{
      EztvFixtures.show_id() => EztvFixtures.show_page(count: 2439)
    })

    assert {:ok, _} = Crawlers.search(Eztv, "Fixture")
    assert pages_asked() == ["1", "2", "3", "4", "5"]
  end

  test "a term IMDb suggests no show for is an empty answer, without asking EZTV" do
    stub(EztvFixtures.no_suggestions(), %{})

    assert {:ok, %{inserted: 0, found: 0}} = Crawlers.search(Eztv, "xqzvbnm")
    refute_received {:request, "eztvx.to", _, _}
  end

  test "a show EZTV has no torrents for is an empty answer" do
    stub(EztvFixtures.suggestions(), %{})

    assert {:ok, %{found: 0}} = Crawlers.search(Eztv, "Fixture")
    assert Torrents.count_torrents() == 0
  end

  test "a term that is only an episode number asks nobody" do
    stub(EztvFixtures.suggestions(), %{})

    assert {:ok, %{found: 0}} = Crawlers.search(Eztv, "S01E01 1080p")
    refute_received {:request, _, _, _}
  end

  test "a torrent with no usable upload time is dropped rather than crashed on" do
    page = EztvFixtures.show_page()
    [first | rest] = page["torrents"]
    page = %{page | "torrents" => [Map.delete(first, "date_released_unix") | rest]}

    stub(EztvFixtures.suggestions(), %{EztvFixtures.show_id() => page})

    assert {:ok, %{found: 2}} = Crawlers.search(Eztv, "Fixture")
  end

  test "EZTV failing says why the search failed" do
    Test.stub(Eztv, fn conn ->
      case conn.host do
        "v3.sg.media-imdb.com" -> Test.json(conn, EztvFixtures.suggestions())
        "eztvx.to" -> Plug.Conn.send_resp(conn, 503, "Service Unavailable")
      end
    end)

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, {:http_status, 503}} = Crawlers.search(Eztv, "Fixture")
    end)
  end

  test "an IMDb answer that is not suggestions is a failure" do
    Test.stub(Eztv, &Test.json(&1, ["nope"]))

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, :unexpected_response} = Crawlers.search(Eztv, "Fixture")
    end)
  end

  defp pages_asked do
    receive do
      {:request, "eztvx.to", _, %{"page" => page}} -> [page | pages_asked()]
      {:request, _, _, _} -> pages_asked()
    after
      0 -> []
    end
  end
end
