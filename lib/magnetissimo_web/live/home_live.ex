defmodule MagnetissimoWeb.HomeLive do
  @moduledoc """
  The index terminal: search, category filter, per-source status and the
  latest intercepts.

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
     |> assign(:page_title, "Index terminal")
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
      <section class="grid gap-4 lg:grid-cols-12">
        <%!-- Terminal --%>
        <div class="panel panel-hot animate-boot flex flex-col lg:col-span-8">
          <div class="panel-title">
            <span>|--terminal|</span>
            <span class="label text-phos-500">{number(@total)} records on disk</span>
          </div>

          <div class="p-5 sm:p-8">
            <h1 class="font-display text-[clamp(2.75rem,11vw,6rem)] font-light tracking-tight text-phos-100 glow-lg">
              Magnet<span class="text-phos-300">issimo</span>
            </h1>
            <p class="mt-3 max-w-xl font-display text-base text-phos-300/90 sm:text-lg">
              <span class="text-phos-500">(</span>
              a self-hosted torrent index. Crawls {length(@source_counts)} sources, remembers every magnet it sees, speaks JSON to Sonarr and Radarr.
              <span class="text-phos-500">)</span>
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
              <label for="q" class="label block text-phos-500">Query</label>
              <div class="mt-1 flex items-center gap-3 border-b-2 border-phos-500/50 transition focus-within:border-phos-300 focus-within:shadow-[0_8px_24px_-12px_rgba(153,204,255,0.6)]">
                <span class="dossier text-3xl text-phos-300 glow" aria-hidden="true">&gt;</span>
                <input
                  type="text"
                  id="q"
                  name="q"
                  value={@q}
                  autocomplete="off"
                  spellcheck="false"
                  autofocus
                  phx-debounce="200"
                  placeholder="search the index_"
                  class="dossier w-full bg-transparent py-2 text-3xl text-phos-100 placeholder-phos-700 outline-none glow"
                />
                <button
                  type="submit"
                  class="label focus-phos shrink-0 border border-phos-500/50 px-2 py-1.5 text-phos-300 transition hover:border-phos-300 hover:bg-phos-500/10 hover:text-phos-100"
                >
                  Enter
                </button>
              </div>
            </.form>

            <p id="status-line" class="dossier mt-4 text-lg text-phos-500">
              <%= cond do %>
                <% @q != "" -> %>
                  <span class="text-phos-300 glow">{@count}</span>
                  {if @count == 1, do: "match", else: "matches"} for
                  <span class="text-phos-100 glow">"{@q}"</span>
                  <span :if={@category}>in {short_category(@category.name)}</span>
                  <span class="cursor"></span>
                <% @category -> %>
                  Showing <span class="text-phos-300 glow">{short_category(@category.name)}</span>
                  <span class="cursor"></span>
                <% true -> %>
                  Ready for query<span class="cursor"></span>
              <% end %>
            </p>
          </div>

          <div class="dossier mt-auto grid grid-cols-[auto_1fr] items-center gap-3 border-t border-phos-500/30 px-5 py-2 text-lg sm:px-8">
            <span class="label text-phos-700">Bank 1</span>
            <div class="ticker text-phos-300" aria-hidden="true">
              <div>
                <span :for={name <- @ticker ++ @ticker} class="pr-10">
                  <span class="mr-3 inline-block size-2 bg-phos-500 align-middle"></span>{name}
                </span>
              </div>
            </div>
          </div>
        </div>

        <%!-- Right column --%>
        <div class="grid gap-4 sm:grid-cols-2 lg:col-span-4 lg:grid-cols-1">
          <div class="panel panel-hot animate-boot [animation-delay:80ms]">
            <div class="panel-title">
              <span>Receiver</span>
              <span class="flex gap-1" aria-hidden="true">
                <span class="size-2 rounded-full border border-phos-300"></span>
                <span class="size-2 rounded-full border border-phos-300"></span>
                <span class="size-2 rounded-full bg-phos-300 shadow-[0_0_6px_#99ccff]"></span>
              </span>
            </div>
            <div class="flex items-center gap-4 p-4">
              <canvas
                id="receiver-orb"
                phx-hook="Dither"
                phx-update="ignore"
                data-seed={"#{@total}:#{length(@source_counts)}"}
                class="pixelated size-28 shrink-0 drop-shadow-[0_0_12px_rgba(102,153,255,0.6)] sm:size-32"
                aria-hidden="true"
              ></canvas>
              <dl class="dossier flex-1 text-lg leading-tight">
                <div class="dossier-row">
                  <dt class="text-phos-500">Signal</dt>
                  <span class="leader"></span>
                  <dd class="text-acid glow-acid">Lock</dd>
                </div>
                <div class="dossier-row">
                  <dt class="text-phos-500">Last seen</dt>
                  <span class="leader"></span>
                  <dd class="text-phos-100">{ago(@latest_at, @now)}</dd>
                </div>
                <div class="dossier-row">
                  <dt class="text-phos-500">Sources</dt>
                  <span class="leader"></span>
                  <dd class="text-phos-100">{length(@source_counts)} / {length(@source_counts)}</dd>
                </div>
              </dl>
            </div>
          </div>

          <div id="sources" class="panel panel-hot animate-boot [animation-delay:160ms]">
            <div class="panel-title">
              <span>Index status</span>
              <span class="label text-phos-500">by source</span>
            </div>
            <ul class="dossier p-4 text-lg">
              <li :for={{name, count} <- @source_counts} class="py-1.5">
                <div class="flex items-baseline justify-between gap-3">
                  <span class="text-phos-200">{name}</span>
                  <span class="text-phos-100 tabular-nums glow">{number(count)}</span>
                </div>
                <div class="mt-1 h-1.5 bg-phos-900">
                  <div
                    class="h-full bg-phos-500 shadow-[0_0_8px_rgba(102,153,255,0.9)] transition-[width] duration-700"
                    style={"width: #{round(count / max_source_count(@source_counts) * 100)}%"}
                  >
                  </div>
                </div>
              </li>
            </ul>
            <.signal id="status-signal" class="h-12 w-full border-t border-phos-500/30" />
          </div>
        </div>
      </section>

      <%!-- Categories --%>
      <section id="categories" class="panel animate-boot mt-4 [animation-delay:240ms]">
        <div class="panel-title">
          <span>Function</span>
          <.link
            :if={@category}
            patch={index_path(@q, nil)}
            id="clear-category"
            class="label text-acid hover:text-acid-bright"
          >
            Clear filter ×
          </.link>
          <span :if={!@category} class="label text-phos-500">filter by category</span>
        </div>
        <div class="flex flex-wrap gap-x-8 gap-y-4 p-4">
          <div :for={parent <- @tree} class="min-w-32">
            <h3 class="dossier text-lg text-phos-300">{parent.name}</h3>
            <div class="mt-1.5 flex flex-wrap gap-1.5">
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
      <section id="results" class="panel animate-boot mt-4 [animation-delay:320ms]">
        <div class="panel-title">
          <span>{if @q == "", do: "Latest intercepts", else: "Search results"}</span>
          <span class="label text-phos-500">{@count} {if @count == 1, do: "record", else: "records"}</span>
        </div>

        <div
          class="label hidden grid-cols-[3rem_1fr_9rem_7rem_6rem_8rem_5rem_3rem] gap-3 border-b border-phos-500/30 px-4 py-2 text-phos-700 md:grid"
          aria-hidden="true"
        >
          <span>#</span>
          <span>Name</span>
          <span>Function</span>
          <span>Source</span>
          <span class="text-right">Size</span>
          <span>Swarm</span>
          <span class="text-right">Age</span>
          <span class="text-right">Link</span>
        </div>

        <ol id="torrents" phx-update="stream" class="divide-y divide-phos-500/15">
          <li
            id="torrents-empty"
            class="dossier hidden p-10 text-center text-2xl text-phos-500 only:block"
          >
            No records match<span class="cursor"></span>
          </li>
          <li
            :for={{id, torrent} <- @streams.torrents}
            id={id}
            class="group relative grid gap-x-3 gap-y-2 px-4 py-3 transition hover:bg-phos-500/[0.06] md:grid-cols-[3rem_1fr_9rem_7rem_6rem_8rem_5rem_3rem] md:items-center"
          >
            <span class="absolute inset-y-0 left-0 w-0.5 bg-phos-300 opacity-0 shadow-[0_0_8px_#99ccff] transition group-hover:opacity-100"></span>
            <span class="dossier hidden text-lg text-phos-700 md:block">{ordinal(torrent.id)}</span>

            <h2 class="min-w-0 font-mono text-sm leading-snug text-phos-100">
              <.link
                navigate={~p"/torrents/#{torrent}"}
                class="focus-phos block truncate transition group-hover:glow"
                title={torrent.name}
              >
                {torrent.name}
              </.link>
            </h2>

            <div class="flex flex-wrap items-center gap-x-3 gap-y-1.5 md:contents">
              <.category_chip name={torrent.category.name} />
              <span class="label text-phos-500">{torrent.source.name}</span>
              <span class="font-mono text-xs text-phos-200 tabular-nums md:text-right">
                {bytes(torrent.size_in_bytes)}
              </span>
            </div>
            <div class="flex items-center gap-4 md:contents">
              <.swarm seeders={torrent.seeders} leechers={torrent.leechers} class="w-32 md:w-auto" />
              <span class="font-mono text-xs text-phos-500 tabular-nums md:text-right">
                {ago(torrent.published_at, @now)}
              </span>
              <a
                href={torrent.magnet_url}
                class="focus-phos ml-auto inline-flex items-center justify-end text-phos-500 transition hover:text-phos-100 hover:drop-shadow-[0_0_6px_rgba(153,204,255,0.9)] md:ml-0"
                title="Open magnet link"
                aria-label={"Magnet link for #{torrent.name}"}
              >
                <.magnet_icon class="size-5" />
              </a>
            </div>
          </li>
        </ol>
      </section>
    </Layouts.app>
    """
  end
end
