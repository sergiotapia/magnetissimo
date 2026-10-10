defmodule MagnetissimoWeb.ThemeControllerTest do
  # Not async: rendering the home page reads the index.
  use MagnetissimoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  setup :stub_sources

  describe "GET /theme/:mode" do
    test "remembers the pick and goes back to the page it came from", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://homelab.lan:4000/?q=dune&page=2")
        |> get(~p"/theme/dark")

      assert redirected_to(conn) == "/?q=dune&page=2"
      assert %{value: "dark", max_age: max_age} = conn.resp_cookies["theme"]
      assert max_age > 0
    end

    test "following the system forgets the pick", %{conn: conn} do
      conn = get(conn, ~p"/theme/system")

      assert redirected_to(conn) == "/"
      assert %{max_age: 0} = conn.resp_cookies["theme"]
    end

    test "ignores a mode it doesn't know", %{conn: conn} do
      conn = get(conn, ~p"/theme/sepia")

      assert redirected_to(conn) == "/"
      refute Map.has_key?(conn.resp_cookies, "theme")
    end

    test "never sends the reader to another host", %{conn: conn} do
      for referer <- ["http://evil.example//evil.example/x", "javascript:alert(1)", "nonsense"] do
        conn = conn |> put_req_header("referer", referer) |> get(~p"/theme/light")
        assert redirected_to(conn) == "/"
      end
    end
  end

  describe "the root layout" do
    test "draws the picked theme on <html>", %{conn: conn} do
      assert conn |> put_req_cookie("theme", "dark") |> theme_on_page() == "dark"
    end

    test "follows the system without a pick, or with one it doesn't know", %{conn: conn} do
      assert theme_on_page(conn) == "system"
      assert conn |> put_req_cookie("theme", "sepia") |> theme_on_page() == "system"
    end
  end

  test "the switch links each mode, so it works without JavaScript", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for mode <- ~w(system light dark) do
      assert has_element?(view, ~s(#theme-#{mode}[href="/theme/#{mode}"]))
    end

    assert has_element?(view, ~s(#theme-cycle-dark[href="/theme/system"]))
  end

  defp theme_on_page(conn) do
    conn
    |> get(~p"/")
    |> html_response(200)
    |> LazyHTML.from_document()
    |> LazyHTML.query("html")
    |> LazyHTML.attribute("data-theme")
    |> List.first()
  end
end
