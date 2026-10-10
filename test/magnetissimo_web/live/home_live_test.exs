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

  describe "operators and refine fields" do
    setup do
      now = DateTime.utc_now()
      gib = 1024 * 1024 * 1024

      for {name, size, seeders, days} <- [
            {"Lima Film 2160p", 20 * gib, 900, 1},
            {"Lima Film 1080p", 6 * gib, 40, 30},
            {"Lima Film CAM", gib, 2, 400}
          ] do
        TorrentsFixtures.torrent_fixture(%{
          name: name,
          description: "A couple of lima beans.",
          size_in_bytes: size,
          seeders: seeders,
          published_at: DateTime.add(now, -days, :day)
        })
      end

      :ok
    end

    test "an exclusion narrows the list, and the sources are asked the plain words",
         %{conn: conn} do
      :ok = SourceSearch.subscribe("lima")
      {:ok, view, _html} = live(conn, ~p"/?#{[q: "lima -cam"]}")
      await_terms(view, ["lima"])

      # The stub sources answer any search with their fixtures, which a source
      # hit lets through: what matters is that the CAM is gone.
      lima = view |> row_names() |> Enum.filter(&String.starts_with?(&1, "Lima"))
      assert Enum.sort(lima) == ["Lima Film 1080p", "Lima Film 2160p"]
      assert has_element?(view, "#source-status-yts[data-status=done]")
    end

    test "each alternative asks the sources, and every answer is followed", %{conn: conn} do
      terms = ["lima 2160p", "lima 1080p"]
      for term <- terms, do: :ok = SourceSearch.subscribe(term)

      {:ok, view, _html} = live(conn, ~p"/?#{[q: "lima 2160p|1080p"]}")
      assert has_element?(view, "#source-status-yts")
      await_terms(view, terms)

      assert Enum.sort(row_names(view)) == ["Lima Film 1080p", "Lima Film 2160p"]
      refute has_element?(view, "#source-status li[data-status=searching]")
    end

    test "a query of exclusions only asks no one and lists everything else", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/?#{[q: "-cam"]}")

      refute has_element?(view, "#source-status")
      assert Enum.sort(row_names(view)) == ["Lima Film 1080p", "Lima Film 2160p"]
    end

    test "refine fields filter the list and every link keeps them", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/?#{[min_size: "5 GB", max_age: "60d"]}")

      assert Enum.sort(row_names(view)) == ["Lima Film 1080p", "Lima Film 2160p"]
      assert has_element?(view, "#refine[open]")
      assert has_element?(view, "#refine-min_size[value='5 GB']")
      assert has_element?(view, "#refine-line", "at least 5.0 GiB")

      for link <- ["#sort-seeders", "#category-2000", "#source-yts"] do
        assert has_element?(view, ~s(#{link}[href*="min_size=5+GB"][href*="max_age=60d"])),
               "#{link} drops the refine fields"
      end

      view |> element("#clear-refine") |> render_click()
      assert_patch(view, ~p"/")
      assert Enum.sort(row_names(view)) == ["Lima Film 1080p", "Lima Film 2160p", "Lima Film CAM"]
    end

    test "changing a refine field patches the url, as typed", %{conn: conn} do
      :ok = SourceSearch.subscribe("lima")
      {:ok, view, _html} = live(conn, ~p"/?#{[q: "lima"]}")
      refute has_element?(view, "#refine[open]")

      view
      |> form("#search-form", q: "lima", min_seeders: "10", in: "title")
      |> render_change()

      assert_patch(view, ~p"/?#{[q: "lima", in: "title", min_seeders: "10"]}")
      assert Enum.sort(row_names(view)) == ["Lima Film 1080p", "Lima Film 2160p"]
      await_terms(view, ["lima"])
    end

    test "names only leaves out matches in the description", %{conn: conn} do
      :ok = SourceSearch.subscribe("couple")
      {:ok, view, _html} = live(conn, ~p"/?#{[q: "couple", in: "title"]}")
      assert row_names(view) == []
      await_terms(view, ["couple"])

      # The sources answered "couple" a moment ago, so they are not asked again.
      {:ok, view, _html} = live(conn, ~p"/?#{[q: "couple"]}")
      assert view |> row_names() |> Enum.count(&String.starts_with?(&1, "Lima")) == 3
    end

    test "a field that does not read is ignored and marked", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/?#{[min_size: "huge", max_seeders: "100"]}")

      assert has_element?(view, "#refine-min_size[aria-invalid=true][value=huge]")
      refute has_element?(view, "#refine-max_seeders[aria-invalid]")
      assert Enum.sort(row_names(view)) == ["Lima Film 1080p", "Lima Film CAM"]
    end

    test "the form still works as a plain GET without JavaScript", %{conn: conn} do
      html = conn |> get(~p"/?#{[q: "lima", min_seeders: "100"]}") |> html_response(200)
      doc = LazyHTML.from_document(html)

      for name <- [
            "q",
            "in",
            "min_size",
            "max_size",
            "min_seeders",
            "max_seeders",
            "max_age",
            "min_age"
          ] do
        refute Enum.empty?(
                 LazyHTML.query(doc, ~s(form#search-form[method=get] [name="#{name}"]))
               ),
               "the form has no #{name} field"
      end

      rows = doc |> LazyHTML.query("#torrents h2") |> Enum.map(&String.trim(LazyHTML.text(&1)))
      assert Enum.sort(rows) == ["Lima Film 2160p"]
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
  # Like `await_sources/1`, for a page that asked the sources several terms.
  defp await_terms(view, terms) do
    for term <- terms do
      key = SourceSearch.key(term)
      assert_receive {:source_search_done, ^key, _statuses}, 2_000
    end

    _ = :sys.get_state(SourceSearch)
    _ = :sys.get_state(view.pid)
    :ok
  end

  defp await_sources(view) do
    assert_receive {:source_search_done, _key, _statuses}, 2_000
    _ = :sys.get_state(SourceSearch)
    _ = :sys.get_state(view.pid)
    :ok
  end
end
