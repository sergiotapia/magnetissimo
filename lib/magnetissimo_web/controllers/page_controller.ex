defmodule MagnetissimoWeb.PageController do
  use MagnetissimoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
