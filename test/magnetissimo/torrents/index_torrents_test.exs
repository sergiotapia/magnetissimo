defmodule Magnetissimo.Torrents.IndexTorrentsTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  defp attrs(source, overrides) do
    hash = :crypto.hash(:sha, "index torrents test") |> Base.encode16(case: :lower)

    Map.merge(
      %{
        name: "Fixture Release",
        canonical_url: "https://example.test/#{hash}",
        published_at: DateTime.utc_now(),
        size_in_bytes: 1_000,
        magnet_hash: hash,
        magnet_url: "magnet:?xt=urn:btih:#{hash}",
        category_id: Taxonomy.id!("Movies"),
        source_id: Torrents.get_source_by_name!(source).id
      },
      overrides
    )
  end

  test "a source with no swarm leaves the swarm another source counted" do
    %{ids: [id]} = Torrents.index_torrents([attrs("The Pirate Bay", %{seeders: 40, leechers: 3})])
    %{ids: [^id]} = Torrents.index_torrents([attrs("AudioBookBay", %{})])

    assert %{seeders: 40, leechers: 3} = Torrents.get_torrent!(id)
  end

  test "a source with a swarm still refreshes it" do
    %{ids: [id]} = Torrents.index_torrents([attrs("The Pirate Bay", %{seeders: 40, leechers: 3})])
    %{ids: [^id]} = Torrents.index_torrents([attrs("YTS", %{seeders: 0, leechers: 9})])

    assert %{seeders: 0, leechers: 9} = Torrents.get_torrent!(id)
  end

  test "a new torrent from a source with no swarm starts at zero" do
    %{ids: [id]} = Torrents.index_torrents([attrs("AudioBookBay", %{})])

    assert %{seeders: 0, leechers: 0} = Torrents.get_torrent!(id)
  end

  test "a torrent indexed without a file list gains one, and keeps the first it had" do
    %{ids: [id]} = Torrents.index_torrents([attrs("YTS", %{seeders: 5})])
    assert Torrents.get_torrent!(id).files == nil

    files = [%{path: "Movie.mkv", size: 1_000}]
    %{ids: [^id]} = Torrents.index_torrents([attrs("YTS", %{files: files, file_count: 1})])

    assert %{files: [%{"path" => "Movie.mkv"}], file_count: 1, seeders: 5} =
             Torrents.get_torrent!(id)

    other = [%{path: "Other.mkv", size: 1_000}]
    %{ids: [^id]} = Torrents.index_torrents([attrs("YTS", %{files: other, file_count: 1})])

    assert [%{"path" => "Movie.mkv"}] = Torrents.get_torrent!(id).files
    assert Torrents.count_search_torrents("movie.mkv") == 1
  end

  test "a site's category replaces the DHT's guess, and the DHT never puts it back" do
    movies = %{category_id: Taxonomy.id!("Movies")}
    anime = %{category_id: Taxonomy.id!("TV/Anime")}
    other = %{category_id: Taxonomy.other_id()}

    %{ids: [id]} = Torrents.index_torrents([attrs("DHT", movies)])
    %{ids: [^id]} = Torrents.index_torrents([attrs("TorrentDownloads", other)])
    assert Torrents.get_torrent!(id).category_id == Taxonomy.id!("Movies")

    %{ids: [^id]} = Torrents.index_torrents([attrs("Nyaa.si", anime)])
    assert Torrents.get_torrent!(id).category_id == Taxonomy.id!("TV/Anime")

    %{ids: [^id]} = Torrents.index_torrents([attrs("DHT", movies)])
    assert Torrents.get_torrent!(id).category_id == Taxonomy.id!("TV/Anime")
  end

  test "a site's category is never replaced but for Other" do
    %{ids: [id]} = Torrents.index_torrents([attrs("YTS", %{})])

    %{ids: [^id]} =
      Torrents.index_torrents([attrs("Nyaa.si", %{category_id: Taxonomy.id!("TV")})])

    assert Torrents.get_torrent!(id).category_id == Taxonomy.id!("Movies")

    %{ids: [^id]} = Torrents.index_torrents([attrs("DHT", %{category_id: Taxonomy.id!("XXX")})])
    assert Torrents.get_torrent!(id).category_id == Taxonomy.id!("Movies")
  end

  test "a size past SQLite's integers is rejected, not a crash" do
    %{ids: [], rejected: [{_attrs, errors}]} =
      Torrents.index_torrents([attrs("YTS", %{size_in_bytes: 99_999_999_999_999_999_999})])

    assert Keyword.has_key?(errors, :size_in_bytes)
  end

  test "a refreshed swarm does not touch the search indexes" do
    %{ids: [id]} = Torrents.index_torrents([attrs("YTS", %{seeders: 5})])
    %{ids: [^id]} = Torrents.index_torrents([attrs("YTS", %{seeders: 6})])

    for index <- ["torrents_search", "torrents_words"] do
      Repo.query!("INSERT INTO #{index}(#{index}) VALUES('integrity-check')")
    end

    assert Torrents.count_search_torrents("fixture release") == 1
  end
end
