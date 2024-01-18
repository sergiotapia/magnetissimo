defmodule Magnetissimo.Torrents.Source do
  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Helpers
  alias Magnetissimo.Torrents.Torrent

  schema "sources" do
    field :name, :string
    field :url, :string
    field :slug, :string

    has_many :torrents, Torrent

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :slug, :url])
    |> validate_required([:name, :slug, :url])
    |> Helpers.slugify()
  end
end
