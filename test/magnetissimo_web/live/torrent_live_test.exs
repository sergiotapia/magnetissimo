defmodule MagnetissimoWeb.TorrentLiveTest do
  use MagnetissimoWeb.ConnCase, async: false

  import Magnetissimo.TorrentsFixtures
  import Phoenix.LiveViewTest

  test "shows the dossier with the magnet and the source link", %{conn: conn} do
    torrent = torrent_fixture(name: "Oppenheimer 2160p", seeders: 3412, leechers: 210)

    {:ok, view, html} = live(conn, ~p"/torrents/#{torrent}")

    assert html =~ "Oppenheimer 2160p"
    assert has_element?(view, "#torrent-#{torrent.id}")
    assert has_element?(view, "#magnet-link[href='#{torrent.magnet_url}']")
    assert has_element?(view, "#source-link[href='#{torrent.canonical_url}']")

    assert has_element?(
             view,
             "#torrent-#{torrent.id} svg[aria-label='infohash fingerprint'] rect"
           )

    assert has_element?(view, "#torrent-#{torrent.id} dd", torrent.magnet_hash)
  end

  test "404s for a torrent that does not exist", %{conn: conn} do
    seed!()

    assert_raise Ecto.NoResultsError, fn ->
      live(conn, ~p"/torrents/123456")
    end
  end
end
