defmodule MagnetissimoWeb.Layouts do
  @moduledoc """
  Page layouts.

  `root.html.heex` (embedded from `layouts/`) is the HTML skeleton: the CSRF
  meta tag, `app.css` and `app.js`. `app/1` is the frame every page renders
  inside: the BIOS bar, the nav, the hex legend, the footer and the CRT glass
  over everything. `flash_group/1` shows flash messages plus the client- and
  server-error notices.
  """
  use MagnetissimoWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @version Mix.Project.config()[:version]

  # The legend at the top of the page is the palette, the way the Blue Flax
  # poster prints its own hex codes in the margin.
  @palette [
    {"#04050A", "bg-ink-950"},
    {"#6699FF", "bg-phos-500"},
    {"#99CCFF", "bg-phos-300"},
    {"#CCCC33", "bg-acid"},
    {"#FF6B9D", "bg-rose"},
    {"#E4F0FF", "bg-phos-100"}
  ]

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, version: @version, palette: @palette)

    ~H"""
    <div class="crt-scanlines" aria-hidden="true"></div>
    <div class="crt-vignette" aria-hidden="true"></div>
    <div class="crt-sweep" aria-hidden="true"></div>

    <div class="relative mx-auto flex min-h-dvh max-w-7xl flex-col px-4 sm:px-6 lg:px-8">
      <header class="pt-4 sm:pt-6">
        <%!-- BIOS line --%>
        <div class="label flex flex-wrap items-center justify-between gap-x-6 gap-y-1 text-phos-500">
          <span class="flex items-center gap-2">
            <span class="inline-block size-1.5 animate-pulse-glow bg-acid shadow-[0_0_8px_#cccc33]"></span>
            Magnetissimo (TM)
          </span>
          <span class="hidden sm:inline">Self-hosted index</span>
          <span class="hidden md:inline">Research</span>
          <span>Ver v{@version}</span>
          <span class="hidden sm:inline">Port......4000</span>
        </div>

        <%!-- Nav --%>
        <nav
          id="nav"
          class="dossier mt-3 flex items-center justify-between gap-2 border-y border-phos-500/30 py-1.5 text-xl sm:text-2xl"
          aria-label="Primary"
        >
          <.nav_link navigate={~p"/"} id="nav-latest">Latest</.nav_link>
          <.nav_link href={~p"/#categories"} id="nav-categories">Categories</.nav_link>
          <.nav_link href={~p"/#sources"} id="nav-sources">Sources</.nav_link>
          <.nav_link href={~p"/api/latest"} id="nav-api">API</.nav_link>
          <.nav_link href="https://github.com/sergiotapia/magnetissimo" id="nav-source">
            More+
          </.nav_link>
        </nav>

        <%!-- Hex legend --%>
        <div class="label mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-phos-700 sm:justify-between">
          <span :for={{hex, class} <- @palette} class="flex items-center gap-1.5">
            <span class={["inline-block size-2 border border-phos-700/60", class]}></span>
            {hex}
          </span>
        </div>
      </header>

      <main class="flex-1 py-6 sm:py-8">
        {render_slot(@inner_block)}
      </main>

      <footer class="label mb-6 flex flex-wrap items-center justify-between gap-x-6 gap-y-2 border-t border-phos-500/30 pt-3 text-phos-700">
        <span>All data on non-removable disk</span>
        <span class="hidden sm:inline">No accounts · No tracking · No JavaScript required</span>
        <span>
          <a href={~p"/api/latest"} class="hover:text-phos-300">/api/latest</a>
          <span class="mx-1">·</span>
          <a href={~p"/api/search/1080p"} class="hover:text-phos-300">/api/search/:term</a>
        </span>
        <span>(c) {DateTime.utc_now().year} Magnetissimo</span>
      </footer>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :id, :string, required: true
  attr :rest, :global, include: ~w(href navigate)
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      id={@id}
      class="focus-phos px-1 text-phos-300 hover:text-phos-100 hover:glow sm:px-3"
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("Signal lost")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Reacquiring the server")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
