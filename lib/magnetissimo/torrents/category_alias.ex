defmodule Magnetissimo.Torrents.CategoryAlias do
  @moduledoc """
  A site's own wording for a category, mapped onto a canonical category.

  Nyaa says "Anime - Anime Music Video" where we say "Anime - Music Video";
  YTS says "Movies" where we say "Video - Movies". These strings used to live
  in a Postgres `text[]` column on `categories`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Torrents.Category

  schema "category_aliases" do
    field :name, :string

    belongs_to :category, Category

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(category_alias, attrs) do
    category_alias
    |> cast(attrs, [:name, :category_id])
    |> validate_required([:name, :category_id])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:category_id)
  end
end
