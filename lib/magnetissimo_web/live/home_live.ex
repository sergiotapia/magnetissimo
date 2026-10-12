defmodule MagnetissimoWeb.HomeLive do
  @moduledoc """
  The home page: search, category and source filters, per-source status and
  the latest magnets.

  The URL is the state. Typing patches `?q=`, picking a category patches
  `?category=`, toggling sources patches `?sources=` (their slugs, comma
  separated), the refine fields patch theirs (see
  `MagnetissimoWeb.SearchFilters`), a column header patches `?sort=` and
  `?dir=`, and the pager patches `?page=`. `handle_params/3` loads from
  those, so a search is a link and the form still works as a plain GET
  without JavaScript.

  `?q=` is read as a `Magnetissimo.Torrents.Query`, so it can hold quoted text,
  exclusions, alternatives and patterns.

  A search answers twice. The index answers at once, and at the same moment
  every source's own search is asked through `Magnetissimo.SourceSearch`.
  The sources are asked plain words, `Query.remote_terms/1`: one search for
  most queries, one per alternative for a query with a few, none for one of
  exclusions only. The page follows every one of them, and shows each source
  as one status across them. Each source's hits are indexed as they land, the
  page is reloaded from the index, and the rows that were not there before
  slide in.
  """
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.SourceSearch
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.Torrents.Query
  alias MagnetissimoWeb.SearchFilters

  # The columns a header sorts by, each with the way its first click orders
  # it: names A to Z, the biggest and best seeded first, the youngest first.
  @sort_columns [name: :asc, size: :desc, seeders: :desc, age: :asc]
  @sort_params Map.new(@sort_columns, fn {column, _dir} -> {Atom.to_string(column), column} end)

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Latest")
     |> assign(:source_list, Torrents.list_sources())
     |> assign_index_stats()
     |> assign(:ticker, Enum.map(Torrents.list_latest_torrents(limit: 8), & &1.name))
     |> assign(:source_keys, [])
     |> assign(:source_statuses, %{})
     |> assign(:sources, %{})
     |> assign(:shown_ids, MapSet.new())
     |> assign(:arrived, :all)
     |> assign(:now, DateTime.utc_now())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    q = params |> Map.get("q", "") |> param_text() |> String.trim()

    here = %{
      q: q,
      category: lookup_category(params["category"]),
      sources: lookup_sources(params["sources"], socket.assigns.source_list),
      sort: lookup_sort(params["sort"], params["dir"]),
      filters: SearchFilters.from_params(params)
    }

    query = Query.parse(q)

    # The sources are asked before the index is read, so whatever a source
    # indexed before its status was read here is already in the first load.
    {:noreply,
     socket
     |> assign(:query, query)
     |> follow_sources(query)
     |> load_results(here, page_param(params["page"]))
     |> assign(:arrived, :all)}
  end

  # A crafted URL can repeat a param as `q[]=`, which arrives as a list.
  defp param_text(text) when is_binary(text), do: text
  defp param_text(_other), do: ""

  # Typing patches the URL once the reader pauses: `phx-debounce` on the
  # input keeps that to one patch per pause rather than one per keystroke,
  # and pressing enter takes the immediate `submit` path instead. Either way
  # `handle_params/3` does the searching.
  @impl true
  # The refine fields are in the same form, so a change to any of them comes
  # through here too, and goes back to the first page.
  def handle_event(event, %{"q" => q} = params, socket) when event in ["search", "submit"] do
    here = %{
      socket.assigns.here
      | q: String.trim(q),
        filters: SearchFilters.from_params(params)
    }

    {:noreply, push_patch(socket, to: index_path(here))}
  end

  # A source's answer is only applied to the terms it was asked for. One for a
  # term the reader has moved on from can still be in the mailbox after the
  # unsubscribe, and must not redraw the list under the newer term.
  @impl true
  def handle_info({:source_search, key, source, status}, socket) do
    if key in socket.assigns.source_keys do
      socket = put_statuses(socket, key, &Map.put(&1, source, status))

      socket =
        case status do
          {:done, %{found: found}} when found > 0 -> reload_with_arrivals(socket)
          _nothing_new -> socket
        end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:source_search_done, key, statuses}, socket) do
    if key in socket.assigns.source_keys,
      do: {:noreply, put_statuses(socket, key, fn _ -> statuses end)},
      else: {:noreply, socket}
  end

  # Moves the subscriptions to the sources' answers for `query`'s remote
  # terms, and asks for them. The first, disconnected render cannot receive
  # answers, so it asks nothing.
  defp follow_sources(socket, query) do
    terms = query |> Query.remote_terms() |> Enum.uniq_by(&SourceSearch.key/1)
    keys = Enum.map(terms, &SourceSearch.key/1)
    previous = socket.assigns.source_keys

    if not connected?(socket) or keys == previous do
      socket
    else
      for key <- previous -- keys, do: SourceSearch.unsubscribe(key)
      for key <- keys -- previous, do: :ok = SourceSearch.subscribe(key)

      statuses = Map.new(terms, &{SourceSearch.key(&1), SourceSearch.request(&1)})

      socket
      |> assign(:source_keys, keys)
      |> assign(:source_statuses, statuses)
      |> assign(:sources, merge_statuses(statuses))
    end
  end

  defp put_statuses(socket, key, fun) do
    statuses = Map.update(socket.assigns.source_statuses, key, fun.(%{}), fun)

    socket
    |> assign(:source_statuses, statuses)
    |> assign(:sources, merge_statuses(statuses))
  end

  # One status per source across every term it was asked: still asking while
  # any search is, done with the counts added up once any answered, and
  # failed only if every one did.
  defp merge_statuses(by_key) do
    by_key
    |> Map.values()
    |> Enum.flat_map(&Map.to_list/1)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new(fn {source, statuses} -> {source, merge_status(statuses)} end)
  end

  defp merge_status([status]), do: status

  defp merge_status(statuses) do
    done = for {:done, counts} <- statuses, do: counts

    cond do
      :searching in statuses ->
        :searching

      done != [] ->
        {:done,
         %{
           found: done |> Enum.map(& &1.found) |> Enum.sum(),
           inserted: done |> Enum.map(& &1.inserted) |> Enum.sum()
         }}

      true ->
        hd(statuses)
    end
  end

  # Any Torznab category can be filtered on, including one nothing is filed
  # under yet: the link is still a valid one, and simply lists nothing.
  defp lookup_category(nil), do: nil

  defp lookup_category(id) when is_binary(id) do
    case Integer.parse(id) do
      {id, ""} -> Taxonomy.get(id)
      _ -> nil
    end
  end

  # The sources picked, in the order the page lists them. A slug the page
  # does not know, such as a source since removed, is dropped.
  defp lookup_sources(nil, _all), do: []

  defp lookup_sources(param, all) do
    slugs = param |> String.split(",", trim: true) |> MapSet.new()
    Enum.filter(all, &MapSet.member?(slugs, source_slug(&1.name)))
  end

  # Clicking a source adds it to the filter, or takes it out if it was in.
  # The list stays in page order, so one selection is always one URL.
  defp toggle_source(picked, source, all) do
    picked = if source in picked, do: List.delete(picked, source), else: [source | picked]
    Enum.filter(all, &(&1 in picked))
  end

  # A column the page does not know is no sort at all; a direction it does
  # not know is the column's own.
  defp lookup_sort(column, dir) do
    case Map.fetch(@sort_params, column) do
      {:ok, column} -> {column, lookup_dir(dir, Keyword.fetch!(@sort_columns, column))}
      :error -> nil
    end
  end

  defp lookup_dir("asc", _default), do: :asc
  defp lookup_dir("desc", _default), do: :desc
  defp lookup_dir(_dir, default), do: default

  # What a header's click sorts by. The first click orders its column the way
  # it is most often wanted, the second turns that around and the third goes
  # back to the page's own order: best match for a search, newest otherwise.
  defp sort_after_click(current, column) do
    first = Keyword.fetch!(@sort_columns, column)

    case current do
      {^column, ^first} -> {column, flip(first)}
      {^column, _flipped} -> nil
      _other -> {column, first}
    end
  end

  # The order the list is in when no column was picked, so the header can show
  # it: the latest list is the age column, youngest first; a search is ranked.
  defp shown_sort(nil, ""), do: {:age, :asc}
  defp shown_sort(sort, _q), do: sort

  defp flip(:asc), do: :desc
  defp flip(:desc), do: :asc

  # The age column is the publication date the other way round.
  defp torrent_sort(nil), do: []
  defp torrent_sort({:name, dir}), do: [sort: {:name, dir}]
  defp torrent_sort({:size, dir}), do: [sort: {:size_in_bytes, dir}]
  defp torrent_sort({:seeders, dir}), do: [sort: {:seeders, dir}]
  defp torrent_sort({:age, dir}), do: [sort: {:published_at, flip(dir)}]

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

  # Everything the results panel shows is derived from the query, the filters,
  # the sort and the page, so a URL patch and a fresh batch of hits from the
  # source both come through here. `here` is all of that but the page.
  defp load_results(socket, here, page) do
    %{q: q, category: category, sources: sources, sort: sort, filters: filters} = here
    query = socket.assigns.query
    now = DateTime.utc_now()
    refine = SearchFilters.opts(filters, now)

    opts =
      [category_id: category && category.id, source_ids: Enum.map(sources, & &1.id)]
      |> Enum.reject(fn {_key, value} -> value in [nil, []] end)
      |> Kernel.++(refine)

    count =
      if q == "",
        do: Torrents.count_torrents(opts),
        else: Torrents.count_search_torrents(query, opts)

    pages = max(1, ceil(count / Torrents.per_page()))
    page = min(page, pages)

    torrents =
      if q == "",
        do: Torrents.list_latest_torrents(opts ++ torrent_sort(sort) ++ page_opts(page)),
        else: Torrents.search_torrents(query, opts ++ torrent_sort(sort) ++ page_opts(page))

    socket
    |> assign(:here, here)
    |> assign(:q, q)
    |> assign(:category, category)
    |> assign(:source_filter, sources)
    |> assign(:sort, sort)
    |> assign(:filters, filters)
    |> assign(:page, page)
    |> assign(:pages, pages)
    |> assign(:count, count)
    |> assign_filtered_away(here, refine, count)
    |> assign(:form, to_form(%{"q" => q}))
    |> assign(:now, now)
    |> assign(:shown_ids, MapSet.new(torrents, & &1.id))
    |> stream(:torrents, torrents, reset: true)
  end

  # With a category or source filter on, every source is still asked, for
  # every category, so the page says how much of each answer those filters
  # are hiding: per source in its chip, and in total next to the match count.
  # The refine fields narrow what is asked about, so they stay applied.
  defp assign_filtered_away(socket, %{q: ""}, _refine, _count) do
    assign(socket, in_filter: nil, outside: 0)
  end

  defp assign_filtered_away(socket, here, refine, count) do
    %{category: category, sources: sources} = here
    query = socket.assigns.query

    in_filter =
      if category,
        do: Torrents.count_search_hits_by_source(Query.remote_terms(query), category.id)

    outside =
      if category || sources != [],
        do: Torrents.count_search_torrents(query, refine) - count,
        else: 0

    assign(socket, in_filter: in_filter, outside: outside)
  end

  # A source added to the index: reload the page and mark the rows that were
  # not on it before, so they, and only they, slide in. Resetting the stream
  # re-attaches every kept row, which would replay a row animation on all of
  # them, so the animation class goes only on the arrivals.
  defp reload_with_arrivals(socket) do
    %{here: here, page: page} = socket.assigns
    before = socket.assigns.shown_ids

    arrived_before =
      if socket.assigns.arrived == :all, do: MapSet.new(), else: socket.assigns.arrived

    socket = socket |> assign_index_stats() |> load_results(here, page)

    arrived =
      socket.assigns.shown_ids |> MapSet.difference(before) |> MapSet.union(arrived_before)

    assign(socket, :arrived, arrived)
  end

  defp assign_index_stats(socket) do
    counts = Torrents.count_torrents_by_category()

    socket
    |> assign(:category_counts, counts)
    |> assign(:tree, category_tree(counts))
    |> assign(:source_counts, Map.new(Torrents.count_torrents_by_source()))
    |> assign(:total, Torrents.count_torrents())
  end

  # The page as it is, with `changes` made: any of the keys in `here`, and
  # `:page`, which is otherwise the first.
  defp index_path(here, changes \\ []) do
    here = Map.merge(here, Map.new(changes))
    %{q: q, category: category, sources: sources, filters: filters} = here
    {column, dir} = here.sort || {nil, nil}
    page = Map.get(here, :page, 1)

    params =
      Enum.reject(
        [
          q: if(String.trim(q) != "", do: q),
          category: category && category.id,
          sources: if(sources != [], do: Enum.map_join(sources, ",", &source_slug(&1.name)))
        ] ++
          SearchFilters.to_params(filters) ++
          [
            sort: column,
            dir: dir,
            page: if(page > 1, do: page)
          ],
        fn {_key, value} -> is_nil(value) end
      )

    ~p"/?#{params}"
  end

  # Only the categories something is filed under, each top level with the
  # count for its whole group. The taxonomy has some seventy categories, most
  # of which no source uses.
  defp category_tree(counts) do
    for {root, children} <- Taxonomy.tree(&Map.has_key?(counts, &1.id)) do
      family_count =
        root.id |> Taxonomy.family_ids() |> Enum.map(&Map.get(counts, &1, 0)) |> Enum.sum()

      {root, children, family_count}
    end
  end

  defp max_source_count(counts), do: counts |> Map.values() |> Enum.max(fn -> 1 end) |> max(1)

  defp picked?(sources, name), do: Enum.any?(sources, &(&1.name == name))

  # With sources picked, the chips of the others are told apart: they are
  # still asked, but nothing they find is listed.
  defp hidden_by_sources?([], _name), do: false
  defp hidden_by_sources?(sources, name), do: not picked?(sources, name)

  defp arrived?(:all, _torrent), do: false
  defp arrived?(arrived, torrent), do: MapSet.member?(arrived, torrent.id)

  # A fresh page rises in as a whole; after that only arrivals move.
  defp arrival_class(:all, _torrent), do: "animate-rise"

  defp arrival_class(arrived, torrent),
    do: if(MapSet.member?(arrived, torrent.id), do: "animate-arrive")

  defp source_slug(name), do: name |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-")

  defp status_name(:searching), do: "searching"
  defp status_name({:done, _}), do: "done"
  defp status_name({:failed, _}), do: "failed"

  # With a category filter on, a source's answer is told as what of it the
  # filter shows, so "50 found" never sits above an empty list unexplained.
  defp source_label({:done, %{found: found}}, _name, _category, _in_filter, true = _hidden)
       when found > 0 do
    "#{found} found · not shown"
  end

  defp source_label({:done, %{found: found}}, name, category, in_filter, _hidden)
       when found > 0 and is_map(in_filter) do
    "#{found} found · #{Map.get(in_filter, name, 0)} in #{category.name}"
  end

  defp source_label(status, _name, _category, _in_filter, _hidden), do: status_label(status)

  defp status_label(:searching), do: "asking…"
  defp status_label({:done, %{found: 0}}), do: "nothing"
  defp status_label({:done, %{found: found, inserted: 0}}), do: "#{found} found"
  defp status_label({:done, %{found: found, inserted: new}}), do: "#{found} found · #{new} new"
  defp status_label({:failed, :timeout}), do: "timed out"
  defp status_label({:failed, _reason}), do: "unreachable"

  defp status_title(name, :searching), do: "Asking #{name}'s own search"
  defp status_title(name, {:done, _}), do: "#{name} answered; its hits are in the results"
  defp status_title(name, {:failed, _}), do: "#{name} did not answer this time"

  defp sort_headers do
    [
      {:name, "Name", "name"},
      {:size, "Size", "size"},
      {:seeders, "Swarm", "seeders"},
      {:age, "Age", "age"}
    ]
  end

  attr :column, :atom, required: true
  attr :label, :string, required: true
  attr :title, :string, required: true
  attr :shown, :any, required: true, doc: "the order the list is in, `{column, dir}` or nil"
  attr :patch, :string, required: true

  defp sort_header(assigns) do
    dir =
      case assigns.shown do
        {column, dir} when column == assigns.column -> dir
        _other -> nil
      end

    assigns = assign(assigns, :dir, dir)

    ~H"""
    <.link
      patch={@patch}
      id={"sort-#{@column}"}
      data-dir={@dir}
      aria-label={"Sort by #{@title}" <> if(@dir, do: ", now #{dir_word(@dir)}", else: "")}
      title={"Sort by #{@title}"}
      class={[
        "group/sort focus-ring inline-flex items-center gap-1 rounded transition-colors hover:text-azure-600",
        @dir && "text-azure-600",
        @column in [:size, :age] && "md:flex-row-reverse md:justify-self-end"
      ]}
    >
      <span>{@label}</span>
      <.icon
        name={sort_icon(@dir)}
        class={[
          "size-3.5 shrink-0 transition",
          !@dir && "opacity-0 group-hover/sort:opacity-60 group-focus-visible/sort:opacity-60"
        ]}
      />
    </.link>
    """
  end

  defp sort_icon(:asc), do: "hero-arrow-up-mini"
  defp sort_icon(:desc), do: "hero-arrow-down-mini"
  defp sort_icon(nil), do: "hero-arrows-up-down-mini"

  defp dir_word(:asc), do: "ascending"
  defp dir_word(:desc), do: "descending"

  # The refine fields, in a disclosure under the search box. It opens itself
  # when the URL holds any, and is otherwise left as the reader set it: the
  # server does not know, so `open` is not patched back.
  attr :filters, SearchFilters, required: true
  attr :clear, :string, required: true, doc: "the page with no refine fields"

  defp refine(assigns) do
    ~H"""
    <details
      id="refine"
      open={refine_open?(@filters)}
      phx-mounted={JS.ignore_attributes(["open"])}
      class="group/refine mt-3 pl-5"
    >
      <summary class="focus-ring inline-flex cursor-pointer list-none items-center gap-1.5 rounded text-sm font-semibold text-ink-500 transition hover:text-azure-600 [&::-webkit-details-marker]:hidden">
        <.icon
          name="hero-adjustments-horizontal-mini"
          class="size-4 text-azure-500 transition group-open/refine:rotate-90"
        /> Refine
      </summary>

      <div class="mt-3 grid gap-x-5 gap-y-3 sm:grid-cols-3">
        <fieldset class="sm:col-span-3">
          <legend class="label mb-1.5">Search in</legend>
          <div class="flex flex-wrap gap-x-5 gap-y-1 text-sm font-semibold text-ink-700">
            <label class="inline-flex items-center gap-2">
              <input
                type="radio"
                name="in"
                value=""
                id="refine-in-all"
                checked={@filters.scope == :all}
                class="accent-azure-500"
              /> Names, descriptions and files
            </label>
            <label class="inline-flex items-center gap-2">
              <input
                type="radio"
                name="in"
                value="title"
                id="refine-in-title"
                checked={@filters.scope == :name}
                class="accent-azure-500"
              /> Names only
            </label>
          </div>
        </fieldset>

        <.refine_pair
          :for={{legend, fields} <- refine_fields()}
          legend={legend}
          fields={fields}
          filters={@filters}
        />
      </div>

      <div class="mt-3 flex flex-wrap items-baseline justify-between gap-x-4 gap-y-2">
        <p id="refine-help" class="text-xs leading-relaxed text-ink-500">
          In the search box: <code class="font-mono text-ink-700">"exact text"</code>
          · <code class="font-mono text-ink-700">-word</code>
          to exclude · <code class="font-mono text-ink-700">this|that</code>
          · <code class="font-mono text-ink-700">s01e*</code>
          for any ending
        </p>
        <.link
          :if={refine_open?(@filters)}
          patch={@clear}
          id="clear-refine"
          class="pill focus-ring px-2.5 py-1 text-[0.7rem] font-bold"
        >
          Clear refine ×
        </.link>
      </div>
    </details>
    """
  end

  attr :legend, :string, required: true
  attr :fields, :list, required: true, doc: "`{name, label, placeholder}` for each field"
  attr :filters, SearchFilters, required: true

  defp refine_pair(assigns) do
    ~H"""
    <fieldset>
      <legend class="label mb-1.5">{@legend}</legend>
      <div class="grid grid-cols-2 gap-2">
        <div :for={{name, label, placeholder} <- @fields}>
          <label for={"refine-#{name}"} class="sr-only">{@legend} {label}</label>
          <.input
            type="text"
            name={name}
            id={"refine-#{name}"}
            value={SearchFilters.value(@filters, name)}
            placeholder={placeholder}
            autocomplete="off"
            spellcheck="false"
            phx-debounce="400"
            aria-invalid={SearchFilters.invalid?(@filters, name) && "true"}
            aria-describedby={SearchFilters.invalid?(@filters, name) && "refine-#{name}-error"}
            class="well w-full rounded-full px-3.5 py-1.5 text-sm font-semibold text-ink-900 outline-none placeholder:font-normal placeholder:text-ink-300 focus-visible:shadow-[0_0_0_3px_rgba(79,123,255,0.35)] aria-invalid:shadow-[0_0_0_2px_var(--color-bubble)]"
          />
          <p
            :if={SearchFilters.invalid?(@filters, name)}
            id={"refine-#{name}-error"}
            class="mt-1 pl-3.5 text-xs text-ink-500"
          >
            Not understood, so ignored
          </p>
        </div>
      </div>
    </fieldset>
    """
  end

  defp refine_fields do
    [
      {"Size", [{"min_size", "at least", "min, e.g. 2 GB"}, {"max_size", "at most", "max"}]},
      {"Seeders", [{"min_seeders", "at least", "min"}, {"max_seeders", "at most", "max"}]},
      {"Age", [{"max_age", "newer than", "newer, e.g. 7d"}, {"min_age", "older than", "older"}]}
    ]
  end

  # Open when the URL holds a refine field, read or not.
  defp refine_open?(filters), do: filters.scope != :all or filters.typed != %{}

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
                seed={"#{@total}:#{length(@source_list)}"}
                class="size-20 shrink-0"
              />
              <dl class="flex-1 text-sm">
                <div class="spec-row">
                  <dt class="text-ink-500">Sources</dt>
                  <span class="leader"></span>
                  <dd class="font-bold text-ink-900">{length(@source_list)}</dd>
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
              <.link
                :if={@source_filter != []}
                patch={index_path(@here, sources: [])}
                id="clear-sources"
                class="pill focus-ring px-2.5 py-1 font-sans text-[0.7rem] font-bold tracking-normal normal-case"
              >
                Clear filter ×
              </.link>
              <span :if={@source_filter == []} class="label">filter by source</span>
            </div>
            <%!-- Each source toggles in and out of the filter; none picked is all of them. --%>
            <ul class="space-y-1 p-3 text-sm">
              <li :for={source <- @source_list}>
                <.link
                  patch={
                    index_path(@here, sources: toggle_source(@source_filter, source, @source_list))
                  }
                  id={"source-#{source_slug(source.name)}"}
                  aria-current={picked?(@source_filter, source.name) && "true"}
                  title={
                    if(picked?(@source_filter, source.name),
                      do: "Stop showing results from #{source.name}",
                      else: "Show results from #{source.name}"
                    )
                  }
                  class={[
                    "group/source focus-ring block rounded-xl px-2 py-1.5 transition hover:bg-glass/80",
                    picked?(@source_filter, source.name) && "bg-azure-100/70",
                    hidden_by_sources?(@source_filter, source.name) && "opacity-50 hover:opacity-100"
                  ]}
                >
                  <div class="flex items-center justify-between gap-3">
                    <span class="flex items-center gap-2 font-semibold text-ink-700">
                      <span class={[
                        "inline-flex size-4 shrink-0 items-center justify-center rounded-full transition",
                        if(picked?(@source_filter, source.name),
                          do: "gel",
                          else:
                            "border border-frost-300 bg-glass/70 group-hover/source:border-azure-400"
                        )
                      ]}>
                        <.icon
                          :if={picked?(@source_filter, source.name)}
                          name="hero-check-mini"
                          class="size-3.5"
                        />
                      </span>
                      {source.name}
                    </span>
                    <span class="font-mono text-xs text-ink-900 tabular-nums">
                      {number(Map.get(@source_counts, source.name, 0))}
                    </span>
                  </div>
                  <div class="well mt-1.5 ml-6 h-2.5 rounded-full p-0.5">
                    <div
                      class="bar-fill h-full transition-[width] duration-700"
                      style={"width: #{round(Map.get(@source_counts, source.name, 0) / max_source_count(@source_counts) * 100)}%"}
                    >
                    </div>
                  </div>
                </.link>
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
                patch={index_path(@here, category: nil)}
                id="clear-category"
                class="pill focus-ring px-2.5 py-1 font-sans text-[0.7rem] font-bold tracking-normal normal-case"
              >
                Clear filter ×
              </.link>
              <span :if={!@category} class="label">filter by category</span>
            </div>
            <div class="space-y-4 p-5">
              <p :if={@tree == []} id="categories-empty" class="text-sm text-ink-500">
                Nothing indexed yet.
              </p>
              <div :for={{root, children, family_count} <- @tree} id={"category-group-#{root.id}"}>
                <h3 class="font-display text-xs font-bold tracking-[0.2em] text-ink-500 uppercase">
                  {root.name}
                </h3>
                <div class="mt-2 flex flex-wrap gap-1.5">
                  <%!-- The whole group: the top level and all of its children. --%>
                  <.link
                    patch={index_path(@here, category: root)}
                    id={"category-#{root.id}"}
                    aria-current={@category && @category.id == root.id && "true"}
                    class={[
                      if(@category && @category.id == root.id, do: "gel", else: "pill"),
                      "focus-ring inline-flex items-center px-3 py-1 text-xs leading-none font-semibold whitespace-nowrap"
                    ]}
                  >
                    All
                    <span class={[
                      "ml-1.5 rounded-full px-1.5 py-px font-mono text-[0.65rem]",
                      if(@category && @category.id == root.id,
                        do: "bg-white/25",
                        else: "bg-azure-100 text-azure-600"
                      )
                    ]}>
                      {family_count}
                    </span>
                  </.link>
                  <.category_chip
                    :for={category <- children}
                    category={category}
                    short
                    patch={index_path(@here, category: category)}
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
                  class="wordmark h-auto w-full"
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
                <input
                  :if={@source_filter != []}
                  type="hidden"
                  name="sources"
                  value={Enum.map_join(@source_filter, ",", &source_slug(&1.name))}
                />
                <%= if @sort do %>
                  <input type="hidden" name="sort" value={elem(@sort, 0)} />
                  <input type="hidden" name="dir" value={elem(@sort, 1)} />
                <% end %>
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

                <.refine filters={@filters} clear={index_path(@here, filters: %SearchFilters{})} />
              </.form>

              <p :if={@q != "" or !@category} id="status-line" class="mt-4 pl-5 text-sm text-ink-500">
                <%= if @q != "" do %>
                  <span class="font-bold text-azure-600">{@count}</span>
                  {if @count == 1, do: "match", else: "matches"} for
                  <span class="font-bold text-ink-900">“{@q}”</span>
                  <span :if={@category}>in {@category.name}</span>
                  <span :if={@source_filter != []} id="source-filter-line">
                    from {Enum.map_join(@source_filter, ", ", & &1.name)}
                  </span>
                  <span :if={SearchFilters.active?(@filters)} id="refine-line">
                    · {Enum.join(SearchFilters.summary(@filters), " · ")}
                  </span>
                  <span :if={@outside > 0} id="filtered-away">
                    · {@outside} more outside the filter,
                    <.link
                      patch={index_path(@here, category: nil, sources: [])}
                      id="show-all"
                      class="font-semibold text-azure-600 underline decoration-azure-200 underline-offset-2 transition hover:decoration-azure-500"
                    >
                      show all
                    </.link>
                  </span>
                <% else %>
                  <%= if SearchFilters.active?(@filters) do %>
                    <span class="font-bold text-azure-600">{@count}</span>
                    {if @count == 1, do: "magnet", else: "magnets"}
                    <span id="refine-line">
                      · {Enum.join(SearchFilters.summary(@filters), " · ")}
                    </span>
                  <% else %>
                    Type to search, or pick a category.
                  <% end %>
                <% end %>
              </p>

              <ul
                :if={@sources != %{}}
                id="source-status"
                class="mt-3 flex flex-wrap items-center gap-1.5 pl-5"
                aria-live="polite"
              >
                <li
                  :for={{name, status} <- Enum.sort(@sources)}
                  id={"source-status-#{source_slug(name)}"}
                  data-status={status_name(status)}
                  data-hidden={hidden_by_sources?(@source_filter, name) && "true"}
                  title={
                    if(hidden_by_sources?(@source_filter, name),
                      do: status_title(name, status) <> ", but the source filter hides them",
                      else: status_title(name, status)
                    )
                  }
                  class={[
                    "pill flex items-center gap-1.5 px-2.5 py-1 text-xs font-semibold transition duration-500",
                    hidden_by_sources?(@source_filter, name) && "opacity-55",
                    status == :searching && "text-ink-500",
                    match?({:failed, _}, status) && "border-bubble-soft text-ink-500"
                  ]}
                >
                  <span class={[
                    "size-1.5 shrink-0 rounded-full transition-colors duration-500",
                    status == :searching && "animate-pulse bg-azure-400 motion-reduce:animate-none",
                    match?({:done, _}, status) && "bg-mint shadow-[0_0_0_3px_var(--color-mint-soft)]",
                    match?({:failed, _}, status) && "bg-bubble"
                  ]}></span>
                  <span class="text-ink-900">{name}</span>
                  <span class="font-mono text-[0.7rem] tabular-nums">{source_label(
                    status,
                    name,
                    @category,
                    @in_filter,
                    hidden_by_sources?(@source_filter, name)
                  )}</span>
                </li>
              </ul>
            </div>

            <div class="mt-auto grid grid-cols-[auto_auto_1fr] items-center gap-3 border-t border-frost-300/70 bg-glass/40 px-6 py-2.5 sm:px-10">
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
              id="sort-headers"
              class="label flex flex-wrap items-center gap-x-4 gap-y-1 border-b border-frost-300/70 px-5 py-2.5 md:grid md:grid-cols-[minmax(0,1fr)_5.5rem_7.5rem_4.5rem_2rem]"
            >
              <span class="text-ink-300 md:hidden">Sort by</span>
              <.sort_header
                :for={{column, label, title} <- sort_headers()}
                column={column}
                label={label}
                title={title}
                shown={shown_sort(@sort, @q)}
                patch={index_path(@here, sort: sort_after_click(shown_sort(@sort, @q), column))}
              />
              <span class="hidden text-right md:block" aria-hidden="true">Link</span>
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
                data-arrived={arrived?(@arrived, torrent) && "true"}
                class={[
                  arrival_class(@arrived, torrent),
                  "group grid gap-x-4 gap-y-2.5 rounded-2xl px-3.5 py-3 transition hover:bg-glass/80 hover:shadow-[0_6px_16px_-10px_rgba(31,63,209,0.4)] md:grid-cols-[minmax(0,1fr)_5.5rem_7.5rem_4.5rem_2rem] md:items-center"
                ]}
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
                    <.category_chip category={Taxonomy.fetch!(torrent.category_id)} />
                    <span class="label">{torrent.source.name}</span>
                    <span
                      :if={arrived?(@arrived, torrent)}
                      class="rounded-full bg-azure-100 px-2 py-0.5 font-display text-[0.6rem] font-bold tracking-[0.15em] text-azure-700 uppercase"
                    >
                      Just found
                    </span>
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
                patch={index_path(@here, page: @page - 1)}
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
                patch={index_path(@here, page: @page + 1)}
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
