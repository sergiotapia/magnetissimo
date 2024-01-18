defmodule Magnetissimo.Torrents.Torrent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Helpers
  alias Magnetissimo.Torrents.Category
  alias Magnetissimo.Torrents.Source

  schema "torrents" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :published_at, :utc_datetime_usec
    field :canonical_url, :string
    field :magnet_url, :string
    field :magnet_hash, :string
    field :leechers, :integer
    field :seeders, :integer
    field :size_in_bytes, :integer

    belongs_to :category, Category
    belongs_to :source, Source

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(torrent, attrs) do
    torrent
    |> cast(attrs, [
      :name,
      :slug,
      :published_at,
      :description,
      :canonical_url,
      :magnet_url,
      :magnet_hash,
      :leechers,
      :seeders,
      :size_in_bytes,
      :category_id,
      :source_id
    ])
    |> Helpers.slugify()
    |> validate_required([
      :name,
      :slug,
      :published_at,
      :canonical_url,
      :magnet_url,
      :magnet_hash,
      :leechers,
      :seeders,
      :size_in_bytes,
      :category_id,
      :source_id
    ])
  end
end
