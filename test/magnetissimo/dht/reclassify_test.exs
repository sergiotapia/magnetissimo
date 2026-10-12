defmodule Magnetissimo.DHT.ReclassifyTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.DHT
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  defp attrs(source, name, category) do
    hash = :crypto.hash(:sha, name) |> Base.encode16(case: :lower)

    %{
      name: name,
      canonical_url: "magnet:?xt=urn:btih:#{hash}",
      published_at: DateTime.utc_now(),
      size_in_bytes: 1_000_000_000,
      magnet_hash: hash,
      magnet_url: "magnet:?xt=urn:btih:#{hash}",
      category_id: Taxonomy.id!(category),
      source_id: Torrents.get_source_by_name!(source).id,
      files: [%{path: "#{name}.mkv", size: 1_000_000_000}],
      file_count: 1
    }
  end

  defp category(id), do: Taxonomy.fetch!(Torrents.get_torrent!(id).category_id).name

  test "files the DHT's torrents again, but not one a site has returned" do
    %{ids: [stale]} = Torrents.index_torrents([attrs("DHT", "Show.S01E01.1080p", "Movies")])
    %{ids: [current]} = Torrents.index_torrents([attrs("DHT", "Film.2020.1080p", "Movies/HD")])
    %{ids: [returned]} = Torrents.index_torrents([attrs("DHT", "Other.S01E02.1080p", "Movies")])

    %{ids: [^returned]} =
      Torrents.index_torrents([attrs("Nyaa.si", "Other.S01E02.1080p", "Other")],
        search_term: "other"
      )

    %{ids: [site]} = Torrents.index_torrents([attrs("YTS", "Site.S01E03.1080p", "Movies")])

    assert DHT.reclassify_torrents() == 1

    assert category(stale) == "TV/HD"
    assert category(current) == "Movies/HD"
    assert category(returned) == "Movies"
    assert category(site) == "Movies"
  end
end
