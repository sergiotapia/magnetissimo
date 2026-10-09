defmodule Magnetissimo.Torrents.Category do
  @moduledoc """
  A canonical category, two levels deep.

  Top-level rows are the broad groups (Video, Audio, Books, ...) and child rows
  are what a torrent is actually filed under ("Video - Movies"). Only children
  are ever assigned to a torrent.

  Each site names its categories differently, so the strings a site uses are
  mapped onto a canonical category through `Magnetissimo.Torrents.CategoryAlias`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Torrents.CategoryAlias
  alias Magnetissimo.Torrents.Torrent

  @fallback "Other"

  schema "categories" do
    field :name, :string

    belongs_to :parent_category, __MODULE__, foreign_key: :parent_id
    has_many :children, __MODULE__, foreign_key: :parent_id
    has_many :category_aliases, CategoryAlias
    has_many :torrents, Torrent

    timestamps(type: :utc_datetime_usec)
  end

  @doc "The category every unresolved site category falls back to."
  def fallback, do: @fallback

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :parent_id])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:parent_id)
  end
end
