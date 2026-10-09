defmodule MagnetissimoWeb.TorrentControllerTest do
  use MagnetissimoWeb.ConnCase, async: false

  import Magnetissimo.TorrentsFixtures

  test "GET /api/latest returns the newest torrents with the 2.0.0 fields", %{conn: conn} do
    torrent = torrent_fixture(name: "Dune Part Two 1080p")

    conn = get(conn, ~p"/api/latest")

    assert %{"data" => [data]} = json_response(conn, 200)

    assert data == %{
             "id" => torrent.id,
             "name" => torrent.name,
             "description" => torrent.description,
             "canonical_url" => torrent.canonical_url,
             "published_at" => DateTime.to_iso8601(torrent.published_at),
             "leechers" => torrent.leechers,
             "seeders" => torrent.seeders,
             "size_in_bytes" => torrent.size_in_bytes,
             "magnet_hash" => torrent.magnet_hash,
             "magnet_url" => torrent.magnet_url,
             "category" => "Video - Movies",
             "source" => "YTS"
           }
  end

  test "GET /api/search/:term searches by name", %{conn: conn} do
    dune = torrent_fixture(name: "Dune Part Two 1080p")
    _other = torrent_fixture(name: "Parasite 1080p")

    conn = get(conn, ~p"/api/search/dune")

    assert %{"data" => [%{"id" => id}]} = json_response(conn, 200)
    assert id == dune.id
  end
end
