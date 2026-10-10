defmodule Magnetissimo.ThePirateBayFixtures do
  @moduledoc """
  Synthetic apibay `q.php` answers for tests.

  Shaped after the real responses, with no real data in them. Three details
  are load-bearing: every value is a string, numbers included; the infohash is
  uppercase; and names keep the site's HTML escaping (`&amp;`).
  """

  @hash_hd "0123456789ABCDEF0123456789ABCDEF01234567"
  @hash_book "89ABCDEF0123456789ABCDEF0123456789ABCDEF"

  def hash_hd, do: @hash_hd
  def hash_book, do: @hash_book

  @doc "Two hits: an HD film and an e-book whose name carries an entity."
  def api_response do
    [
      row("1001", "Fixture Movie 2024 1080p WEB-DL", @hash_hd,
        swarm: {"25", "4"},
        size: "1621350154",
        added: "1791568547",
        category: "207"
      ),
      row("1002", "Fixtures &amp; Factories, 2nd Edition", @hash_book,
        swarm: {"7", "0"},
        size: "8554738",
        added: "1791564238",
        category: "601"
      )
    ]
  end

  @doc "What apibay sends for a term that matched nothing: one placeholder row."
  def empty_response do
    placeholder =
      row("0", "No results returned", String.duplicate("0", 40),
        swarm: {"0", "0"},
        size: "0",
        added: "0",
        category: "0"
      )

    [Map.put(placeholder, "total_found", "1")]
  end

  defp row(id, name, hash, opts) do
    {seeders, leechers} = Keyword.fetch!(opts, :swarm)

    %{
      "id" => id,
      "name" => name,
      "info_hash" => hash,
      "seeders" => seeders,
      "leechers" => leechers,
      "size" => Keyword.fetch!(opts, :size),
      "num_files" => "1",
      "added" => Keyword.fetch!(opts, :added),
      "category" => Keyword.fetch!(opts, :category),
      "username" => "fixture",
      "status" => "member",
      "imdb" => ""
    }
  end
end
