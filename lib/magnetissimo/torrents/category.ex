defmodule Magnetissimo.Torrents.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Helpers
  alias Magnetissimo.Torrents.Torrent

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :alternative_names, {:array, :string}

    has_many :torrents, Torrent

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> Helpers.slugify()
  end
end
