defmodule Magnetissimo.Torrents do
  @moduledoc """
  The torrents context: the sites we crawl, the canonical category tree, and the
  indexed torrents.

  Searching goes through `search_torrents/2`, which queries the `torrents_search`
  FTS5 index. Read `match_query/1` before writing anything else that talks to
  that index.
  """

  import Ecto.Query, warn: false

  alias Magnetissimo.Repo
  alias Magnetissimo.Torrents.Category
  alias Magnetissimo.Torrents.Source
  alias Magnetissimo.Torrents.Torrent

  @latest_limit 50
  @search_limit 50

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

  @doc "Returns the most recently published torrents."
  def list_latest_torrents(limit \\ @latest_limit) do
    Repo.all(
      from t in Torrent,
        order_by: [desc: t.published_at],
        limit: ^limit,
        preload: [:source, :category]
    )
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
  Full-text searches torrents by name and description, best match first.

  A name match outranks a description match ten to one, so a title beats a plot
  summary that happens to mention the same word. Returns `[]` for blank input.
  """
  def search_torrents(term, limit \\ @search_limit) do
    case match_query(term) do
      nil ->
        []

      match ->
        match
        |> matching_torrent_ids(limit)
        |> load_torrents_in_order()
    end
  end

  @doc """
  Turns free text into an FTS5 `MATCH` expression, or `nil` when there is
  nothing to search for.

  Every token is wrapped in double quotes. Raw user input must never reach
  `MATCH` unquoted, because FTS5 parses its argument as a query language, so
  ordinary search text kills the query with a syntax error:

      ubuntu:24.04 -> no such column: ubuntu
      x265-        -> fts5: syntax error near ""
      foo(bar)     -> fts5: syntax error near "foo"
      NOT          -> fts5: syntax error near "NOT"
      *            -> unknown special query

  Quoting also neutralises the boolean operators, so a user searching for `OR`
  gets torrents containing "or" rather than a query matching everything. The
  trailing `*` makes the final token a prefix match, which is what typing into
  a search box needs.
  """
  def match_query(term) when is_binary(term) do
    tokens = term |> String.split(~r/\s+/, trim: true) |> Enum.map(&quote_token/1)

    case tokens do
      [] -> nil
      _ -> tokens |> List.update_at(-1, &(&1 <> "*")) |> Enum.join(" ")
    end
  end

  def match_query(_term), do: nil

  defp quote_token(token), do: ~s("#{String.replace(token, "\"", "\"\"")}")

  defp matching_torrent_ids(match, limit) do
    # bm25's weights must be literals: 10x for name, 1x for description.
    sql = """
    SELECT rowid
    FROM torrents_search
    WHERE torrents_search MATCH ?
    ORDER BY bm25(torrents_search, 10.0, 1.0)
    LIMIT ?
    """

    %{rows: rows} = Repo.query!(sql, [match, limit])
    Enum.map(rows, &hd/1)
  end

  # The FTS index returns ids in relevance order; a single `where id in ^ids`
  # query would lose it, so the rows are re-sorted here.
  defp load_torrents_in_order([]), do: []

  defp load_torrents_in_order(ids) do
    by_id =
      from(t in Torrent, where: t.id in ^ids, preload: [:source, :category])
      |> Repo.all()
      |> Map.new(&{&1.id, &1})

    Enum.flat_map(ids, fn id -> List.wrap(by_id[id]) end)
  end
end
