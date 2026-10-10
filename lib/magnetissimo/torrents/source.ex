defmodule Magnetissimo.Torrents.Source do
  @moduledoc """
  A site we crawl torrents from.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Torrents.Torrent

  schema "sources" do
    field :name, :string
    field :url, :string
    field :last_crawled_at, :utc_datetime_usec

    has_many :torrents, Torrent

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> unique_constraint(:name)
  end
end
