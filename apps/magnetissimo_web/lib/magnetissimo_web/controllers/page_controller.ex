defmodule MagnetissimoWeb.PageController do
  use MagnetissimoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
