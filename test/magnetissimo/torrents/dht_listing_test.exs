defmodule Magnetissimo.Torrents.DhtListingTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    site = TorrentsFixtures.torrent_fixture(%{name: "Site Release", category: "Movies"})

    dht =
      TorrentsFixtures.torrent_fixture(%{name: "DHT Release", category: "Movies", source: "DHT"})

    %{site: site, dht: dht}
  end

  test "the views without a search leave the DHT out", %{site: site} do
    assert Enum.map(Torrents.list_latest_torrents(), & &1.id) == [site.id]
    assert Torrents.count_torrents() == 1
    assert Torrents.count_torrents_by_category() == %{Taxonomy.id!("Movies") => 1}
  end

  test "picking the DHT as a source shows it", %{dht: dht} do
    source = Torrents.get_source_by_name!("DHT")

    assert Enum.map(Torrents.list_latest_torrents(source_ids: [source.id]), & &1.id) == [dht.id]
    assert Torrents.count_torrents(source_ids: [source.id]) == 1
  end

  test "a search finds DHT torrents like any other" do
    assert Enum.map(Torrents.search_torrents("release"), & &1.name) |> Enum.sort() ==
             ["DHT Release", "Site Release"]
  end

  test "list_dht_torrents/1 lists only the DHT's, newest first", %{dht: dht} do
    newer = TorrentsFixtures.torrent_fixture(%{name: "Newer DHT Release", source: "DHT"})

    assert Enum.map(Torrents.list_dht_torrents(), & &1.id) == [newer.id, dht.id]
    assert Enum.map(Torrents.list_dht_torrents(limit: 1), & &1.id) == [newer.id]
  end

  test "known_hashes/1 and update_swarm/3", %{dht: dht} do
    unknown = String.duplicate("0", 40)

    assert Torrents.known_hashes([dht.magnet_hash, unknown]) == MapSet.new([dht.magnet_hash])
    assert Torrents.update_swarm(dht.magnet_hash, 12, 3) == {:ok, dht.id}
    assert %{seeders: 12, leechers: 3} = Torrents.get_torrent!(dht.id)
    assert Torrents.update_swarm(unknown, 1, 1) == :error
  end
end
