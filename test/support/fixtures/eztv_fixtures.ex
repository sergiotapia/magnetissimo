defmodule Magnetissimo.EztvFixtures do
  @moduledoc """
  Synthetic IMDb suggestion and EZTV API answers for tests.

  Shaped after the real responses, with no real data in them. Details that
  are load-bearing: IMDb ids carry a `tt` prefix that EZTV's API does not
  take; IMDb suggests movies and people alongside shows; EZTV sends the size
  as a string but the swarm and upload time as integers, and ends every title
  with " EZTV"; and an id with no torrents comes back with no `torrents` key.
  """

  @show_id "1000001"
  @spinoff_id "1000002"

  @hash_hd "0123456789abcdef0123456789abcdef01234567"
  @hash_sd "89abcdef0123456789abcdef0123456789abcdef"
  @hash_uhd "fedcba9876543210fedcba9876543210fedcba98"
  @hash_spinoff "00112233445566778899aabbccddeeff00112233"

  def show_id, do: @show_id
  def spinoff_id, do: @spinoff_id
  def hash_hd, do: @hash_hd
  def hash_sd, do: @hash_sd
  def hash_uhd, do: @hash_uhd
  def hash_spinoff, do: @hash_spinoff

  @doc "IMDb's suggestions for \"fixture\": two shows, a movie and a person."
  def suggestions do
    %{
      "d" => [
        %{"id" => "tt#{@show_id}", "qid" => "tvSeries", "l" => "Fixture Show", "y" => 2020},
        %{"id" => "tt9000001", "qid" => "movie", "l" => "Fixture: The Movie", "y" => 2022},
        %{"id" => "nm0000001", "l" => "Fixture Person"},
        %{"id" => "tt#{@spinoff_id}", "qid" => "tvMiniSeries", "l" => "Fixture Spinoff"}
      ],
      "q" => "fixture",
      "v" => 1
    }
  end

  @doc "What IMDb sends for a query it has nothing for."
  def no_suggestions, do: %{"q" => "xqzvbnm", "v" => 1}

  @doc "The show's torrents, newest first: an HD, an SD and a UHD episode."
  def show_page(opts \\ []) do
    rows = [
      row(2001, "Fixture Show S02E01 720p WEB H264-FIX EZTV", @hash_hd,
        swarm: {25, 4},
        size: "1080141019",
        released: 1_791_602_777
      ),
      row(2002, "Fixture Show S01E09 480p x264-FIX EZTV", @hash_sd,
        swarm: {7, 1},
        size: "220000000",
        released: 1_791_500_000
      ),
      row(2003, "Fixture Show S01E08 2160p WEB H265-FIX EZTV", @hash_uhd,
        swarm: {3, 0},
        size: "4500000000",
        released: 1_791_400_000
      )
    ]

    page(@show_id, Keyword.get(opts, :count, length(rows)), rows)
  end

  @doc "The spinoff's one torrent, with no resolution in its name."
  def spinoff_page do
    page(@spinoff_id, 1, [
      row(3001, "Fixture Spinoff S01E01 WEB EZTV", @hash_spinoff,
        swarm: {2, 2},
        size: "300000000",
        released: 1_791_300_000
      )
    ])
  end

  @doc "What EZTV sends for an IMDb id it has no torrents for."
  def empty_page(imdb_id),
    do: %{"imdb_id" => imdb_id, "torrents_count" => 0, "limit" => 100, "page" => 1}

  defp page(imdb_id, count, rows) do
    %{
      "imdb_id" => imdb_id,
      "torrents_count" => count,
      "limit" => 100,
      "page" => 1,
      "torrents" => rows
    }
  end

  defp row(id, title, hash, opts) do
    {seeds, peers} = Keyword.fetch!(opts, :swarm)

    %{
      "id" => id,
      "hash" => hash,
      "filename" => "#{String.replace_suffix(title, " EZTV", "")}[EZTVx.to].mkv",
      "magnet_url" => "magnet:?xt=urn:btih:#{hash}",
      "title" => title,
      "imdb_id" => @show_id,
      "season" => "1",
      "episode" => "1",
      "small_screenshot" => "",
      "large_screenshot" => "",
      "seeds" => seeds,
      "peers" => peers,
      "date_released_unix" => Keyword.fetch!(opts, :released),
      "size_bytes" => Keyword.fetch!(opts, :size)
    }
  end
end
