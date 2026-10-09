defmodule MagnetissimoWeb.HomeLiveTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Magnetissimo.Crawlers.Nyaa.Feed
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures

  test "submitting a search asks the source, then shows what it found", %{conn: conn} do
    TorrentsFixtures.seed!()
    Req.Test.stub(Yts, fn conn -> Req.Test.json(conn, YtsFixtures.api_response()) end)
    # The Nyaa sites are asked too; an empty feed stands in for them here.
    Req.Test.stub(Feed, fn conn -> Plug.Conn.send_resp(conn, 200, "<rss></rss>") end)

    {:ok, view, _html} = live(conn, ~p"/")
    assert :ok = Req.Test.allow(Yts, self(), view.pid)
    assert :ok = Req.Test.allow(Feed, self(), view.pid)

    html = view |> form("#search-form", q: "Fixture Movie") |> render_submit()
    assert html =~ "Asking the source"

    await_source(view)

    assert has_element?(view, "#torrents", "Fixture Movie (2024)")
    refute has_element?(view, "#source-search")
  end

  test "typing searches the local index and never asks the source", %{conn: conn} do
    TorrentsFixtures.seed!()

    {:ok, view, _html} = live(conn, ~p"/")

    html = view |> form("#search-form", q: "fall deadpoint") |> render_change()

    refute html =~ "Asking the source"
    refute has_element?(view, "#source-search")
  end

  test "hits from the source appear in the results as they arrive", %{conn: conn} do
    TorrentsFixtures.seed!()

    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fall 2 Deadpoint"]}")

    torrent = TorrentsFixtures.torrent_fixture(%{name: "Fall 2: Deadpoint (2026)"})
    refute has_element?(view, "#torrents-#{torrent.id}")

    send(view.pid, {:source_search, "Fall 2 Deadpoint", :updated})

    assert has_element?(view, "#torrents-#{torrent.id}", "Fall 2: Deadpoint (2026)")
  end

  test "a batch for a term the reader has moved on from is dropped", %{conn: conn} do
    TorrentsFixtures.seed!()

    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fall"]}")

    # Indexed mid-search: it matches "Fall", so it would appear if the batch
    # were applied, which is exactly what must not happen.
    torrent = TorrentsFixtures.torrent_fixture(%{name: "Fall From Grace (2024)"})
    refute has_element?(view, "#torrents-#{torrent.id}")

    send(view.pid, {:source_search, "Deadpoint", :updated})

    refute has_element?(view, "#torrents-#{torrent.id}")
  end

  # The lookup runs in its own process, which must finish before the test does:
  # the sandbox hands it a connection it would otherwise still be writing on
  # after the test's transaction has rolled back.
  defp await_source(view) do
    task = :sys.get_state(view.pid).socket.assigns.search_task
    ref = Process.monitor(task)

    assert_receive {:DOWN, ^ref, :process, ^task, :normal}
  end
end
