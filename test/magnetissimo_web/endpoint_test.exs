defmodule MagnetissimoWeb.EndpointTest do
  use MagnetissimoWeb.ConnCase, async: true

  # The LiveView socket's origin check, as a browser's handshake meets it. A
  # test conn can't upgrade, so an accepted origin ends in a 400 and a
  # refused one in a 403.
  defp handshake(conn, origin) do
    conn
    |> put_req_header("origin", origin)
    |> get("/live/websocket?vsn=2.0.0")
  end

  describe "the LiveView socket" do
    @tag :capture_log
    test "accepts the host it is reached at, and only that", %{conn: conn} do
      assert handshake(conn, "http://www.example.com").status == 400
      assert handshake(conn, "http://other.example.com").status == 403
      assert handshake(conn, "https://www.example.com").status == 403
    end

    @tag :capture_log
    test "accepts an https page behind a TLS-ending proxy", %{conn: conn} do
      proxied = put_req_header(conn, "x-forwarded-proto", "https")

      assert handshake(proxied, "https://www.example.com").status == 400
      assert handshake(proxied, "https://other.example.com").status == 403
    end
  end
end
