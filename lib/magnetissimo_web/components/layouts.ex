defmodule MagnetissimoWeb.Layouts do
  @moduledoc """
  Page layouts.

  `root.html.heex` (embedded from `layouts/`) is the HTML skeleton: the CSRF
  meta tag, `app.css` and `app.js`, and `data-theme` on `<html>` from the
  reader's `theme` cookie (see `MagnetissimoWeb.Theme`). `app/1` is the frame
  every page renders inside: the sky, the nav with the theme switch, and the
  content. `flash_group/1` shows flash messages plus the client- and
  server-error notices.
  """
  use MagnetissimoWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

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
    ~H"""
    <div class="sky" aria-hidden="true">
      <div class="ceiling"></div>
      <.sparkle class="top-[14%] left-[6%] size-5" />
      <.sparkle class="top-[8%] right-[18%] size-3 [animation-delay:1.2s]" />
      <.sparkle class="top-[52%] right-[4%] size-6 [animation-delay:2.1s]" />
      <.sparkle class="bottom-[12%] left-[10%] size-4 [animation-delay:0.6s]" />
    </div>

    <div class="relative z-10 mx-auto flex min-h-dvh max-w-7xl flex-col px-4 sm:px-6 lg:px-8">
      <header class="pt-4 sm:pt-6">
        <%!-- The links scroll sideways on a phone; the theme switch stays put. --%>
        <div class="panel flex items-center gap-1 py-1.5 pr-1.5 pl-1.5 sm:gap-3 sm:pl-3">
          <nav
            id="nav"
            class="flex min-w-0 flex-1 items-center justify-between gap-0.5 overflow-x-auto [scrollbar-width:none] max-sm:[mask-image:linear-gradient(to_right,#000_calc(100%-1.25rem),transparent)]"
            aria-label="Primary"
          >
            <.nav_link navigate={~p"/"} id="nav-latest">Latest</.nav_link>
            <.nav_link href={~p"/#categories"} id="nav-categories">Categories</.nav_link>
            <.nav_link href={~p"/#sources"} id="nav-sources">Sources</.nav_link>
            <.nav_link navigate={~p"/dht"} id="nav-dht">DHT</.nav_link>
            <.nav_link href={~p"/api/latest"} id="nav-api">API</.nav_link>
            <.nav_link href="https://github.com/sergiotapia/magnetissimo" id="nav-source">
              More+
            </.nav_link>
          </nav>
          <.theme_switch />
        </div>
      </header>

      <main class="flex-1 pt-6 pb-10 sm:pt-8 sm:pb-12">
        {render_slot(@inner_block)}
      </main>
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
      class="focus-ring shrink-0 rounded-full px-1.5 py-1.5 font-display text-[0.68rem] font-bold tracking-[0.06em] text-ink-700 uppercase transition hover:bg-glass hover:text-azure-600 hover:shadow-[0_4px_12px_-6px_rgba(42,115,168,0.45)] sm:px-5 sm:text-sm sm:tracking-[0.2em]"
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  The `theme-color` metas for the root layout, as `{scheme, colour, media}`.

  Both are always rendered so the switch's hook can flip them: following the
  system, each answers to its `prefers-color-scheme`; with a pick, the picked
  one matches `all` and the other `not all`.
  """
  def theme_colors(theme) do
    for {scheme, color} <- [{"light", "#e7f3f7"}, {"dark", "#07131f"}] do
      media =
        cond do
          theme in [nil, "system"] -> "(prefers-color-scheme: #{scheme})"
          theme == scheme -> "all"
          true -> "not all"
        end

      {scheme, color, media}
    end
  end

  # Each mode with its icon, its name, and the mode a phone's single button
  # moves on to from it.
  @theme_options [
    {"system", "hero-computer-desktop-mini", "Match the system", "light"},
    {"light", "hero-sun-mini", "Light", "dark"},
    {"dark", "hero-moon-mini", "Dark", "system"}
  ]

  # The light/dark switch: three links on a recessed track, with a gel thumb
  # that CSS slides under whichever mode `<html data-theme>` names. The page
  # never has to know the theme to draw it. A phone has no room for the
  # track beside the nav, so it gets one gel button per mode instead: CSS
  # shows the current mode's, and it links to the next mode.
  #
  # Without JavaScript each link goes through `ThemeController`, which sets
  # the cookie and comes back. With it, the hook writes the cookie itself and
  # flips `data-theme` in place, revealing the new theme in a circle that
  # grows from the button, unless the reader prefers reduced motion.
  defp theme_switch(assigns) do
    assigns = assign(assigns, :options, @theme_options)

    ~H"""
    <div
      id="theme-switch"
      class="shrink-0"
      role="group"
      aria-label="Theme"
      phx-hook=".ThemeSwitch"
      phx-update="ignore"
    >
      <div class="theme-switch well">
        <span class="theme-switch-thumb gel" aria-hidden="true"></span>
        <a
          :for={{mode, icon, title, _next} <- @options}
          href={~p"/theme/#{mode}"}
          id={"theme-#{mode}"}
          data-mode={mode}
          class="focus-ring"
          title={title}
          aria-label={"#{title} theme"}
          rel="nofollow"
        >
          <.icon name={icon} class="size-4" />
        </a>
      </div>
      <a
        :for={{mode, icon, title, next} <- @options}
        href={~p"/theme/#{next}"}
        id={"theme-cycle-#{mode}"}
        data-mode={next}
        data-when={mode}
        class="theme-cycle gel focus-ring"
        title={"#{title}. Switch to #{next}"}
        aria-label={"Theme: #{String.downcase(title)}. Switch to #{next}"}
        rel="nofollow"
      >
        <.icon name={icon} class="size-4" />
      </a>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".ThemeSwitch">
      const YEAR = 60 * 60 * 24 * 365
      const dark = window.matchMedia("(prefers-color-scheme: dark)")
      const calm = window.matchMedia("(prefers-reduced-motion: reduce)")

      const resolve = mode => mode === "system" ? (dark.matches ? "dark" : "light") : mode

      export default {
        mounted() {
          this.mark(document.documentElement.dataset.theme || "system")
          this.el.addEventListener("click", event => {
            const link = event.target.closest("a[data-mode]")
            if (!link || event.metaKey || event.ctrlKey || event.shiftKey) return
            event.preventDefault()
            this.pick(link.dataset.mode, link)
          })
        },

        pick(mode, origin) {
          const root = document.documentElement
          const before = resolve(root.dataset.theme || "system")
          const apply = () => {
            root.dataset.theme = mode
            this.remember(mode)
            this.mark(mode)
          }

          if (before === resolve(mode) || calm.matches || !document.startViewTransition) {
            apply()
            return
          }

          // The new theme grows out of the button that was pressed.
          const box = origin.getBoundingClientRect()
          const x = box.left + box.width / 2
          const y = box.top + box.height / 2
          const reach = Math.hypot(Math.max(x, innerWidth - x), Math.max(y, innerHeight - y))

          root.dataset.turning = ""
          const turn = document.startViewTransition(apply)
          // `ready` rejects when the browser skips the transition, say in a
          // hidden tab. The theme has still changed by then.
          turn.ready.then(() => {
            root.animate(
              {clipPath: [`circle(0px at ${x}px ${y}px)`, `circle(${reach}px at ${x}px ${y}px)`]},
              {duration: 650, easing: "cubic-bezier(0.2, 0.7, 0.2, 1)", pseudoElement: "::view-transition-new(root)"}
            )
          }, () => {})
          turn.finished.finally(() => delete root.dataset.turning)
        },

        remember(mode) {
          document.cookie = mode === "system"
            ? "theme=; path=/; max-age=0; samesite=lax"
            : `theme=${mode}; path=/; max-age=${YEAR}; samesite=lax`

          for (const meta of document.querySelectorAll("meta[name=theme-color][data-scheme]")) {
            const scheme = meta.dataset.scheme
            meta.media = mode === "system"
              ? `(prefers-color-scheme: ${scheme})`
              : (scheme === mode ? "all" : "not all")
          }
        },

        mark(mode) {
          for (const link of this.el.querySelectorAll(".theme-switch a[data-mode]")) {
            if (link.dataset.mode === mode) link.setAttribute("aria-current", "true")
            else link.removeAttribute("aria-current")
          }
        },
      }
    </script>
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
