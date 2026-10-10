defmodule MagnetissimoWeb.Theme do
  @moduledoc """
  The reader's light or dark preference, kept in a plain `theme` cookie.

  The cookie holds `"light"` or `"dark"`. Without it the page follows the
  system's `prefers-color-scheme`, which is the `"system"` mode. As a plug
  this reads the cookie into `conn.assigns.theme`, and the root layout writes
  it to `<html data-theme>`, so the first paint is already in the right theme:
  no flash, and no inline script deciding it before the CSS applies.

  The cookie is unsigned on purpose. The theme switch's hook in
  `MagnetissimoWeb.Layouts` writes it from the browser, and an unknown value
  only ever falls back to `"system"`. `MagnetissimoWeb.ThemeController` sets
  it for readers without JavaScript.
  """
  @behaviour Plug

  import Plug.Conn

  @cookie "theme"
  @modes ~w(system light dark)
  # A year, refreshed every time the reader picks.
  @max_age 60 * 60 * 24 * 365

  @doc "The modes, in the order the switcher shows them."
  def modes, do: @modes

  @doc "The mode a `theme` cookie value stands for."
  def parse(value) when value in ["light", "dark"], do: value
  def parse(_missing_or_unknown), do: "system"

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    conn = fetch_cookies(conn)
    assign(conn, :theme, parse(conn.cookies[@cookie]))
  end

  @doc """
  Remembers `mode` for this browser. `"system"` forgets the choice.
  """
  def put(conn, "system"), do: delete_resp_cookie(conn, @cookie)

  def put(conn, mode) when mode in ["light", "dark"] do
    put_resp_cookie(conn, @cookie, mode,
      max_age: @max_age,
      same_site: "Lax",
      http_only: false,
      sign: false
    )
  end
end
