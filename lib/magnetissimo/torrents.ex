defmodule Magnetissimo.Torrents do
  @moduledoc """
  The Torrents context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Magnetissimo.Repo

  alias Magnetissimo.Torrents.Torrent
  alias Magnetissimo.Torrents.Category
  alias Magnetissimo.Torrents.Source
  alias Magnetissimo.Torrents.Torrent

  @doc """
  Returns a list of crawler statistics for every source
  in the database. How many torrents we've indexed per source.

  ## Examples

      iex> get_crawler_statistics()
      [
        {"1337x", 200},
        {"rarbg", 123},
        {"yts", 39}
      ]
  """
  @spec get_crawler_statistics() :: [{binary(), integer()}]
  def get_crawler_statistics do
    query =
      from(t in Torrent,
        inner_join: source in assoc(t, :source),
        group_by: [source.name, source.id],
        order_by: [asc: source.name],
        select: {source.name, count(t.id)}
      )

    Repo.all(query)
  end

  @doc """
  Creates Oban jobs for each out crawlers for the given
  search term. Uniqueness is validated per 24 hours to avoid
  duplicate crawls.

  ## Examples

      iex> enqueue_crawls_for_search_term("x265")
      :ok
  """
  @spec enqueue_crawls_for_search_term(binary()) :: :ok
  def enqueue_crawls_for_search_term(search_term) do
    keys = [:search_term]

    {:ok, _} =
      %{search_term: search_term}
      |> Magnetissimo.Workers.Nyaa.new(
        unique: [fields: [:args, :worker], keys: keys, period: 86400]
      )
      |> Oban.insert()

    {:ok, _} =
      %{search_term: search_term}
      |> Magnetissimo.Workers.TorrentDownloads.new(
        unique: [fields: [:args, :worker], keys: keys, period: 86400]
      )
      |> Oban.insert()

    {:ok, _} =
      %{search_term: search_term}
      |> Magnetissimo.Workers.Yts.new(
        unique: [fields: [:args, :worker], keys: keys, period: 86400]
      )
      |> Oban.insert()

    {:ok, _} =
      %{search_term: search_term}
      |> Magnetissimo.Workers.Leetx.new(
        unique: [fields: [:args, :worker], keys: keys, period: 86400]
      )
      |> Oban.insert()

    :ok
  end

  @doc """
  Returns the list of torrents by performing a full-text
  search against the name and description fields.

  ## Examples

      iex> search_torrents("x265")
      [%Torrent{}, ...]
  """
  @spec search_torrents(binary()) :: [Torrent.t()]
  def search_torrents(search_term) do
    enqueue_crawls_for_search_term(search_term)

    query =
      from(t in Torrent,
        where:
          fragment(
            "search_vector @@ websearch_to_tsquery(?)",
            ^search_term
          ),
        order_by: {
          :desc,
          fragment(
            "ts_rank_cd(search_vector, websearch_to_tsquery(?), 4)",
            ^search_term
          )
        },
        preload: [:source, :category]
      )

    Repo.all(query)
  end

  @doc """
  Returns the list of sources.

  ## Examples

      iex> list_sources()
      [%Source{}, ...]

  """
  @spec list_sources() :: [Source.t()]
  def list_sources do
    Repo.all(Source)
  end

  @doc """
  Gets a single source.

  Raises `Ecto.NoResultsError` if the Source does not exist.

  ## Examples

      iex> get_source!(123)
      %Source{}

      iex> get_source!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_source!(binary()) :: Source.t()
  def get_source!(id), do: Repo.get!(Source, id)

  @spec get_source_by_name!(binary()) :: Source.t()
  def get_source_by_name!(name) do
    Repo.one!(from(s in Source, where: s.name == ^name))
  end

  @doc """
  Creates a source.

  ## Examples

      iex> create_source(%{field: value})
      {:ok, %Source{}}

      iex> create_source(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_source(map()) :: {:ok, Source.t()} | {:error, Ecto.Changeset.t()}
  def create_source(attrs \\ %{}) do
    %Source{}
    |> Source.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a source.

  ## Examples

      iex> update_source(source, %{field: new_value})
      {:ok, %Source{}}

      iex> update_source(source, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_source(Source.t(), map()) :: {:ok, Source.t()} | {:error, Ecto.Changeset.t()}
  def update_source(%Source{} = source, attrs) do
    source
    |> Source.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a source.

  ## Examples

      iex> delete_source(source)
      {:ok, %Source{}}

      iex> delete_source(source)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_source(Source.t()) :: {:ok, Source.t()} | {:error, Ecto.Changeset.t()}
  def delete_source(%Source{} = source) do
    Repo.delete(source)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking source changes.

  ## Examples

      iex> change_source(source)
      %Ecto.Changeset{data: %Source{}}

  """
  @spec change_source(Source.t(), map()) :: Ecto.Changeset.t()
  def change_source(%Source{} = source, attrs \\ %{}) do
    Source.changeset(source, attrs)
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  @spec list_categories() :: [Category.t()]
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_category!(binary()) :: Category.t()
  def get_category!(id), do: Repo.get!(Category, id)

  @spec get_category_by_name!(binary()) :: Category.t()
  def get_category_by_name!(name) do
    Repo.one!(from(c in Category, where: c.name == ^name))
  end

  @doc """
  Gets a single category by name or alias.

  Raises `Ecto.NoResultsError` if the Category does not exist.
  """
  @spec get_category_by_name_or_alias!(binary()) :: Category.t()
  def get_category_by_name_or_alias!("Other") do
    Repo.one!(from(c in Category, where: c.name == "Other"))
  end

  def get_category_by_name_or_alias!(alias_name) do
    query =
      from(c in Category,
        where:
          fragment("parent_id IS NOT NULL") and
            (fragment("? = ANY(alternative_names)", ^alias_name) or
               fragment("name = ?", ^alias_name)),
        select: c,
        limit: 1
      )

    case Repo.one(query) do
      nil ->
        Repo.one!(from(c in Category, where: c.name == "Other"))

      category ->
        category
    end
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_category(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_category(Category.t(), map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_category(Category.t()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  @spec change_category(Category.t(), map()) :: Ecto.Changeset.t()
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  @doc """
  Returns the list of torrents.

  ## Examples

      iex> list_torrents()
      [%Torrent{}, ...]

  """
  @spec list_torrents() :: [Torrent.t()]
  def list_torrents do
    q =
      from(t in Torrent,
        preload: [:source, :category],
        order_by: [desc: t.published_at],
        limit: 25
      )

    Repo.all(q)
  end

  @doc """
  Gets a single torrent.

  Raises `Ecto.NoResultsError` if the Torrent does not exist.

  ## Examples

      iex> get_torrent!(123)
      %Torrent{}

      iex> get_torrent!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_torrent!(binary()) :: Torrent.t()
  def get_torrent!(id), do: Repo.get!(Torrent, id) |> Repo.preload([:category, :source])

  @doc """
  Creates a torrent.

  ## Examples

      iex> create_torrent(%{field: value})
      {:ok, %Torrent{}}

      iex> create_torrent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_torrent(map()) :: {:ok, Torrent.t()} | {:error, Ecto.Changeset.t()}
  def create_torrent(attrs \\ %{}) do
    %Torrent{}
    |> Torrent.changeset(attrs)
    |> Repo.insert()
  end

  def create_torrent_for_source(torrent_attrs, source_name) do
    case create_torrent(torrent_attrs) do
      {:ok, torrent} ->
        Logger.info(
          "[#{source_name}] Creating torrent: #{torrent_attrs.name} (#{torrent_attrs.canonical_url})"
        )

        {:ok, torrent}

      {:error, changeset} ->
        Logger.error(
          "[#{source_name}] Skipped creating torrent: #{torrent_attrs.name} (#{torrent_attrs.canonical_url}) - reason: #{inspect(changeset.errors)}"
        )

        {:error, changeset}
    end
  end

  @doc """
  Updates a torrent.

  ## Examples

      iex> update_torrent(torrent, %{field: new_value})
      {:ok, %Torrent{}}

      iex> update_torrent(torrent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_torrent(Torrent.t(), map()) :: {:ok, Torrent.t()} | {:error, Ecto.Changeset.t()}
  def update_torrent(%Torrent{} = torrent, attrs) do
    torrent
    |> Torrent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a torrent.

  ## Examples

      iex> delete_torrent(torrent)
      {:ok, %Torrent{}}

      iex> delete_torrent(torrent)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_torrent(Torrent.t()) :: {:ok, Torrent.t()} | {:error, Ecto.Changeset.t()}
  def delete_torrent(%Torrent{} = torrent) do
    Repo.delete(torrent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking torrent changes.

  ## Examples

      iex> change_torrent(torrent)
      %Ecto.Changeset{data: %Torrent{}}

  """
  @spec change_torrent(Torrent.t(), map()) :: Ecto.Changeset.t()
  def change_torrent(%Torrent{} = torrent, attrs \\ %{}) do
    Torrent.changeset(torrent, attrs)
  end
end
