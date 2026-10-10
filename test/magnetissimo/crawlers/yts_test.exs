defmodule Magnetissimo.Crawlers.YtsTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test, so two tests that both write cannot run at
  # the same time however long the busy timeout is.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures
  alias Req.Test

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "indexes one torrent per quality variant, with the hashes downcased" do
    stub_api()

    assert {:ok, %{inserted: 2}} = Crawlers.search(Yts, "Fixture Movie")

    assert [first, second] = Torrents.list_latest_torrents()

    assert first.name == "Fixture Movie (2024)"
    assert Taxonomy.fetch!(first.category_id).name == "Movies/HD"
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

  test "an entry with no usable upload time is dropped rather than crashed on" do
    Test.stub(Yts, fn conn ->
      Test.json(conn, %{
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

    assert {:ok, %{found: 0}} = Crawlers.search(Yts, "Broken")
    assert Torrents.count_torrents() == 0
  end

  test "search indexes the API's hits and makes them findable by the term" do
    Test.stub(Yts, fn conn ->
      assert conn.query_string =~ "query_term=Fall+2+Deadpoint"
      Test.json(conn, YtsFixtures.api_response())
    end)

    assert {:ok, %{inserted: 2, found: 2}} = Crawlers.search(Yts, "Fall 2 Deadpoint")

    assert [first, second] = Torrents.list_latest_torrents()
    assert first.name == "Fixture Movie (2024)"
    assert first.magnet_hash == String.downcase(YtsFixtures.hash_1080p())
    assert second.magnet_hash == String.downcase(YtsFixtures.hash_720p())

    assert Torrents.count_search_torrents("fall 2 deadpoint") == 2
  end

  test "search refreshes the swarm of a torrent already indexed" do
    Test.stub(Yts, fn conn -> Test.json(conn, YtsFixtures.api_response()) end)
    assert {:ok, %{inserted: 2}} = Crawlers.search(Yts, "Fixture Movie")

    fresher =
      update_in(YtsFixtures.api_response(), ["data", "movies", Access.all(), "torrents"], fn ts ->
        Enum.map(ts, &Map.merge(&1, %{"seeds" => 999, "peers" => 7}))
      end)

    Test.stub(Yts, fn conn -> Test.json(conn, fresher) end)
    assert {:ok, %{inserted: 0, found: 2}} = Crawlers.search(Yts, "Fixture Movie")

    assert Enum.map(Torrents.list_latest_torrents(), &{&1.seeders, &1.leechers}) ==
             [{999, 7}, {999, 7}]
  end

  test "a torrent filed under Other takes the category a later source knows" do
    other = Taxonomy.other_id()
    stub_api()
    {:ok, [attrs | _]} = Yts.search("Fixture Movie")

    # As TorrentDownloads' search would file it, with no category to go on.
    %{ids: [id]} = Torrents.index_torrents([%{attrs | category_id: other}])
    assert Torrents.get_torrent!(id).category_id == other

    %{ids: [^id]} = Torrents.index_torrents([attrs])
    assert Torrents.get_torrent!(id).category_id == Taxonomy.id!("Movies/HD")

    # A real category is never overwritten, by Other or by anything else.
    %{ids: [^id]} = Torrents.index_torrents([%{attrs | category_id: other}])
    assert Torrents.get_torrent!(id).category_id == Taxonomy.id!("Movies/HD")
  end

  test "a search that fails says why" do
    Test.stub(Yts, fn conn -> Plug.Conn.send_resp(conn, 500, "nope") end)

    ExUnit.CaptureLog.capture_log(fn ->
      assert {:error, _reason} = Crawlers.search(Yts, "Fall 2 Deadpoint")
    end)
  end

  test "a search with no matches is an empty answer, not a failure" do
    Test.stub(Yts, fn conn -> Test.json(conn, YtsFixtures.empty_response()) end)

    assert {:ok, %{inserted: 0, found: 0}} = Crawlers.search(Yts, "xqzvbnm")
  end

  defp stub_api do
    Test.stub(Yts, fn conn ->
      assert conn.query_string =~ "limit=50"

      Test.json(conn, YtsFixtures.api_response())
    end)
  end
end
