defmodule MagnetissimoWeb.DhtLiveTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Magnetissimo.DHT
  alias Magnetissimo.DHT.Runner
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  defp dht_torrent(name, attrs \\ %{}) do
    TorrentsFixtures.torrent_fixture(Map.merge(%{name: name, source: "DHT"}, attrs))
  end

  test "lists what the DHT found, and nothing from the sites", %{conn: conn} do
    found = dht_torrent("Found On The DHT", %{files: [%{path: "a.mkv", size: 5}], file_count: 1})
    site = TorrentsFixtures.torrent_fixture(%{name: "From A Site"})

    {:ok, view, _html} = live(conn, ~p"/dht")

    assert has_element?(view, "#dht-torrents-#{found.id}", "Found On The DHT")
    assert has_element?(view, "#dht-torrents-#{found.id}", "1 file")
    refute has_element?(view, "#dht-torrents-#{site.id}")
  end

  test "says the crawler is off, with the switch off at the gentle rate", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/dht")

    assert has_element?(view, "#dht-state", "Off")
    assert has_element?(view, "#dht-off")
    refute has_element?(view, "#dht-enabled[checked]")
    assert has_element?(view, "#dht-rate[value='0']")
    assert has_element?(view, "#dht-rate-about", "Safe on any home router")
  end

  describe "the switch and the rate" do
    setup do
      on_exit(fn -> Runner.apply_config(%{DHT.config(%DHT.Settings{}) | enabled: false}) end)
    end

    test "the switch turns the crawler on and off", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dht")

      view |> form("#dht-settings", dht: %{enabled: "true", rate: "0"}) |> render_change()

      assert has_element?(view, "#dht-enabled[checked]")
      assert has_element?(view, "#dht-enabled-state", "On")
      assert %{enabled: true, rate: "gentle"} = DHT.settings()
      assert [_crawler] = DynamicSupervisor.which_children(DHT.CrawlerSlot)

      view |> form("#dht-settings", dht: %{enabled: "false", rate: "0"}) |> render_change()

      refute has_element?(view, "#dht-enabled[checked]")
      assert DynamicSupervisor.which_children(DHT.CrawlerSlot) == []
    end

    test "the slider picks the rate, and says what it costs", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dht")

      view |> form("#dht-settings", dht: %{enabled: "false", rate: "2"}) |> render_change()

      assert %{rate: "max"} = DHT.settings()
      assert has_element?(view, "#dht-rate-name", "max")
      assert has_element?(view, "#dht-rate-about", "keep it for a VPS")
    end

    test "every open page follows a change", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dht")
      {:ok, _other} = DHT.update_settings(%{enabled: true, rate: "normal"})

      assert has_element?(view, "#dht-enabled[checked]")
      assert has_element?(view, "#dht-rate-name", "normal")
    end

    test "without JavaScript the form posts", %{conn: conn} do
      conn = post(conn, ~p"/dht/settings", dht: %{enabled: "true", rate: "1"})

      assert redirected_to(conn) == ~p"/dht"
      assert %{enabled: true, rate: "normal"} = DHT.settings()
    end
  end

  test "new torrents go on top as they are found", %{conn: conn} do
    old = dht_torrent("Older Find")
    {:ok, view, _html} = live(conn, ~p"/dht")

    new = dht_torrent("Newer Find")
    DHT.broadcast({:dht_indexed, Torrents.get_torrents([new.id])})

    assert has_element?(view, "#dht-torrents-#{new.id}.animate-arrive", "Newer Find")
    refute has_element?(view, "#dht-torrents-#{old.id}.animate-arrive")
    assert has_element?(view, "#dht-torrents > li:first-child#dht-torrents-#{new.id}")
  end

  test "a swarm estimate replaces the numbers and flashes them", %{conn: conn} do
    torrent = dht_torrent("Swarming", %{seeders: 0, leechers: 0})
    {:ok, view, _html} = live(conn, ~p"/dht")

    assert has_element?(view, "#swarm-#{torrent.id}-0-0")
    refute has_element?(view, "#swarm-#{torrent.id}-0-0.animate-flash")

    DHT.broadcast({:dht_swarm, %{id: torrent.id, seeders: 42, leechers: 7}})

    assert has_element?(view, "#swarm-#{torrent.id}-42-7.animate-flash")
    refute has_element?(view, "#swarm-#{torrent.id}-0-0")
  end

  test "the status panel shows the crawler's numbers", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/dht")

    status = %{
      running: true,
      config: %{preset: :gentle, rate: 20, fetches: 8},
      totals: %{indexed: 1_234},
      rates: %{torrents_per_minute: 12.5, hashes_per_minute: 300.0, kbit_out: 10.0, kbit_in: 30.0},
      indexed_last_hour: 600,
      nodes_known: 900,
      fetching: 8,
      fetch_queue: 250,
      udp: %{flows_30s: 100, flows_120s: 400},
      tcp: %{flows_30s: 50, flows_120s: 200}
    }

    DHT.broadcast({:dht_status, status})

    assert has_element?(view, "#dht-state", "Crawling")
    assert has_element?(view, "#dht-indexed-hour", "600")
    assert has_element?(view, "#dht-router", "600")
    assert has_element?(view, "#dht-total", "1,234")
  end

  test "the header links to the page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#nav-dht[href='/dht']")
  end
end
