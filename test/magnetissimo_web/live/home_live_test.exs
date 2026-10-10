defmodule MagnetissimoWeb.HomeLiveTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Magnetissimo.Crawlers.Nyaa.Feed
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.SourceSearch
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures

  setup do
    TorrentsFixtures.seed!()

    # The sources are asked from SourceSearch's own tasks, not from this
    # process, so the stubs are shared with every process.
    Req.Test.set_req_test_to_shared()
    Req.Test.stub(Yts, fn conn -> Req.Test.json(conn, YtsFixtures.api_response()) end)
    # The feed-driven sources are asked too; an empty feed stands in for them.
    Req.Test.stub(Feed, &Plug.Conn.send_resp(&1, 200, "<rss></rss>"))
    Req.Test.stub(TorrentDownloads, &Plug.Conn.send_resp(&1, 200, "<rss></rss>"))

    # The database is rolled back after every test, so a term cached by the
    # last test must not count as already searched in this one.
    previous = Application.get_env(:magnetissimo, SourceSearch)
    Application.put_env(:magnetissimo, SourceSearch, ttl: 0)
    on_exit(fn -> Application.put_env(:magnetissimo, SourceSearch, previous || []) end)

    :ok
  end

  test "the index answers at once, then the sources' hits slide in", %{conn: conn} do
    local = TorrentsFixtures.torrent_fixture(%{name: "Fixture Movie Collection"})
    :ok = SourceSearch.subscribe("Fixture Movie")

    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fixture Movie"]}")

    assert has_element?(view, "#torrents-#{local.id}")
    refute has_element?(view, "#torrents-#{local.id}[data-arrived]")
    assert has_element?(view, "#source-status-yts")

    await_sources(view)

    assert has_element?(view, "#source-status-yts[data-status=done]", "2 found · 2 new")
    assert has_element?(view, "#source-status-nyaa-si[data-status=done]", "nothing")
    assert has_element?(view, "#torrents li[data-arrived]", "Fixture Movie (2024)")
    # What was already on the page stays put rather than arriving again.
    refute has_element?(view, "#torrents-#{local.id}[data-arrived]")
  end

  test "typing patches the url, which asks the sources", %{conn: conn} do
    :ok = SourceSearch.subscribe("Fixture Movie")
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#q[phx-debounce='400']")
    refute has_element?(view, "#source-status")

    view |> form("#search-form", q: "Fixture Movie") |> render_change()
    assert_patch(view, ~p"/?#{[q: "Fixture Movie"]}")

    await_sources(view)
    assert has_element?(view, "#torrents", "Fixture Movie (2024)")
  end

  test "pressing enter asks the sources too", %{conn: conn} do
    :ok = SourceSearch.subscribe("Fixture Movie")
    {:ok, view, _html} = live(conn, ~p"/")

    view |> form("#search-form", q: "Fixture Movie") |> render_submit()
    assert_patch(view, ~p"/?#{[q: "Fixture Movie"]}")

    await_sources(view)
    assert has_element?(view, "#torrents", "Fixture Movie (2024)")
  end

  test "a source that is down is shown as such, and the others still answer", %{conn: conn} do
    Req.Test.stub(TorrentDownloads, &Plug.Conn.send_resp(&1, 503, "unavailable"))
    :ok = SourceSearch.subscribe("Fixture Movie")

    ExUnit.CaptureLog.capture_log(fn ->
      {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fixture Movie"]}")
      await_sources(view)

      assert has_element?(view, "#source-status-torrentdownloads[data-status=failed]")
      assert has_element?(view, "#torrents", "Fixture Movie (2024)")
    end)
  end

  test "an answer for a term the reader has left cannot redraw the list", %{conn: conn} do
    current = TorrentsFixtures.torrent_fixture(%{name: "Deadpoint (2026)"})
    :ok = SourceSearch.subscribe("Deadpoint")

    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Deadpoint"]}")
    await_sources(view)

    # The earlier term's answer lands after the reader has moved on. It matches
    # "Fall" but not "Deadpoint", so applying it would drop the current result.
    stale = TorrentsFixtures.torrent_fixture(%{name: "Fall From Grace (2024)"})
    send(view.pid, {:source_search, "fall", "YTS", {:done, %{found: 1, inserted: 1}}})

    assert has_element?(view, "#torrents-#{current.id}", "Deadpoint (2026)")
    refute has_element?(view, "#torrents-#{stale.id}")
  end

  test "the first, disconnected render shows the index and asks no one", %{conn: conn} do
    TorrentsFixtures.torrent_fixture(%{name: "Deadpoint (2026)"})

    html = conn |> get(~p"/?#{[q: "Deadpoint"]}") |> html_response(200)

    assert html =~ "Deadpoint (2026)"
    refute html =~ "source-status"
  end

  # Every source must be done before the test ends: the sandbox hands their
  # tasks a connection they would otherwise still be writing on after the
  # test's transaction has rolled back.
  #
  # The broadcast reaches this process and the view from the same handler in
  # SourceSearch, so once that handler is over and the view has worked through
  # its mailbox, the view has seen every answer.
  defp await_sources(view) do
    assert_receive {:source_search_done, _key, _statuses}, 2_000
    _ = :sys.get_state(SourceSearch)
    _ = :sys.get_state(view.pid)
    :ok
  end
end
