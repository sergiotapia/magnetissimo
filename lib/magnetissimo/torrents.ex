defmodule Magnetissimo.Torrents do
  @moduledoc """
  The Torrents context.
  """

  import Ecto.Query, warn: false
  alias Magnetissimo.Repo

  alias Magnetissimo.Torrents.Category
  alias Magnetissimo.Torrents.Source
  alias Magnetissimo.Torrents.Torrent

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
    Repo.all(Torrent)
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
  def get_torrent!(id), do: Repo.get!(Torrent, id)

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
