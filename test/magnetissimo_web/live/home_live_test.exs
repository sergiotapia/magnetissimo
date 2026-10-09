defmodule MagnetissimoWeb.HomeLiveTest do
  use MagnetissimoWeb.ConnCase, async: false

  import Magnetissimo.TorrentsFixtures
  import Phoenix.LiveViewTest

  describe "latest" do
    test "lists the newest torrents with a link to each", %{conn: conn} do
      torrent = torrent_fixture(name: "Blade Runner 2049 2160p")

      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#search-form")
      assert has_element?(view, "#torrents-#{torrent.id} a[href='/torrents/#{torrent.id}']")
      assert has_element?(view, "#torrents-#{torrent.id} a[href^='magnet:?xt=urn:btih:']")
      assert has_element?(view, "#sources")
      assert has_element?(view, "#categories")
    end

    test "shows the empty state when nothing is indexed", %{conn: conn} do
      seed!()
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#torrents-empty")
      refute has_element?(view, "#torrents a[href^='/torrents/']")
    end
  end

  describe "search" do
    test "typing patches the URL and narrows the list", %{conn: conn} do
      dune = torrent_fixture(name: "Dune Part Two 1080p")
      other = torrent_fixture(name: "Parasite 1080p")

      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#search-form", q: "dune")
      |> render_change()

      assert_patch(view, ~p"/?q=dune")
      assert has_element?(view, "#torrents-#{dune.id}")
      refute has_element?(view, "#torrents-#{other.id}")
      assert has_element?(view, "#status-line", "1 match")
    end

    test "a search is a link", %{conn: conn} do
      dune = torrent_fixture(name: "Dune Part Two 1080p")
      {:ok, view, _html} = live(conn, ~p"/?q=part")

      assert has_element?(view, "#torrents-#{dune.id}")
      assert has_element?(view, "#q[value='part']")
    end
  end

  describe "category filter" do
    test "a chip filters, and clearing restores the list", %{conn: conn} do
      movie = torrent_fixture(name: "A Movie")
      show = torrent_fixture(name: "A Show", category: "Video - Television")

      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("#category-#{show.category_id}") |> render_click()

      assert_patch(view, ~p"/?category=#{show.category_id}")
      assert has_element?(view, "#torrents-#{show.id}")
      refute has_element?(view, "#torrents-#{movie.id}")
      assert has_element?(view, "#category-#{show.category_id}[aria-current='true']")

      view |> element("#clear-category") |> render_click()

      assert_patch(view, ~p"/")
      assert has_element?(view, "#torrents-#{movie.id}")
    end

    test "an unknown category is ignored", %{conn: conn} do
      movie = torrent_fixture()
      {:ok, view, _html} = live(conn, ~p"/?category=999999")
      assert has_element?(view, "#torrents-#{movie.id}")

      {:ok, view, _html} = live(conn, ~p"/?category=nope")
      assert has_element?(view, "#torrents-#{movie.id}")
    end
  end
end
