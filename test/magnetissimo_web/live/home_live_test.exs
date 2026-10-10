defmodule MagnetissimoWeb.HomeLiveTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.SourceSearch
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures

  setup :stub_sources

  test "the index answers at once, then the sources' hits slide in", %{conn: conn} do
    local = TorrentsFixtures.torrent_fixture(%{name: "Fixture Movie Collection"})
    :ok = SourceSearch.subscribe("Fixture Movie")

    # YTS holds its answer until the first page is on screen. Answering at
    # once, it can land before that page is read, and then its hits are part
    # of it rather than arrivals.
    test = self()

    Req.Test.stub(Yts, fn conn ->
      send(test, {:yts_asked, self()})
      assert_receive :answer, 2_000
      Req.Test.json(conn, YtsFixtures.api_response())
    end)

    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fixture Movie"]}")

    assert has_element?(view, "#torrents-#{local.id}")
    refute has_element?(view, "#torrents-#{local.id}[data-arrived]")
    assert has_element?(view, "#source-status-yts[data-status=searching]")

    assert_receive {:yts_asked, yts}, 2_000
    send(yts, :answer)
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

  test "with a category filter on, each answer says how much of it the filter shows",
       %{conn: conn} do
    :ok = SourceSearch.subscribe("Fixture Movie")

    # YTS files the fixture's two variants under Movies/HD.
    {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fixture Movie", category: 5000]}")
    await_sources(view)

    assert has_element?(view, "#source-status-yts", "2 found · 0 in TV")
    assert has_element?(view, "#filtered-away", "2 more outside the filter")
    refute has_element?(view, "#torrents li[id^=torrents-]:not(#torrents-empty)")

    view |> element("#show-all") |> render_click()
    assert_patch(view, ~p"/?#{[q: "Fixture Movie"]}")
    assert has_element?(view, "#torrents", "Fixture Movie (2024)")
    assert has_element?(view, "#source-status-yts", "2 found · 2 new")
    refute has_element?(view, "#filtered-away")
  end

  describe "source filter" do
    setup do
      yts = TorrentsFixtures.torrent_fixture(%{name: "Foxtrot Film", source: "YTS"})

      eztv =
        TorrentsFixtures.torrent_fixture(%{
          name: "Foxtrot Show S01E01",
          source: "EZTV",
          category: "TV/HD"
        })

      nyaa =
        TorrentsFixtures.torrent_fixture(%{
          name: "Foxtrot Anime",
          source: "Nyaa.si",
          category: "TV/Anime"
        })

      %{yts: yts, eztv: eztv, nyaa: nyaa}
    end

    test "toggling sources adds them to the filter and takes them out", %{conn: conn} = ctx do
      {:ok, view, _html} = live(conn, ~p"/")

      # Every source is listed, picked or not, and none picked shows them all.
      assert has_element?(view, "#source-the-pirate-bay")
      refute has_element?(view, "#clear-sources")
      assert has_element?(view, "#torrents-#{ctx.yts.id}")

      view |> element("#source-eztv") |> render_click()
      assert_patch(view, ~p"/?#{[sources: "eztv"]}")
      assert has_element?(view, "#source-eztv[aria-current=true]")
      assert has_element?(view, "#torrents-#{ctx.eztv.id}")
      refute has_element?(view, "#torrents-#{ctx.yts.id}")
      refute has_element?(view, "#torrents-#{ctx.nyaa.id}")

      # A second source is added, and the URL lists them in page order.
      view |> element("#source-nyaa-si") |> render_click()
      assert_patch(view, ~p"/?#{[sources: "eztv,nyaa-si"]}")
      assert has_element?(view, "#torrents-#{ctx.nyaa.id}")
      refute has_element?(view, "#torrents-#{ctx.yts.id}")

      view |> element("#source-eztv") |> render_click()
      assert_patch(view, ~p"/?#{[sources: "nyaa-si"]}")
      refute has_element?(view, "#torrents-#{ctx.eztv.id}")

      view |> element("#clear-sources") |> render_click()
      assert_patch(view, ~p"/")
      assert has_element?(view, "#torrents-#{ctx.yts.id}")
    end

    test "the source filter combines with a category and survives a new search",
         %{conn: conn} = ctx do
      {:ok, view, _html} = live(conn, ~p"/?#{[sources: "eztv,nyaa-si", category: 5070]}")

      assert has_element?(view, "#torrents-#{ctx.nyaa.id}")
      refute has_element?(view, "#torrents-#{ctx.eztv.id}")
      assert has_element?(view, "#search-form input[name=sources][value='eztv,nyaa-si']")

      # YTS finds nothing, so what is outside the filter is only what is indexed.
      Req.Test.stub(Yts, &Req.Test.json(&1, %{"data" => %{"movie_count" => 0}}))
      :ok = SourceSearch.subscribe("Foxtrot")

      view |> form("#search-form", q: "Foxtrot") |> render_submit()
      assert_patch(view, ~p"/?#{[q: "Foxtrot", category: 5070, sources: "eztv,nyaa-si"]}")
      await_sources(view)

      assert has_element?(view, "#source-filter-line", "from EZTV, Nyaa.si")
      assert has_element?(view, "#filtered-away", "2 more outside the filter")

      view |> element("#show-all") |> render_click()
      assert_patch(view, ~p"/?#{[q: "Foxtrot"]}")
      assert has_element?(view, "#torrents-#{ctx.yts.id}")
    end

    test "a source answering outside the filter says its hits are not shown", %{conn: conn} do
      :ok = SourceSearch.subscribe("Fixture Movie")

      {:ok, view, _html} = live(conn, ~p"/?#{[q: "Fixture Movie", sources: "eztv"]}")
      await_sources(view)

      assert has_element?(view, "#source-status-yts[data-hidden]", "2 found · not shown")
      refute has_element?(view, "#source-status-eztv[data-hidden]")
      refute has_element?(view, "#torrents", "Fixture Movie (2024)")
    end

    test "a source the page does not know is ignored", %{conn: conn} = ctx do
      {:ok, view, _html} = live(conn, ~p"/?#{[sources: "nowhere"]}")

      refute has_element?(view, "#clear-sources")
      assert has_element?(view, "#torrents-#{ctx.yts.id}")
    end
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

  describe "column headers" do
    setup do
      now = DateTime.utc_now()

      TorrentsFixtures.torrent_fixture(%{
        name: "Kappa Big",
        size_in_bytes: 9_000,
        seeders: 1,
        published_at: DateTime.add(now, -2, :day)
      })

      TorrentsFixtures.torrent_fixture(%{
        name: "kappa Alpha",
        size_in_bytes: 1_000,
        seeders: 900,
        published_at: now
      })

      :ok
    end

    test "sort the latest list, one way then the other, then back", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Unsorted, the latest list is in age order, and the header says so.
      assert has_element?(view, "#sort-age[data-dir=asc]")
      assert row_names(view) == ["kappa Alpha", "Kappa Big"]

      view |> element("#sort-size") |> render_click()
      assert_patch(view, ~p"/?#{[sort: "size", dir: "desc"]}")
      assert has_element?(view, "#sort-size[data-dir=desc]")
      refute has_element?(view, "#sort-age[data-dir]")
      assert row_names(view) == ["Kappa Big", "kappa Alpha"]

      view |> element("#sort-size") |> render_click()
      assert_patch(view, ~p"/?#{[sort: "size", dir: "asc"]}")
      assert row_names(view) == ["kappa Alpha", "Kappa Big"]

      view |> element("#sort-size") |> render_click()
      assert_patch(view, ~p"/")
      refute has_element?(view, "#sort-size[data-dir]")

      view |> element("#sort-age") |> render_click()
      assert_patch(view, ~p"/?#{[sort: "age", dir: "desc"]}")
      assert row_names(view) == ["Kappa Big", "kappa Alpha"]
    end

    test "sort a search by name or seeders, and keep the sort when searching again",
         %{conn: conn} do
      # The sources find nothing, so the rows are only the two fixtures.
      Req.Test.stub(Yts, &Req.Test.json(&1, YtsFixtures.empty_response()))
      :ok = SourceSearch.subscribe("kappa")
      :ok = SourceSearch.subscribe("kappa big")

      {:ok, view, _html} = live(conn, ~p"/?#{[q: "kappa", sort: "name"]}")
      await_sources(view)

      # No direction in the link is the column's own: A to Z.
      assert has_element?(view, "#sort-name[data-dir=asc]")
      assert row_names(view) == ["kappa Alpha", "Kappa Big"]

      view |> element("#sort-seeders") |> render_click()
      assert_patch(view, ~p"/?#{[q: "kappa", sort: "seeders", dir: "desc"]}")
      assert row_names(view) == ["kappa Alpha", "Kappa Big"]

      view |> form("#search-form", q: "kappa big") |> render_submit()
      assert_patch(view, ~p"/?#{[q: "kappa big", sort: "seeders", dir: "desc"]}")
      await_sources(view)
    end

    test "a sort the page does not know is ignored", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/?#{[sort: "magnet_hash", dir: "sideways"]}")

      assert has_element?(view, "#sort-age[data-dir=asc]")
      assert row_names(view) == ["kappa Alpha", "Kappa Big"]
    end
  end

  defp row_names(view) do
    view
    |> render()
    |> LazyHTML.from_fragment()
    |> LazyHTML.query("#torrents li[id^=torrents-]:not(#torrents-empty) h2")
    |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))
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
