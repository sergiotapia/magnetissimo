defmodule Magnetissimo.Crawlers.YtsTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test, so two tests that both write cannot run at
  # the same time however long the busy timeout is.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  # Uppercase on purpose: the API sends infohashes that way and the schema only
  # accepts lowercase, so every crawler test would fail without the downcase.
  @hash_720p "0123456789ABCDEF0123456789ABCDEF01234567"
  @hash_1080p "89ABCDEF0123456789ABCDEF0123456789ABCDEF"

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
    assert first.magnet_hash == String.downcase(@hash_1080p)
    assert first.seeders == 25
    assert first.leechers == 4
    assert first.size_in_bytes == 1_621_350_154
    assert DateTime.to_unix(first.published_at) == 1_791_568_547

    assert String.starts_with?(
             first.magnet_url,
             "magnet:?xt=urn:btih:#{String.downcase(@hash_1080p)}" <>
               "&dn=Fixture+Movie+%282024%29" <>
               "&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce"
           )

    assert second.magnet_hash == String.downcase(@hash_720p)
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
              "torrents" => [%{"hash" => @hash_720p, "size_bytes" => 1_000}]
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

  defp stub_api do
    Req.Test.stub(Yts, fn conn ->
      assert conn.query_string =~ "limit=50"
      assert conn.query_string =~ "sort_by=date_added"

      Req.Test.json(conn, api_response())
    end)
  end

  # Synthetic, shaped after the real response: one movie, two quality variants,
  # uppercase infohashes, second-precision upload times.
  defp api_response do
    %{
      "status" => "ok",
      "data" => %{
        "movie_count" => 1,
        "limit" => 50,
        "page_number" => 1,
        "movies" => [
          %{
            "url" => "https://yts.test/movies/fixture-movie-2024",
            "title_long" => "Fixture Movie (2024)",
            "description_full" => "Synthetic data for the crawler test.",
            "torrents" => [
              %{
                "hash" => @hash_720p,
                "quality" => "720p",
                "size_bytes" => 874_575_299,
                "seeds" => 12,
                "peers" => 3,
                "date_uploaded_unix" => 1_791_564_238,
                "url" => "https://yts.test/torrent/download/#{@hash_720p}"
              },
              %{
                "hash" => @hash_1080p,
                "quality" => "1080p",
                "size_bytes" => 1_621_350_154,
                "seeds" => 25,
                "peers" => 4,
                "date_uploaded_unix" => 1_791_568_547,
                "url" => "https://yts.test/torrent/download/#{@hash_1080p}"
              }
            ]
          }
        ]
      }
    }
  end
end
