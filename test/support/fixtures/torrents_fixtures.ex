defmodule Magnetissimo.TorrentsFixtures do
  @moduledoc """
  Test data for the torrents context.

  `seed!/0` loads the real sources, because a torrent cannot be filed without
  one. `torrent_fixture/1` then inserts one torrent with sensible defaults;
  pass a `:category` (a Torznab name such as `"TV/Anime"`) or a `:source`
  name to file it somewhere specific.
  """

  alias Magnetissimo.Seeds
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents

  @doc "Inserts the sources. Safe to call more than once."
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

    category_id = Taxonomy.id!(Map.get(attrs, :category, "Movies"))

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
        category_id: category_id,
        source_id: source.id
      })
      |> Torrents.create_torrent()

    Torrents.get_torrent!(torrent.id)
  end
end
