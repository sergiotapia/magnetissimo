defmodule Magnetissimo.Torrents.Source do
  @moduledoc """
  A site whose own search we ask for torrents.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Torrents.Torrent

  schema "sources" do
    field :name, :string
    field :url, :string

    has_many :torrents, Torrent

    timestamps(type: :utc_datetime_usec)
  end

  @doc "Casts a `Magnetissimo.Seeds` row. Names are unique."
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> unique_constraint(:name)
  end
end
