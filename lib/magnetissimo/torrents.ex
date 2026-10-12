defmodule Magnetissimo.Torrents do
  @moduledoc """
  The torrents context: the sites we crawl and the indexed torrents. The
  categories they are filed under are `Magnetissimo.Taxonomy`.

  Searching goes through `search_torrents/2`, which queries the two FTS5
  indexes. Read `Magnetissimo.Torrents.Search` before writing anything else
  that talks to them.
  """

  import Ecto.Query, warn: false

  alias Magnetissimo.Repo
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents.Query
  alias Magnetissimo.Torrents.Search
  alias Magnetissimo.Torrents.SearchHit
  alias Magnetissimo.Torrents.Source
  alias Magnetissimo.Torrents.Torrent

  @latest_limit 50
  @search_limit 50
  @per_page 25

  ## Sources

  @doc "Returns every crawl source, ordered by name."
  def list_sources do
    Repo.all(from s in Source, order_by: [asc: s.name])
  end

  @doc """
  Returns the source with the given name.

  Raises `Ecto.NoResultsError` if there is no such source.
  """
  def get_source_by_name!(name) do
    Repo.get_by!(Source, name: name)
  end

  ## Categories

  @doc """
  Returns `%{category_id => torrent_count}` for every category with torrents
  filed directly under it. A top-level category's own count leaves out its
  children; see `Magnetissimo.Taxonomy.family_ids/1`. Like
  `list_latest_torrents/1`, it leaves out what the DHT found.
  """
  def count_torrents_by_category do
    from(t in Torrent, group_by: t.category_id, select: {t.category_id, count(t.id)})
    |> without_dht([])
    |> Repo.all()
    |> Map.new()
  end

  ## Torrents

  @doc "How many torrents a page of the UI holds."
  def per_page, do: @per_page

  @doc """
  Returns the most recently published torrents.

  Torrents the DHT found are left out unless `:source_ids` names the DHT. It
  finds thousands an hour, of every age, and would bury what the sites
  publish; they have a page of their own (`list_dht_torrents/1`), and
  searches find them like any other.

  ## Options

    * `:limit` - how many to return, 50 by default
    * `:offset` - skip this many, 0 by default, for paging
    * `:category_id` - only torrents filed under this category or, for a
      top-level one, any of its children
    * `:category_ids` - only torrents filed under exactly one of these, such
      as `Magnetissimo.Taxonomy.torznab_ids/1` returns; an empty list is no
      filter
    * `:source_ids` - only torrents from one of these sources; an empty list
      is no filter, not an empty result
    * `:sort` - a `t:Magnetissimo.Torrents.Search.sort/0`, such as
      `{:seeders, :desc}`, in place of newest first
    * `:min_size` and `:max_size` - in bytes
    * `:min_seeders` and `:max_seeders`
    * `:published_after` and `:published_before` - `DateTime`s

  Every bound is inclusive, and a `nil` one is no bound.
  """
  def list_latest_torrents(opts \\ []) do
    limit = Keyword.get(opts, :limit, @latest_limit)
    offset = Keyword.get(opts, :offset, 0)

    query = from t in Torrent, limit: ^limit, offset: ^offset, preload: [:source]

    query |> filtered(opts) |> sorted(opts[:sort]) |> Repo.all()
  end

  defp sorted(query, nil), do: order_by(query, [t], desc: t.published_at, desc: t.id)

  defp sorted(query, {:name, dir}) do
    order_by(query, [t], [{^dir, fragment("? COLLATE NOCASE", t.name)}, desc: t.id])
  end

  defp sorted(query, {field, dir}) when field in [:size_in_bytes, :seeders, :published_at] do
    order_by(query, [t], [{^dir, field(t, ^field)}, desc: t.id])
  end

  @doc """
  Returns how many torrents are indexed, or match the filters
  `list_latest_torrents/1` takes.
  """
  def count_torrents(opts \\ []) do
    Repo.aggregate(filtered(from(t in Torrent), opts), :count)
  end

  @dht "DHT"

  # Without a source filter, the DHT's torrents stay out of the views that
  # list without a search. Picking the DHT as a source shows them.
  defp without_dht(query, opts) do
    if Keyword.get(opts, :source_ids, []) == [] do
      dht = from s in Source, where: s.name == @dht, select: s.id
      where(query, [t], t.source_id not in subquery(dht))
    else
      query
    end
  end

  defp filtered(query, opts) do
    query = without_dht(query, opts)

    query =
      for {column, ids} <- filters(opts), ids != [], reduce: query do
        query -> where(query, [t], field(t, ^column) in ^ids)
      end

    for {column, bound, value} <- ranges(opts), reduce: query do
      query when bound == :min -> where(query, [t], field(t, ^column) >= ^value)
      query when bound == :max -> where(query, [t], field(t, ^column) <= ^value)
    end
  end

  @ranges [
    min_size: {:size_in_bytes, :min},
    max_size: {:size_in_bytes, :max},
    min_seeders: {:seeders, :min},
    max_seeders: {:seeders, :max},
    published_after: {:published_at, :min},
    published_before: {:published_at, :max}
  ]

  # Each is `{column, :min | :max, value}`, for every bound given.
  defp ranges(opts) do
    for {option, {column, bound}} <- @ranges, value = opts[option], value != nil do
      {column, bound, range_value(value)}
    end
  end

  # `published_at` is stored as ISO 8601 text with six decimals, and compared
  # as text. A date with fewer would sort after one with more in the same
  # second, so every date is padded to the column's precision.
  defp range_value(%DateTime{} = date) do
    {microsecond, _precision} = date.microsecond
    %{DateTime.shift_zone!(date, "Etc/UTC") | microsecond: {microsecond, 6}}
  end

  defp range_value(value) when is_integer(value), do: value

  # Each is `{column, ids}`, kept when the column is one of the ids. An
  # empty list is no filter.
  defp filters(opts) do
    family =
      case Keyword.fetch(opts, :category_id) do
        {:ok, category_id} -> Taxonomy.family_ids(category_id)
        :error -> []
      end

    [
      category_id: family,
      category_id: Keyword.get(opts, :category_ids, []),
      source_id: Keyword.get(opts, :source_ids, [])
    ]
  end

  @doc """
  Gets a single torrent with its source.

  Raises `Ecto.NoResultsError` if the torrent does not exist.
  """
  def get_torrent!(id) do
    Repo.get!(Torrent, id) |> Repo.preload(:source)
  end

  @doc """
  Gets the torrents with these ids, with their sources, in the order given.
  An id with no torrent is skipped.
  """
  def get_torrents(ids), do: load_torrents_in_order(ids)

  @doc """
  Returns the hex infohashes, of those given, that are already indexed.
  """
  @spec known_hashes([String.t()]) :: MapSet.t(String.t())
  def known_hashes([]), do: MapSet.new()

  def known_hashes(hashes) do
    hashes
    |> Enum.uniq()
    |> Enum.chunk_every(500)
    |> Enum.flat_map(fn chunk ->
      Repo.all(from t in Torrent, where: t.magnet_hash in ^chunk, select: t.magnet_hash)
    end)
    |> MapSet.new()
  end

  @doc """
  Returns the torrents the DHT found most recently, newest first.

  ## Options

    * `:limit` - how many, 100 by default
  """
  def list_dht_torrents(opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)

    Repo.all(
      from t in Torrent,
        join: s in assoc(t, :source),
        where: s.name == @dht,
        order_by: [desc: t.inserted_at, desc: t.id],
        limit: ^limit,
        preload: [source: s]
    )
  end

  @doc """
  Sets the swarm of the torrent with this hex infohash, as a DHT scrape
  estimated it. Returns `{:ok, id}`, or `:error` when no such torrent is
  indexed. The search indexes are not touched.
  """
  @spec update_swarm(String.t(), non_neg_integer(), non_neg_integer()) ::
          {:ok, integer()} | :error
  def update_swarm(hash, seeders, leechers) do
    query = from t in Torrent, where: t.magnet_hash == ^hash, select: t.id

    case Repo.update_all(query,
           set: [seeders: seeders, leechers: leechers, updated_at: DateTime.utc_now()]
         ) do
      {1, [id]} -> {:ok, id}
      {_count, _ids} -> :error
    end
  end

  @doc """
  Returns the torrents already indexed at any of `urls`, keyed by
  `canonical_url`.

  For a source whose listing names a page per torrent but no infohash, so its
  crawler can skip fetching the pages it has already read.
  """
  def torrents_by_canonical_url(urls) do
    from(t in Torrent, where: t.canonical_url in ^urls)
    |> Repo.all()
    |> Map.new(&{&1.canonical_url, &1})
  end

  @doc """
  Inserts a torrent as scraped from a source.

  A duplicate `magnet_hash` is the expected outcome when a source republishes
  something already indexed, and comes back as a normal changeset error on
  `:magnet_hash`.
  """
  def create_torrent(attrs) do
    %Torrent{}
    |> Torrent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Indexes a batch of torrents as one source handed them back, in one
  transaction.

  A torrent not yet indexed is inserted. One already indexed, matched by
  `magnet_hash`, keeps everything it has except its swarm: `seeders` and
  `leechers` take the fresh numbers, so a torrent a search or crawl sees again
  stops showing the swarm it had on the day it was first found. A source that
  knows no swarm, and sends `nil` for both, leaves the numbers as they are:
  AudioBookBay or the DHT seeing a torrent again is no reason to zero what
  The Pirate Bay last counted.

  A torrent indexed without a file list gains one when a source that has it,
  the DHT, sees the torrent too.

  The one other exception is a torrent filed under the fallback category.
  TorrentDownloads' search feed carries no category, so a torrent it finds
  first lands in "Other" even when Nyaa knows it is anime. The first source to
  say what it is gets to file it; a real category is never overwritten.

  Attrs that fail `Torrent.changeset/2` are not indexed; they come back in
  `:rejected` with their errors, for the caller to log.

  With `search_term: term`, the batch is also recorded as what a source
  returned for `term` (see `record_search_hits/3`), in the same transaction:
  a search given up on halfway can never leave the torrents indexed but not
  findable by the term that found them.

  Returns `%{ids: ids, inserted: count, rejected: [{attrs, errors}]}`, where
  `ids` holds every valid torrent in the batch, new or already indexed, in the
  order given.
  """
  def index_torrents(attrs_list, opts \\ []) do
    {valid, rejected} =
      Enum.reduce(attrs_list, {[], []}, fn attrs, {valid, rejected} ->
        case Torrent.changeset(%Torrent{}, attrs) do
          %{valid?: true} = changeset -> {[{swarm?(changeset), row(changeset)} | valid], rejected}
          changeset -> {valid, [{attrs, changeset.errors} | rejected]}
        end
      end)

    # One statement cannot upsert the same row twice, so a batch that lists a
    # hash twice keeps the first.
    rows = valid |> Enum.reverse() |> Enum.uniq_by(fn {_swarm?, row} -> row.magnet_hash end)

    {:ok, {ids, inserted}} =
      Repo.transact(fn ->
        {ids, inserted} = upsert(rows)

        if term = opts[:search_term] do
          insert_search_hits(term, Enum.zip(Enum.map(rows, &elem(&1, 1).source_id), ids))
        end

        {:ok, {ids, inserted}}
      end)

    %{ids: ids, inserted: inserted, rejected: Enum.reverse(rejected)}
  end

  @indexed_fields [
    :name,
    :description,
    :canonical_url,
    :published_at,
    :leechers,
    :seeders,
    :size_in_bytes,
    :magnet_hash,
    :magnet_url,
    :category_id,
    :source_id,
    :files,
    :file_count,
    :file_names
  ]

  # Read from the params, as the schema's default of 0 hides a nil.
  defp swarm?(%{params: params}) do
    params["seeders"] != nil or params["leechers"] != nil
  end

  defp row(changeset) do
    now = DateTime.utc_now()

    changeset
    |> Ecto.Changeset.apply_changes()
    |> Map.take(@indexed_fields)
    # A source that sends no swarm numbers sends nil, and the columns are NOT NULL.
    |> Map.update!(:seeders, &(&1 || 0))
    |> Map.update!(:leechers, &(&1 || 0))
    |> Map.merge(%{inserted_at: now, updated_at: now})
  end

  defp upsert([]), do: {[], 0}

  # Rows with a swarm and rows without go in separate statements, as only the
  # first refresh it.
  defp upsert(rows) do
    hashes = Enum.map(rows, fn {_swarm?, row} -> row.magnet_hash end)
    known = Repo.all(from t in Torrent, where: t.magnet_hash in ^hashes, select: t.magnet_hash)

    # Chunked to stay well under SQLite's limit on bound parameters, 16 a row.
    id_by_hash =
      rows
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.flat_map(fn {swarm?, rows} ->
        rows
        |> Enum.chunk_every(500)
        |> Enum.flat_map(fn chunk ->
          {_count, returned} =
            Repo.insert_all(Torrent, chunk,
              on_conflict: refresh(swarm?),
              conflict_target: :magnet_hash,
              returning: [:id, :magnet_hash]
            )

          returned
        end)
      end)
      |> Map.new(&{&1.magnet_hash, &1.id})

    {Enum.map(hashes, &Map.fetch!(id_by_hash, &1)), length(hashes) - length(known)}
  end

  defp refresh(swarm?) do
    fallback_id = Taxonomy.other_id()

    swarm =
      if swarm?,
        do: [
          seeders: dynamic(fragment("excluded.seeders")),
          leechers: dynamic(fragment("excluded.leechers"))
        ],
        else: []

    set =
      swarm ++
        [
          updated_at: dynamic(fragment("excluded.updated_at")),
          category_id:
            dynamic(
              [t],
              fragment(
                "CASE WHEN ? = ? THEN excluded.category_id ELSE ? END",
                t.category_id,
                ^fallback_id,
                t.category_id
              )
            ),
          files: dynamic([t], fragment("coalesce(?, excluded.files)", t.files)),
          file_count: dynamic([t], fragment("coalesce(?, excluded.file_count)", t.file_count)),
          file_names: dynamic([t], fragment("coalesce(?, excluded.file_names)", t.file_names))
        ]

    from(t in Torrent, update: [set: ^set])
  end

  @doc "Returns `{source_name, torrent_count}` for every source."
  def count_torrents_by_source do
    Repo.all(
      from t in Torrent,
        join: s in assoc(t, :source),
        group_by: [s.id, s.name],
        order_by: [asc: s.name],
        select: {s.name, count(t.id)}
    )
  end

  ## Search

  @doc """
  Searches torrents by name, description and file names, best match first.

  `query` is a `t:Magnetissimo.Torrents.Query.t/0`, which may hold
  operators, or plain text, where nothing is an operator: Torznab clients
  send titles, which can begin with a dash or hold a quote. See
  `Magnetissimo.Torrents.Search` for how either is matched and ranked.
  Returns `[]` for input with nothing to search for.

  Takes the same options as `list_latest_torrents/1`, where `:sort` replaces
  best match first, and `:scope`: `:all` (the default) to match names,
  descriptions and file names, or `:name` for names only. The filters and the page are
  applied in SQL, so a page is always full while matches remain.
  """
  def search_torrents(term, opts \\ []) do
    limit = Keyword.get(opts, :limit, @search_limit)
    offset = Keyword.get(opts, :offset, 0)

    case search_query(term, opts, :page) do
      nil ->
        []

      {sql, params} ->
        %{rows: rows} = Repo.query!(sql, params ++ [limit, offset])
        rows |> Enum.map(&hd/1) |> load_torrents_in_order()
    end
  end

  @doc """
  Returns how many torrents `search_torrents/2` matches, so the UI can page.

  Takes the same filter options; input with nothing
  to search for matches nothing rather than everything.
  """
  def count_search_torrents(term, opts \\ []) do
    case search_query(term, opts, :count) do
      nil ->
        0

      {sql, params} ->
        %{rows: [[count]]} = Repo.query!(sql, params)
        count
    end
  end

  defp search_query(term, opts, kind) when is_binary(term) do
    search_query(Query.plain(term), opts, kind)
  end

  # Only a page in best match order needs scores. A count needs no column of
  # `torrents` either, unless a filter reads one: every match is a torrent,
  # since the indexes follow the table and a source hit goes with its torrent.
  defp search_query(%Query{} = query, opts, kind) do
    rank? = kind == :page and is_nil(opts[:sort])
    search_opts = [scope: Keyword.get(opts, :scope, :all), rank: rank?]

    with {matches, params} <- Search.matches(query, search_opts) do
      {filter, filter_params} = search_filter(opts)

      {select, join, tail} =
        case kind do
          :count when filter == "" -> {"count(*)", "", ""}
          :count -> {"count(*)", "JOIN torrents t ON t.id = m.id", ""}
          :page -> {"t.id", "JOIN torrents t ON t.id = m.id", page_tail(opts[:sort])}
        end

      sql = """
      WITH #{matches}
      SELECT #{select}
      FROM matches m
      #{join}
      #{filter}
      #{tail}
      """

      {sql, params ++ filter_params}
    end
  end

  defp search_query(_term, _opts, _kind), do: nil

  defp page_tail(sort), do: "ORDER BY #{Search.order_by(sort)} LIMIT ? OFFSET ?"

  defp search_filter(opts) do
    in_lists =
      for {column, ids} <- filters(opts), ids != [] do
        {"t.#{column} IN (#{Enum.map_join(ids, ", ", fn _ -> "?" end)})", ids}
      end

    bounds =
      for {column, bound, value} <- ranges(opts) do
        operator = if bound == :min, do: ">=", else: "<="
        {"t.#{column} #{operator} ?", [sql_value(value)]}
      end

    conditions = in_lists ++ bounds

    case conditions do
      [] ->
        {"", []}

      _ ->
        {"WHERE " <> Enum.map_join(conditions, " AND ", &elem(&1, 0)),
         Enum.flat_map(conditions, &elem(&1, 1))}
    end
  end

  defp sql_value(%DateTime{} = date), do: DateTime.to_iso8601(date)
  defp sql_value(value), do: value

  # The search returns ids in rank order; a single `where id in ^ids` query
  # would lose it, so the rows are re-sorted here.
  defp load_torrents_in_order([]), do: []

  defp load_torrents_in_order(ids) do
    by_id =
      from(t in Torrent, where: t.id in ^ids, preload: [:source])
      |> Repo.all()
      |> Map.new(&{&1.id, &1})

    Enum.flat_map(ids, fn id -> List.wrap(by_id[id]) end)
  end

  @doc """
  Returns `%{source_name => count}`: how many of the torrents each source
  returned for `term`, or for any of a list of terms, are filed under
  `category_id` or one of its children. A torrent returned for two of the
  terms counts once.

  A source that returned none in the category is left out. This is what lets
  the page say how much of a source's answer a category filter is hiding.
  """
  def count_search_hits_by_source(term, category_id) when is_binary(term) do
    count_search_hits_by_source([term], category_id)
  end

  def count_search_hits_by_source(terms, category_id) when is_list(terms) do
    terms = Enum.map(terms, &Search.normalize/1)

    Repo.all(
      from h in SearchHit,
        join: t in assoc(h, :torrent),
        join: s in assoc(h, :source),
        where: h.term in ^terms,
        where: t.category_id in ^Taxonomy.family_ids(category_id),
        group_by: s.name,
        select: {s.name, count(h.torrent_id, :distinct)}
    )
    |> Map.new()
  end

  @doc """
  Records that a source returned `torrent_ids` when asked for `term`, so the
  search finds them by that term from now on. Already recorded pairs are kept
  as they are.
  """
  def record_search_hits(term, source_id, torrent_ids) do
    insert_search_hits(term, Enum.map(torrent_ids, &{source_id, &1}))
  end

  defp insert_search_hits(_term, []), do: :ok

  defp insert_search_hits(term, hits) do
    term = Search.normalize(term)
    now = DateTime.utc_now()

    hits
    |> Enum.map(fn {source_id, torrent_id} ->
      %{term: term, source_id: source_id, torrent_id: torrent_id, inserted_at: now}
    end)
    |> Enum.chunk_every(5_000)
    |> Enum.each(fn rows ->
      {_count, _} = Repo.insert_all(SearchHit, rows, on_conflict: :nothing)
    end)
  end
end
