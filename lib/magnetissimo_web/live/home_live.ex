defmodule MagnetissimoWeb.HomeLive do
  @moduledoc """
  The home page: search, category filter, per-source status and the
  latest magnets.

  The URL is the state. Typing patches `?q=` and picking a category patches
  `?category=`, and `handle_params/3` loads from those, so a search is a link
  and the form still works as a plain GET without JavaScript.
  """
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Latest")
     |> assign(:tree, Torrents.list_category_tree())
     |> assign(:category_counts, Torrents.count_torrents_by_category())
     |> assign(:source_counts, Torrents.count_torrents_by_source())
     |> assign(:total, Torrents.count_torrents())
     |> assign(:latest_at, Torrents.latest_published_at())
     |> assign(:ticker, Enum.map(Torrents.list_latest_torrents(limit: 8), & &1.name))
     |> assign(:now, DateTime.utc_now())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    q = params |> Map.get("q", "") |> String.trim()
    category = lookup_category(params["category"], socket.assigns.tree)
    opts = if category, do: [category_id: category.id], else: []

    torrents =
      if q == "",
        do: Torrents.list_latest_torrents(opts),
        else: Torrents.search_torrents(q, opts)

    {:noreply,
     socket
     |> assign(:q, q)
     |> assign(:category, category)
     |> assign(:count, length(torrents))
     |> assign(:form, to_form(%{"q" => q}))
     |> assign(:now, DateTime.utc_now())
     |> stream(:torrents, torrents, reset: true)}
  end

  @impl true
  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, push_patch(socket, to: index_path(q, socket.assigns.category))}
  end

  defp lookup_category(nil, _tree), do: nil

  defp lookup_category(id, tree) when is_binary(id) do
    case Integer.parse(id) do
      {id, ""} ->
        tree
        |> Enum.flat_map(fn parent -> [parent | parent.children] end)
        |> Enum.find(&(&1.id == id))

      _ ->
        nil
    end
  end

  defp index_path(q, category) do
    params =
      []
      |> then(&if(String.trim(q) == "", do: &1, else: [{:q, q} | &1]))
      |> then(&if(category, do: [{:category, category.id} | &1], else: &1))

    ~p"/?#{params}"
  end

  # A parent is a heading for its children, except "Other", which has none
  # and holds torrents itself.
  defp filterable(%{children: []} = parent), do: [parent]
  defp filterable(parent), do: parent.children

  defp max_source_count([]), do: 1
  defp max_source_count(counts), do: counts |> Enum.map(&elem(&1, 1)) |> Enum.max() |> max(1)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section class="grid gap-5 lg:grid-cols-12">
        <%!-- Search --%>
        <div class="panel panel-hot animate-rise flex flex-col lg:col-span-8">
          <div class="panel-title">
            <span>Search</span>
            <span class="label">{number(@total)} magnets indexed</span>
          </div>

          <div class="relative p-6 sm:p-10">
            <.sparkle class="top-8 right-10 hidden size-7 text-cobalt-200 sm:block" />
            <.sparkle class="top-24 right-28 hidden size-3 text-lilac [animation-delay:1.4s] sm:block" />

            <h1 class="chrome-text w-fit pb-2 font-display text-[clamp(2.75rem,11vw,6.25rem)] leading-none font-semibold tracking-tight">
              Magnetissimo
            </h1>
            <p class="mt-3 max-w-xl text-base leading-relaxed text-ink-500 sm:text-lg">
              A self-hosted torrent index. Crawls {length(@source_counts)} sources, remembers every magnet it sees, speaks JSON to Sonarr and Radarr.
            </p>

            <.form
              for={@form}
              id="search-form"
              action={~p"/"}
              method="get"
              phx-change="search"
              phx-submit="search"
              class="mt-8"
            >
              <input :if={@category} type="hidden" name="category" value={@category.id} />
              <label for="q" class="sr-only">Search the index</label>
              <div class="well flex items-center gap-2 rounded-full p-1.5 pl-5 transition focus-within:shadow-[inset_0_2px_4px_rgba(31,63,209,0.12),0_0_0_3px_rgba(79,123,255,0.35)]">
                <.icon name="hero-magnifying-glass" class="size-5 shrink-0 text-cobalt-500" />
                <input
                  type="text"
                  id="q"
                  name="q"
                  value={@q}
                  autocomplete="off"
                  spellcheck="false"
                  autofocus
                  phx-debounce="200"
                  placeholder="Search the index…"
                  class="w-full min-w-0 bg-transparent py-2 text-lg font-semibold text-ink-900 outline-none sm:text-xl"
                />
                <button
                  type="submit"
                  class="gel focus-ring shrink-0 px-5 py-2.5 font-display text-sm font-bold tracking-[0.15em] uppercase"
                >
                  Go
                </button>
              </div>
            </.form>

            <p id="status-line" class="mt-4 pl-5 text-sm text-ink-500">
              <%= cond do %>
                <% @q != "" -> %>
                  <span class="font-bold text-cobalt-600">{@count}</span>
                  {if @count == 1, do: "match", else: "matches"} for
                  <span class="font-bold text-ink-900">“{@q}”</span>
                  <span :if={@category}>in {short_category(@category.name)}</span>
                <% @category -> %>
                  Showing
                  <span class="font-bold text-cobalt-600">{short_category(@category.name)}</span>
                <% true -> %>
                  Type to search, or pick a category below.
              <% end %>
            </p>
          </div>

          <div class="mt-auto grid grid-cols-[auto_auto_1fr] items-center gap-3 border-t border-frost-300/70 bg-white/40 px-6 py-2.5 sm:px-10">
            <.disc class="size-5" />
            <span class="label">Now spinning</span>
            <div class="ticker text-sm text-ink-700" aria-hidden="true">
              <div>
                <span :for={name <- @ticker ++ @ticker} class="pr-10">
                  <span class="mr-3 text-cobalt-400">✦</span>{name}
                </span>
              </div>
            </div>
          </div>
        </div>

        <%!-- Right column --%>
        <div class="grid gap-5 sm:grid-cols-2 lg:col-span-4 lg:grid-cols-1">
          <div class="panel panel-hot animate-rise [animation-delay:80ms]">
            <div class="panel-title">
              <span>Status</span>
              <span class="flex items-center gap-1.5 text-[0.65rem] tracking-[0.15em] text-mint">
                <span class="size-2 rounded-full bg-mint shadow-[0_0_0_3px_var(--color-mint-soft)]"></span>
                Online
              </span>
            </div>
            <div class="flex items-center gap-5 p-5">
              <.orb
                id="status-orb"
                seed={"#{@total}:#{length(@source_counts)}"}
                class="size-24 shrink-0 sm:size-28"
              />
              <dl class="flex-1 text-sm">
                <div class="spec-row">
                  <dt class="text-ink-500">Last crawl</dt>
                  <span class="leader"></span>
                  <dd class="font-bold text-ink-900">{ago(@latest_at, @now)}</dd>
                </div>
                <div class="spec-row">
                  <dt class="text-ink-500">Sources</dt>
                  <span class="leader"></span>
                  <dd class="font-bold text-ink-900">{length(@source_counts)}</dd>
                </div>
                <div class="spec-row">
                  <dt class="text-ink-500">Magnets</dt>
                  <span class="leader"></span>
                  <dd class="font-bold text-ink-900">{number(@total)}</dd>
                </div>
              </dl>
            </div>
          </div>

          <div id="sources" class="panel panel-hot animate-rise [animation-delay:160ms]">
            <div class="panel-title">
              <span>Sources</span>
              <span class="label">by magnets</span>
            </div>
            <ul class="space-y-3 p-5 text-sm">
              <li :for={{name, count} <- @source_counts}>
                <div class="flex items-baseline justify-between gap-3">
                  <span class="font-semibold text-ink-700">{name}</span>
                  <span class="font-mono text-xs text-ink-900 tabular-nums">{number(count)}</span>
                </div>
                <div class="well mt-1.5 h-2.5 rounded-full p-0.5">
                  <div
                    class="bar-fill h-full transition-[width] duration-700"
                    style={"width: #{round(count / max_source_count(@source_counts) * 100)}%"}
                  >
                  </div>
                </div>
              </li>
            </ul>
            <.signal id="status-signal" class="h-12 w-full" />
          </div>
        </div>
      </section>

      <%!-- Categories --%>
      <section id="categories" class="panel animate-rise mt-5 [animation-delay:240ms]">
        <div class="panel-title">
          <span>Categories</span>
          <.link
            :if={@category}
            patch={index_path(@q, nil)}
            id="clear-category"
            class="pill focus-ring px-2.5 py-1 font-sans text-[0.7rem] font-bold tracking-normal normal-case"
          >
            Clear filter ×
          </.link>
          <span :if={!@category} class="label">filter by category</span>
        </div>
        <div class="flex flex-wrap gap-x-10 gap-y-5 p-5 sm:p-6">
          <div :for={parent <- @tree} class="min-w-32">
            <h3 class="font-display text-xs font-bold tracking-[0.2em] text-ink-500 uppercase">
              {parent.name}
            </h3>
            <div class="mt-2 flex flex-wrap gap-1.5">
              <.category_chip
                :for={category <- filterable(parent)}
                name={category.name}
                patch={index_path(@q, category)}
                active={@category && @category.id == category.id}
                count={@category_counts[category.id]}
                id={"category-#{category.id}"}
              />
            </div>
          </div>
        </div>
      </section>

      <%!-- Results --%>
      <section id="results" class="panel animate-rise mt-5 [animation-delay:320ms]">
        <div class="panel-title">
          <span>{if @q == "", do: "Fresh magnets", else: "Search results"}</span>
          <span class="label">{@count} {if @count == 1, do: "magnet", else: "magnets"}</span>
        </div>

        <div
          class="label hidden grid-cols-[3rem_1fr_9rem_7rem_6rem_8rem_5rem_3rem] gap-3 border-b border-frost-300/70 px-5 py-2.5 md:grid"
          aria-hidden="true"
        >
          <span>#</span>
          <span>Name</span>
          <span>Category</span>
          <span>Source</span>
          <span class="text-right">Size</span>
          <span>Swarm</span>
          <span class="text-right">Age</span>
          <span class="text-right">Link</span>
        </div>

        <ol id="torrents" phx-update="stream" class="divide-y divide-frost-200 p-1.5">
          <li
            id="torrents-empty"
            class="hidden p-12 text-center text-lg text-ink-500 only:block"
          >
            Nothing matches. Try another word ✦
          </li>
          <li
            :for={{id, torrent} <- @streams.torrents}
            id={id}
            class="group relative grid gap-x-3 gap-y-2 rounded-2xl px-3.5 py-3 transition hover:bg-white/80 hover:shadow-[0_6px_16px_-10px_rgba(31,63,209,0.4)] md:grid-cols-[3rem_1fr_9rem_7rem_6rem_8rem_5rem_3rem] md:items-center"
          >
            <span class="hidden font-mono text-xs text-ink-300 md:block">{ordinal(torrent.id)}</span>

            <h2 class="min-w-0 text-sm leading-snug font-semibold text-ink-900">
              <.link
                navigate={~p"/torrents/#{torrent}"}
                class="focus-ring block truncate transition group-hover:text-cobalt-600"
                title={torrent.name}
              >
                {torrent.name}
              </.link>
            </h2>

            <div class="flex flex-wrap items-center gap-x-3 gap-y-1.5 md:contents">
              <span><.category_chip name={torrent.category.name} /></span>
              <span class="label">{torrent.source.name}</span>
              <span class="font-mono text-xs text-ink-700 tabular-nums md:text-right">
                {bytes(torrent.size_in_bytes)}
              </span>
            </div>
            <div class="flex items-center gap-4 md:contents">
              <.swarm seeders={torrent.seeders} leechers={torrent.leechers} class="w-32 md:w-auto" />
              <span class="font-mono text-xs text-ink-500 tabular-nums md:text-right">
                {ago(torrent.published_at, @now)}
              </span>
              <a
                href={torrent.magnet_url}
                class="gel focus-ring ml-auto inline-flex size-8 items-center justify-center md:justify-self-end"
                title="Open magnet link"
                aria-label={"Magnet link for #{torrent.name}"}
              >
                <.magnet_icon class="size-4" />
              </a>
            </div>
          </li>
        </ol>
      </section>
    </Layouts.app>
    """
  end
end
