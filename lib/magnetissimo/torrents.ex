defmodule Magnetissimo.Torrents do
  @moduledoc """
  The Torrents context.
  """
  require Cachex
  require Logger

  import Ecto.Query, warn: false
  alias Magnetissimo.Repo

  alias Magnetissimo.Torrents.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
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
  def get_category!(id), do: Repo.get!(Category, id)

  def get_category_by_name_or_alias!(alias_name) do
    query =
      from(c in Category,
        where:
          ^alias_name in c.alternative_names or
            c.name == ^alias_name,
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
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Magnetissimo.Torrents.Source

  @doc """
  Returns the list of sources.

  ## Examples

      iex> list_sources()
      [%Source{}, ...]

  """
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
  def get_source!(id), do: Repo.get!(Source, id)

  def get_source_by_name!(name), do: Repo.get_by!(Source, name: name)

  @doc """
  Creates a source.

  ## Examples

      iex> create_source(%{field: value})
      {:ok, %Source{}}

      iex> create_source(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
  def delete_source(%Source{} = source) do
    Repo.delete(source)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking source changes.

  ## Examples

      iex> change_source(source)
      %Ecto.Changeset{data: %Source{}}

  """
  def change_source(%Source{} = source, attrs \\ %{}) do
    Source.changeset(source, attrs)
  end

  alias Magnetissimo.Torrents.Torrent

  @doc """
  Returns the list of torrents.

  ## Examples

      iex> list_torrents()
      [%Torrent{}, ...]

  """
  def list_torrents(limit \\ 50) do
    query =
      from t in Torrent,
        order_by: [desc: t.published_at],
        limit: ^limit,
        preload: [:category, :source]

    Repo.all(query)
  end

  @doc """
  Returns a list of torrents from the database by performing
  an ilike match against a Torrent's name and description.

  ## Examples

      iex> search_torrents("x265")
      [%Torrent{}, ...]

  """
  def search_torrents(filter_opts: filter_opts, offset: offset, limit: limit) do
    if filter_opts[:search] != "" do
      search_term = filter_opts[:search]

      case Cachex.get(:cache, search_term) do
        {:ok, nil} ->
          crawlers = [
            Magnetissimo.Crawlers.Leetx,
            Magnetissimo.Crawlers.TorrentDownloads,
            Magnetissimo.Crawlers.Yts
          ]

          Task.async_stream(
            crawlers,
            fn crawler_module ->
              crawler_module.search(search_term)
            end,
            ordered: false,
            timeout: :infinity
          )
          |> Stream.run()

          Cachex.put(:cache, search_term, search_term, ttl: :timer.hours(1))

        {:ok, search_term} ->
          Logger.info(
            "Cache (1hr) hit for search_term: `#{search_term}`. Skipping crawler search."
          )
      end
    end

    query =
      from(t in Torrent,
        as: :torrent,
        order_by: [desc: t.seeders],
        where: ^filter_where(filter_opts),
        offset: ^offset,
        limit: ^limit,
        preload: [:source, :category]
      )

    Repo.all(query)
  end

  def filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:search, ""}, dynamic ->
        dynamic

      {:search, search_term}, dynamic ->
        search_term = "%#{search_term}%"

        dynamic(
          [torrent: t],
          (^dynamic and like(t.name, ^"%#{search_term}%")) or
            like(t.description, ^"%#{search_term}%")
        )

      {_, _}, dynamic ->
        # Not a where parameter
        dynamic
    end)
  end

  @doc """
  Returns a list of crawler statistics for every source
  in the database. How many torrents we've indexed per source.

  ## Examples

      iex> list_crawler_statistics()
      [
        {"1337x", 200},
        {"rarbg", 123},
        {"yts", 39}
      ]
  """
  def list_crawler_statistics do
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
  Gets a single torrent.

  Raises `Ecto.NoResultsError` if the Torrent does not exist.

  ## Examples

      iex> get_torrent!(123)
      %Torrent{}

      iex> get_torrent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_torrent!(id), do: Repo.get!(Torrent, id) |> Repo.preload([:category, :source])

  @doc """
  Creates a torrent.

  ## Examples

      iex> create_torrent(%{field: value})
      {:ok, %Torrent{}}

      iex> create_torrent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_torrent(attrs \\ %{}) do
    %Torrent{}
    |> Torrent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a torrent.

  ## Examples

      iex> update_torrent(torrent, %{field: new_value})
      {:ok, %Torrent{}}

      iex> update_torrent(torrent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
  def delete_torrent(%Torrent{} = torrent) do
    Repo.delete(torrent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking torrent changes.

  ## Examples

      iex> change_torrent(torrent)
      %Ecto.Changeset{data: %Torrent{}}

  """
  def change_torrent(%Torrent{} = torrent, attrs \\ %{}) do
    Torrent.changeset(torrent, attrs)
  end
end
