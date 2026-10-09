defmodule Magnetissimo.YtsFixtures do
  @moduledoc """
  Synthetic YTS API payloads for tests.

  Shaped after the real responses, with no real data in them. Two details are
  load-bearing: the infohashes are uppercase, because the API sends them that
  way and the schema only accepts lowercase, and upload times are
  second-precision unix integers, which is the only upload field that is the
  same on every mirror.
  """

  @hash_720p "0123456789ABCDEF0123456789ABCDEF01234567"
  @hash_1080p "89ABCDEF0123456789ABCDEF0123456789ABCDEF"

  def hash_720p, do: @hash_720p
  def hash_1080p, do: @hash_1080p

  @doc "An envelope carrying one movie with two quality variants."
  def api_response do
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

  @doc "An envelope the API sends when a term matched nothing."
  def empty_response, do: %{"status" => "ok", "data" => %{"movies" => []}}
end
