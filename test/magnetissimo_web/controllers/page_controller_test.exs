defmodule MagnetissimoWeb.PageControllerTest do
  use MagnetissimoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Magnetissimo"
  end
end
