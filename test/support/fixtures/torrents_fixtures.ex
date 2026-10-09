defmodule Magnetissimo.TorrentsFixtures do
  @moduledoc """
  Test data for the torrents context.

  `seed!/0` loads the real sources and category tree, because a torrent
  cannot be filed without them. `torrent_fixture/1` then inserts one torrent
  with sensible defaults; pass a `:category` or `:source` name to file it
  somewhere specific.
  """

  alias Magnetissimo.Seeds
  alias Magnetissimo.Torrents

  @doc "Inserts the sources and categories. Safe to call more than once."
  def seed!, do: :ok = Seeds.run()

  @doc """
  Inserts a torrent. The hash is derived from the name so two fixtures with
  different names never collide, and the same name is always a duplicate.
  """
  def torrent_fixture(attrs \\ %{}) do
    seed!()
    attrs = Map.new(attrs)

    name = Map.get(attrs, :name, "Fixture Torrent #{System.unique_integer([:positive])}")
    hash = :crypto.hash(:sha, name) |> Base.encode16(case: :lower)

    category =
      Torrents.get_category_by_name_or_alias!(Map.get(attrs, :category, "Video - Movies"))

    source = Torrents.get_source_by_name!(Map.get(attrs, :source, "YTS"))

    {:ok, torrent} =
      attrs
      |> Map.drop([:category, :source])
      |> Enum.into(%{
        name: name,
        description: "#{name} - a fixture.",
        canonical_url: "https://example.test/view/#{hash}",
        published_at: DateTime.utc_now(),
        leechers: 10,
        seeders: 100,
        size_in_bytes: 1_400_000_000,
        magnet_hash: hash,
        magnet_url: "magnet:?xt=urn:btih:#{hash}&dn=#{URI.encode_www_form(name)}",
        category_id: category.id,
        source_id: source.id
      })
      |> Torrents.create_torrent()

    Torrents.get_torrent!(torrent.id)
  end
end
