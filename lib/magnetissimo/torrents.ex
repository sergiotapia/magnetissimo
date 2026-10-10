defmodule Magnetissimo.Torrents do
  @moduledoc """
  The torrents context: the sites we crawl, the canonical category tree, and the
  indexed torrents.

  Searching goes through `search_torrents/2`, which queries the two FTS5
  indexes. Read `Magnetissimo.Torrents.Search` before writing anything else
  that talks to them.
  """

  import Ecto.Query, warn: false

  alias Magnetissimo.Repo
  alias Magnetissimo.Torrents.Category
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

  @doc "Returns every category, parents and children, with their aliases."
  def list_categories do
    Repo.all(
      from c in Category,
        order_by: [asc: c.name],
        preload: [:category_aliases]
    )
  end

  @doc """
  Returns the top-level categories with their children, both ordered by name.

  "Other" has no children, so it comes back as a childless parent: it is the
  one category a torrent can be filed under directly.
  """
  def list_category_tree do
    children = from(c in Category, order_by: [asc: c.name])

    Repo.all(
      from c in Category,
        where: is_nil(c.parent_id),
        order_by: [asc: c.name],
        preload: [children: ^children]
    )
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the category does not exist.
  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc "Returns `%{category_id => torrent_count}` for every category with torrents."
  def count_torrents_by_category do
    Repo.all(
      from t in Torrent,
        group_by: t.category_id,
        select: {t.category_id, count(t.id)}
    )
    |> Map.new()
  end

  @doc """
  Resolves a site's own category wording to a canonical category.

  Aliases win over names, then the canonical name is matched, then `"Other"`.
  Alias-first ordering matters: `"Anime"` is both a top-level category and an
  alias for `"Anime - English-translated"`, and the alias is the intended
  target. Only children are matchable — parents exist to group the tree and are
  never assigned to a torrent.
  """
  def get_category_by_name_or_alias!(name_or_alias) do
    find_category_by_alias(name_or_alias) ||
      find_category_by_name(name_or_alias) ||
      get_fallback_category!()
  end

  defp find_category_by_alias(name) do
    Repo.one(
      from c in Category,
        join: a in assoc(c, :category_aliases),
        where: a.name == ^name
    )
  end

  defp find_category_by_name(name) do
    Repo.one(
      from c in Category,
        where: c.name == ^name and not is_nil(c.parent_id)
    )
  end

  defp get_fallback_category! do
    Repo.get_by!(Category, name: Category.fallback())
  end

  ## Torrents

  @doc "How many torrents a page of the UI holds."
  def per_page, do: @per_page

  @doc """
  Returns the most recently published torrents.

  ## Options

    * `:limit` - how many to return, 50 by default
    * `:offset` - skip this many, 0 by default, for paging
    * `:category_id` - only torrents filed under this category

  """
  def list_latest_torrents(opts \\ []) do
    limit = Keyword.get(opts, :limit, @latest_limit)
    offset = Keyword.get(opts, :offset, 0)

    query =
      from t in Torrent,
        order_by: [desc: t.published_at, desc: t.id],
        limit: ^limit,
        offset: ^offset,
        preload: [:source, :category]

    Repo.all(by_category(query, opts))
  end

  @doc "Returns how many torrents are indexed, or match `:category_id`."
  def count_torrents(opts \\ []) do
    Repo.aggregate(by_category(from(t in Torrent), opts), :count)
  end

  defp by_category(query, opts) do
    case Keyword.fetch(opts, :category_id) do
      {:ok, category_id} -> where(query, [t], t.category_id == ^category_id)
      :error -> query
    end
  end

  @doc "Returns when the newest torrent was published, or `nil` for an empty index."
  def latest_published_at do
    Repo.one(from t in Torrent, select: max(t.published_at))
  end

  @doc """
  Gets a single torrent with its source and category.

  Raises `Ecto.NoResultsError` if the torrent does not exist.
  """
  def get_torrent!(id) do
    Repo.get!(Torrent, id) |> Repo.preload([:source, :category])
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

  Takes the same options as `list_latest_torrents/1`. The category filter and
  the page are applied in SQL, so a page is always full while matches remain.
  """
  def search_torrents(term, opts \\ []) do
    limit = Keyword.get(opts, :limit, @search_limit)
    offset = Keyword.get(opts, :offset, 0)

    case search_query(term, opts, "t.id", "ORDER BY #{Search.order_by()} LIMIT ? OFFSET ?") do
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
          {:ok, category_id} -> {"WHERE t.category_id = ?", [category_id]}
          :error -> {"", []}
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
      from(t in Torrent, where: t.id in ^ids, preload: [:source, :category])
      |> Repo.all()
      |> Map.new(&{&1.id, &1})

    Enum.flat_map(ids, fn id -> List.wrap(by_id[id]) end)
  end

  @doc """
  Records that a source returned `torrent_ids` when asked for `term`, so the
  search finds them by that term from now on. Already recorded pairs are kept
  as they are.
  """
  def record_search_hits(_term, []), do: :ok

  def record_search_hits(term, torrent_ids) do
    term = Search.normalize(term)
    now = DateTime.utc_now()

    rows = Enum.map(torrent_ids, &%{term: term, torrent_id: &1, inserted_at: now})
    {_count, _} = Repo.insert_all(SearchHit, rows, on_conflict: :nothing)

    :ok
  end
end
