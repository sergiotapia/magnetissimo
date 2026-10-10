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
  children; see `Magnetissimo.Taxonomy.family_ids/1`.
  """
  def count_torrents_by_category do
    Repo.all(
      from t in Torrent,
        group_by: t.category_id,
        select: {t.category_id, count(t.id)}
    )
    |> Map.new()
  end

  ## Torrents

  @doc "How many torrents a page of the UI holds."
  def per_page, do: @per_page

  @doc """
  Returns the most recently published torrents.

  ## Options

    * `:limit` - how many to return, 50 by default
    * `:offset` - skip this many, 0 by default, for paging
    * `:category_id` - only torrents filed under this category or, for a
      top-level one, any of its children
    * `:sort` - a `t:Magnetissimo.Torrents.Search.sort/0`, such as
      `{:seeders, :desc}`, in place of newest first

  """
  def list_latest_torrents(opts \\ []) do
    limit = Keyword.get(opts, :limit, @latest_limit)
    offset = Keyword.get(opts, :offset, 0)

    query = from t in Torrent, limit: ^limit, offset: ^offset, preload: [:source]

    query |> by_category(opts) |> sorted(opts[:sort]) |> Repo.all()
  end

  defp sorted(query, nil), do: order_by(query, [t], desc: t.published_at, desc: t.id)

  defp sorted(query, {:name, dir}) do
    order_by(query, [t], [{^dir, fragment("? COLLATE NOCASE", t.name)}, desc: t.id])
  end

  defp sorted(query, {field, dir}) when field in [:size_in_bytes, :seeders, :published_at] do
    order_by(query, [t], [{^dir, field(t, ^field)}, desc: t.id])
  end

  @doc "Returns how many torrents are indexed, or match `:category_id`."
  def count_torrents(opts \\ []) do
    Repo.aggregate(by_category(from(t in Torrent), opts), :count)
  end

  defp by_category(query, opts) do
    case Keyword.fetch(opts, :category_id) do
      {:ok, category_id} -> where(query, [t], t.category_id in ^Taxonomy.family_ids(category_id))
      :error -> query
    end
  end

  @doc "Returns when the newest torrent was published, or `nil` for an empty index."
  def latest_published_at do
    Repo.one(from t in Torrent, select: max(t.published_at))
  end

  @doc """
  Gets a single torrent with its source.

  Raises `Ecto.NoResultsError` if the torrent does not exist.
  """
  def get_torrent!(id) do
    Repo.get!(Torrent, id) |> Repo.preload(:source)
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
  stops showing the swarm it had on the day it was first found.

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
          %{valid?: true} = changeset -> {[row(changeset) | valid], rejected}
          changeset -> {valid, [{attrs, changeset.errors} | rejected]}
        end
      end)

    # One statement cannot upsert the same row twice, so a batch that lists a
    # hash twice keeps the first.
    rows = valid |> Enum.reverse() |> Enum.uniq_by(& &1.magnet_hash)

    {:ok, {ids, inserted}} =
      Repo.transact(fn ->
        {ids, inserted} = upsert(rows)

        if term = opts[:search_term] do
          insert_search_hits(term, Enum.zip(Enum.map(rows, & &1.source_id), ids))
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
    :source_id
  ]

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

  defp upsert(rows) do
    hashes = Enum.map(rows, & &1.magnet_hash)
    known = Repo.all(from t in Torrent, where: t.magnet_hash in ^hashes, select: t.magnet_hash)
    fallback_id = Taxonomy.other_id()

    refresh =
      from t in Torrent,
        update: [
          set: [
            seeders: fragment("excluded.seeders"),
            leechers: fragment("excluded.leechers"),
            updated_at: fragment("excluded.updated_at"),
            category_id:
              fragment(
                "CASE WHEN ? = ? THEN excluded.category_id ELSE ? END",
                t.category_id,
                ^fallback_id,
                t.category_id
              )
          ]
        ]

    # Chunked to stay well under SQLite's limit on bound parameters, 13 a row.
    id_by_hash =
      rows
      |> Enum.chunk_every(500)
      |> Enum.flat_map(fn chunk ->
        {_count, returned} =
          Repo.insert_all(Torrent, chunk,
            on_conflict: refresh,
            conflict_target: :magnet_hash,
            returning: [:id, :magnet_hash]
          )

        returned
      end)
      |> Map.new(&{&1.magnet_hash, &1.id})

    {Enum.map(hashes, &Map.fetch!(id_by_hash, &1)), length(hashes) - length(known)}
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
  Searches torrents by name and description, best match first.

  See `Magnetissimo.Torrents.Search` for how a term is matched and ranked.
  Returns `[]` for input with nothing to search for.

  Takes the same options as `list_latest_torrents/1`, where `:sort` replaces
  best match first. The category filter and the page are applied in SQL, so a
  page is always full while matches remain.
  """
  def search_torrents(term, opts \\ []) do
    limit = Keyword.get(opts, :limit, @search_limit)
    offset = Keyword.get(opts, :offset, 0)
    order = Search.order_by(opts[:sort])

    case search_query(term, opts, "t.id", "ORDER BY #{order} LIMIT ? OFFSET ?") do
      nil ->
        []

      {sql, params} ->
        %{rows: rows} = Repo.query!(sql, params ++ [limit, offset])
        rows |> Enum.map(&hd/1) |> load_torrents_in_order()
    end
  end

  @doc """
  Returns how many torrents `search_torrents/2` matches, so the UI can page.

  Takes the same `:category_id` option; input with nothing to search for
  matches nothing rather than everything.
  """
  def count_search_torrents(term, opts \\ []) do
    case search_query(term, opts, "count(*)", "") do
      nil ->
        0

      {sql, params} ->
        %{rows: [[count]]} = Repo.query!(sql, params)
        count
    end
  end

  defp search_query(term, opts, select, tail) when is_binary(term) do
    with {matches, params} <- Search.matches(term) do
      {filter, filter_params} =
        case Keyword.fetch(opts, :category_id) do
          {:ok, category_id} ->
            ids = Taxonomy.family_ids(category_id)
            {"WHERE t.category_id IN (#{Enum.map_join(ids, ", ", fn _ -> "?" end)})", ids}

          :error ->
            {"", []}
        end

      sql = """
      WITH #{matches}
      SELECT #{select}
      FROM matches m
      JOIN torrents t ON t.id = m.id
      #{filter}
      #{tail}
      """

      {sql, params ++ filter_params}
    end
  end

  defp search_query(_term, _opts, _select, _tail), do: nil

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
  returned for `term` are filed under `category_id` or one of its children.

  A source that returned none in the category is left out. This is what lets
  the page say how much of a source's answer a category filter is hiding.
  """
  def count_search_hits_by_source(term, category_id) do
    Repo.all(
      from h in SearchHit,
        join: t in assoc(h, :torrent),
        join: s in assoc(h, :source),
        where: h.term == ^Search.normalize(term),
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
