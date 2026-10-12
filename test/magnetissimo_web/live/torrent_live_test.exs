defmodule MagnetissimoWeb.TorrentLiveTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Magnetissimo.TorrentsFixtures

  test "a torrent's files are listed, with how many more there are", %{conn: conn} do
    torrent =
      TorrentsFixtures.torrent_fixture(%{
        name: "Big Pack",
        source: "DHT",
        files: [
          %{path: "Pack/Disc 1.iso", size: 4_700_000_000},
          %{path: "Pack/readme.nfo", size: 1_200}
        ],
        file_count: 1_502
      })

    {:ok, view, _html} = live(conn, ~p"/torrents/#{torrent}")

    assert has_element?(view, "#files li", "Pack/Disc 1.iso")
    assert has_element?(view, "#files li", "Pack/readme.nfo")
    assert has_element?(view, "#files-more", "1,500 more")
  end

  test "a DHT torrent links to the DHT page, not to a page it doesn't have", %{conn: conn} do
    torrent = TorrentsFixtures.torrent_fixture(%{name: "Found On The DHT", source: "DHT"})
    {:ok, view, _html} = live(conn, ~p"/torrents/#{torrent}")

    assert has_element?(view, "a[href='/dht']", "DHT")
    refute has_element?(view, "#source-link")
  end

  test "a site's torrent has no file list, and links to its page", %{conn: conn} do
    torrent = TorrentsFixtures.torrent_fixture(%{name: "From A Site"})
    {:ok, view, _html} = live(conn, ~p"/torrents/#{torrent}")

    refute has_element?(view, "#files")
    assert has_element?(view, "#source-link", "View on YTS")
  end
end
