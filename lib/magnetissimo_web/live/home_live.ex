defmodule MagnetissimoWeb.HomeLive do
  @moduledoc """
  The home page: search, category filter, per-source status and the
  latest magnets.

  The URL is the state. Typing patches `?q=`, picking a category patches
  `?category=` and the pager patches `?page=`, and `handle_params/3` loads
  from those, so a search is a link and the form still works as a plain GET
  without JavaScript.
  """
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Crawlers.Nyaa
  alias Magnetissimo.Crawlers.Sukebei
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.Torrents

  @source_crawlers [Yts, Nyaa, Sukebei, TorrentDownloads]

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
     |> assign(:searching, nil)
     |> assign(:search_task, nil)
     |> assign(:now, DateTime.utc_now())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    q = params |> Map.get("q", "") |> String.trim()
    category = lookup_category(params["category"], socket.assigns.tree)

    # Patching to a different term abandons whatever the source was asked for.
    socket = if socket.assigns.searching == q, do: socket, else: clear_search(socket)

    {:noreply, load_results(socket, q, category, page_param(params["page"]))}
  end

  # Typing patches the URL and, once the reader pauses, reaches out to the
  # sources. `phx-debounce` on the input is what keeps that to one lookup per
  # pause rather than one per keystroke; pressing enter cancels the pending
  # timer and takes the immediate `submit` path instead.
  @impl true
  def handle_event("search", %{"q" => q}, socket), do: lookup(socket, q)
  def handle_event("submit", %{"q" => q}, socket), do: lookup(socket, q)

  defp lookup(socket, q) do
    q = String.trim(q)

    {:noreply,
     socket
     |> assign(:q, q)
     |> ask_source(q)
     |> push_patch(to: index_path(q, socket.assigns.category))}
  end

  @impl true
  def handle_info({:source_search, term, :updated}, socket) do
    # A batch for a term the reader has already moved on from is dropped, so a
    # slow lookup for an earlier term cannot redraw the list under a newer one.
    # The rows are in the index either way, so the next search finds them.
    socket = if term == socket.assigns.q, do: reload_results(socket), else: socket

    {:noreply, socket}
  end

  def handle_info({:source_search, _term, :done}, socket), do: {:noreply, socket}

  # The lookup task runs every source in turn, so its exit is the last word on
  # the term, whatever each source turned up. A task whose pid is no longer the
  # current one belongs to a term the reader has moved on from, so its exit
  # neither clears the in-flight state nor reloads the list.
  def handle_info({:DOWN, _ref, :process, pid, _reason}, socket) do
    socket =
      if pid == socket.assigns.search_task do
        socket |> clear_search() |> reload_results()
      else
        socket
      end

    {:noreply, socket}
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

  defp page_param(nil), do: 1

  defp page_param(value) do
    case Integer.parse(value) do
      {page, ""} when page > 0 -> page
      _ -> 1
    end
  end

  defp page_opts(page) do
    [limit: Torrents.per_page(), offset: (page - 1) * Torrents.per_page()]
  end

  # Everything the results panel shows is derived from the query, the category
  # and the page, so a URL patch and a fresh batch of hits from the source both
  # come through here.
  defp load_results(socket, q, category, page) do
    opts = if category, do: [category_id: category.id], else: []

    count =
      if q == "",
        do: Torrents.count_torrents(opts),
        else: Torrents.count_search_torrents(q, opts)

    pages = max(1, ceil(count / Torrents.per_page()))
    page = min(page, pages)

    torrents =
      if q == "",
        do: Torrents.list_latest_torrents(opts ++ page_opts(page)),
        else: Torrents.search_torrents(q, opts ++ page_opts(page))

    socket
    |> assign(:q, q)
    |> assign(:category, category)
    |> assign(:page, page)
    |> assign(:pages, pages)
    |> assign(:count, count)
    |> assign(:form, to_form(%{"q" => q}))
    |> assign(:now, DateTime.utc_now())
    |> stream(:torrents, torrents, reset: true)
  end

  defp reload_results(socket) do
    load_results(socket, socket.assigns.q, socket.assigns.category, socket.assigns.page)
  end

  # Every source is asked in one background task, in turn, so the results on
  # screen stay interactive and only one process writes to SQLite at a time.
  # The answers arrive as `handle_info/2` messages and reload them. A term
  # already in flight is not asked for twice.
  #
  # The task's pid is kept on the socket so the in-flight work is part of the
  # socket's state, which is also what lets a test wait on it instead of
  # sleeping.
  defp ask_source(socket, q) do
    if q == "" or not connected?(socket) or socket.assigns.searching == q do
      socket
    else
      parent = self()

      {:ok, pid} =
        Task.start(fn ->
          Enum.each(@source_crawlers, & &1.search(q, notify: parent))
        end)

      Process.monitor(pid)
      assign(socket, searching: q, search_task: pid)
    end
  end

  defp clear_search(socket), do: assign(socket, searching: nil, search_task: nil)

  defp index_path(q, category, page \\ 1) do
    params =
      []
      |> then(&if(String.trim(q) == "", do: &1, else: [{:q, q} | &1]))
      |> then(&if(category, do: [{:category, category.id} | &1], else: &1))
      |> then(&if(page > 1, do: [{:page, page} | &1], else: &1))

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
      <div class="grid gap-5 lg:grid-cols-[18rem_minmax(0,1fr)] lg:items-start xl:grid-cols-[20rem_minmax(0,1fr)]">
        <%!-- Sidebar: status, sources, categories. Below search on small screens. --%>
        <aside class="grid content-start gap-5 max-lg:order-2 sm:grid-cols-2 lg:grid-cols-1">
          <div class="panel panel-hot animate-rise [animation-delay:80ms]">
            <div class="panel-title">
              <span>Status</span>
              <span class="flex items-center gap-1.5 text-[0.65rem] tracking-[0.15em] text-mint">
                <span class="size-2 rounded-full bg-mint shadow-[0_0_0_3px_var(--color-mint-soft)]"></span>
                Online
              </span>
            </div>
            <div class="flex items-center gap-4 p-5">
              <.orb
                id="status-orb"
                seed={"#{@total}:#{length(@source_counts)}"}
                class="size-20 shrink-0"
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

          <section
            id="categories"
            class="panel animate-rise [animation-delay:240ms] sm:col-span-2 lg:col-span-1"
          >
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
            <div class="space-y-4 p-5">
              <div :for={parent <- @tree}>
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
        </aside>

        <%!-- Main: search, then the results. --%>
        <div class="flex min-w-0 flex-col gap-5 max-lg:contents">
          <div class="panel animate-rise flex flex-col max-lg:order-1">
            <div class="panel-title">
              <span>Search</span>
              <span class="label">{number(@total)} magnets indexed</span>
            </div>

            <div class="relative p-6 sm:p-10">
              <.sparkle class="top-8 right-10 hidden size-7 text-white sm:block" />
              <.sparkle class="top-24 right-28 hidden size-3 text-aqua [animation-delay:1.4s] sm:block" />

              <h1 id="site-wordmark" class="mx-auto w-full max-w-[640px]">
                <img
                  src={~p"/images/wordmark.webp"}
                  alt="Magnetissimo"
                  width="1549"
                  height="257"
                  class="h-auto w-full"
                />
              </h1>

              <.form
                for={@form}
                id="search-form"
                action={~p"/"}
                method="get"
                phx-change="search"
                phx-submit="submit"
                class="mt-8"
              >
                <input :if={@category} type="hidden" name="category" value={@category.id} />
                <label for="q" class="sr-only">Search the index</label>
                <div class="well flex items-center gap-2 rounded-full p-1.5 pl-5 transition focus-within:shadow-[inset_0_2px_4px_rgba(31,63,209,0.12),0_0_0_3px_rgba(79,123,255,0.35)]">
                  <.icon name="hero-magnifying-glass" class="size-5 shrink-0 text-azure-500" />
                  <input
                    type="text"
                    id="q"
                    name="q"
                    value={@q}
                    autocomplete="off"
                    spellcheck="false"
                    autofocus
                    phx-debounce="400"
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

              <p :if={@q != "" or !@category} id="status-line" class="mt-4 pl-5 text-sm text-ink-500">
                <%= if @q != "" do %>
                  <span class="font-bold text-azure-600">{@count}</span>
                  {if @count == 1, do: "match", else: "matches"} for
                  <span class="font-bold text-ink-900">“{@q}”</span>
                  <span :if={@category}>in {@category.name}</span>
                <% else %>
                  Type to search, or pick a category.
                <% end %>
              </p>

              <p
                :if={@searching}
                id="source-search"
                class="mt-3 flex items-center gap-2 pl-5 text-sm text-ink-500"
              >
                <span class="size-1.5 animate-pulse rounded-full bg-azure-400 motion-reduce:animate-none"></span>
                <span>
                  Asking the source for <span class="font-bold text-ink-900">“{@searching}”</span>
                </span>
              </p>
            </div>

            <div class="mt-auto grid grid-cols-[auto_auto_1fr] items-center gap-3 border-t border-frost-300/70 bg-white/40 px-6 py-2.5 sm:px-10">
              <.disc class="size-5" />
              <span class="label">Now spinning</span>
              <div class="ticker text-sm text-ink-700" aria-hidden="true">
                <div>
                  <span :for={name <- @ticker ++ @ticker} class="pr-10">
                    <span class="mr-3 text-azure-400">✦</span>{name}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <section id="results" class="panel animate-rise [animation-delay:320ms] max-lg:order-3">
            <div class="panel-title">
              <span>{if @q == "", do: "Fresh magnets", else: "Search results"}</span>
              <span class="label">
                {@count} {if @count == 1, do: "magnet", else: "magnets"}
                <%= if @pages > 1 do %>
                  · page {@page}/{@pages}
                <% end %>
              </span>
            </div>

            <div
              class="label hidden grid-cols-[minmax(0,1fr)_5.5rem_7.5rem_4.5rem_2rem] gap-4 border-b border-frost-300/70 px-5 py-2.5 md:grid"
              aria-hidden="true"
            >
              <span>Name</span>
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
                class="animate-rise group grid gap-x-4 gap-y-2.5 rounded-2xl px-3.5 py-3 transition hover:bg-white/80 hover:shadow-[0_6px_16px_-10px_rgba(31,63,209,0.4)] md:grid-cols-[minmax(0,1fr)_5.5rem_7.5rem_4.5rem_2rem] md:items-center"
              >
                <div class="min-w-0">
                  <h2 class="text-sm leading-snug font-semibold text-ink-900">
                    <.link
                      navigate={~p"/torrents/#{torrent}"}
                      class="focus-ring block truncate transition group-hover:text-azure-600"
                      title={torrent.name}
                    >
                      {torrent.name}
                    </.link>
                  </h2>
                  <div class="mt-1.5 flex items-center gap-2.5">
                    <.category_chip name={torrent.category.name} />
                    <span class="label">{torrent.source.name}</span>
                  </div>
                </div>

                <div class="flex items-center gap-4 md:contents">
                  <span class="font-mono text-xs text-ink-700 tabular-nums md:text-right">
                    {bytes(torrent.size_in_bytes)}
                  </span>
                  <.swarm
                    seeders={torrent.seeders}
                    leechers={torrent.leechers}
                    class="w-28 md:w-auto"
                  />
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

            <div
              :if={@pages > 1}
              id="pagination"
              class="flex items-center justify-between gap-3 border-t border-frost-300/70 px-5 py-3"
            >
              <.link
                id="page-prev"
                patch={index_path(@q, @category, @page - 1)}
                aria-disabled={@page == 1 && "true"}
                class={[
                  "pill focus-ring px-3.5 py-1.5 font-display text-xs font-bold tracking-[0.15em] uppercase",
                  @page == 1 && "pointer-events-none opacity-40"
                ]}
              >
                ← Prev
              </.link>

              <span class="label">page {@page} of {@pages}</span>

              <.link
                id="page-next"
                patch={index_path(@q, @category, @page + 1)}
                aria-disabled={@page == @pages && "true"}
                class={[
                  "pill focus-ring px-3.5 py-1.5 font-display text-xs font-bold tracking-[0.15em] uppercase",
                  @page == @pages && "pointer-events-none opacity-40"
                ]}
              >
                Next →
              </.link>
            </div>
          </section>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
