defmodule MagnetissimoWeb.HomeLiveTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Magnetissimo.Crawlers.Nyaa.Feed
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures
  alias Req.Test

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  test "typing asks the source after the debounce, then shows what it found", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    allow_sources(view)

    assert has_element?(view, "#q[phx-debounce='400']")

    html = view |> form("#search-form", q: "Fixture Movie") |> render_change()
    assert html =~ "Asking the source"

    await_source(view)

    assert has_element?(view, "#torrents", "Fixture Movie (2024)")
    refute has_element?(view, "#source-search")
  end

  test "pressing enter asks the source immediately", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    allow_sources(view)

    html = view |> form("#search-form", q: "Fixture Movie") |> render_submit()
    assert html =~ "Asking the source"

    await_source(view)
  end

  test "hits from the source appear in the results as they arrive", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fall 2 Deadpoint"]}")

    torrent = TorrentsFixtures.torrent_fixture(%{name: "Fall 2: Deadpoint (2026)"})
    refute has_element?(view, "#torrents-#{torrent.id}")

    send(view.pid, {:source_search, "Fall 2 Deadpoint", :updated})

    assert has_element?(view, "#torrents-#{torrent.id}", "Fall 2: Deadpoint (2026)")
  end

  test "a slow lookup for an earlier term cannot redraw the current list", %{conn: conn} do
    current = TorrentsFixtures.torrent_fixture(%{name: "Deadpoint (2026)"})

    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Deadpoint"]}")
    assert has_element?(view, "#torrents-#{current.id}", "Deadpoint (2026)")

    # The earlier term's batch lands after the reader has moved on. It matches
    # "Fall" but not "Deadpoint", so applying it would drop the current result.
    stale = TorrentsFixtures.torrent_fixture(%{name: "Fall From Grace (2024)"})
    send(view.pid, {:source_search, "Fall", :updated})

    assert has_element?(view, "#torrents-#{current.id}", "Deadpoint (2026)")
    refute has_element?(view, "#torrents-#{stale.id}")
  end

  defp allow_sources(view) do
    Test.stub(Yts, fn conn -> Req.Test.json(conn, YtsFixtures.api_response()) end)
    # The feed-driven sources are asked too; an empty feed stands in for them.
    Test.stub(Feed, fn conn -> Plug.Conn.send_resp(conn, 200, "<rss></rss>") end)
    Test.stub(TorrentDownloads, fn conn -> Plug.Conn.send_resp(conn, 200, "<rss></rss>") end)

    assert :ok = Test.allow(Yts, self(), view.pid)
    assert :ok = Test.allow(Feed, self(), view.pid)
    assert :ok = Test.allow(TorrentDownloads, self(), view.pid)
  end

  # The lookup runs in its own process, which must finish before the test does:
  # the sandbox hands it a connection it would otherwise still be writing on
  # after the test's transaction has rolled back.
  defp await_source(view) do
    case :sys.get_state(view.pid).socket.assigns.search_task do
      # Already finished and cleared; there is nothing left to wait on.
      nil ->
        :ok

      task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, ^task, reason}
        # `:noproc` means it exited between the read above and the monitor.
        assert reason in [:normal, :noproc]
    end
  end
end
