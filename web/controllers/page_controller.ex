defmodule Magnetissimo.PageController do
  use Magnetissimo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
