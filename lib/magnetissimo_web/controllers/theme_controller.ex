defmodule MagnetissimoWeb.ThemeController do
  @moduledoc """
  `GET /theme/:mode`, the theme switcher for readers without JavaScript.

  Each segment of the switcher is a plain link here. It sets the `theme`
  cookie through `MagnetissimoWeb.Theme` and sends the reader back to the
  page they were on. With JavaScript the switcher's hook handles the click
  in the browser and this is never asked.

  The way back is the `Referer`'s path and query only, so a forged header can
  never send the reader to another host.
  """
  use MagnetissimoWeb, :controller

  alias MagnetissimoWeb.Theme

  def update(conn, %{"mode" => mode}) do
    conn = if mode in Theme.modes(), do: Theme.put(conn, mode), else: conn
    redirect(conn, to: back_path(get_req_header(conn, "referer")))
  end

  # A path starting `//` would be read as another host, so it goes home too.
  defp back_path([referer | _rest]) do
    case URI.parse(referer) do
      %URI{path: "//" <> _rest} -> ~p"/"
      %URI{path: "/" <> _rest = path, query: nil} -> path
      %URI{path: "/" <> _rest = path, query: query} -> path <> "?" <> query
      _other -> ~p"/"
    end
  end

  defp back_path([]), do: ~p"/"
end
