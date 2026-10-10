defmodule Magnetissimo.Torrents.Torrent do
  @moduledoc """
  A single indexed torrent.

  Identity is `magnet_hash` (the BitTorrent v1 infohash), not the name: one
  source page can yield several torrents that share a name — YTS returns 720p,
  1080p and 2160p for one movie — and only the hash tells them apart.

  `magnet_url` holds the complete magnet URI, scheme included, exactly as it
  should be handed to a client.

  `category_id` is a Torznab category number (`2045` is Movies/UHD); see
  `Magnetissimo.Taxonomy`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents.Source

  schema "torrents" do
    field :name, :string
    field :description, :string
    field :canonical_url, :string
    field :published_at, :utc_datetime_usec
    field :leechers, :integer, default: 0
    field :seeders, :integer, default: 0
    field :size_in_bytes, :integer
    field :magnet_hash, :string
    field :magnet_url, :string

    # A Torznab number from Magnetissimo.Taxonomy, not a foreign key.
    field :category_id, :integer
    belongs_to :source, Source

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Casts a crawler's attrs. A row is refused unless its hash is 40 lowercase
  hex characters, its magnet a complete `magnet:?xt=urn:btih:` URI, and its
  category a Torznab number.
  """
  def changeset(torrent, attrs) do
    torrent
    |> cast(attrs, [
      :name,
      :description,
      :canonical_url,
      :published_at,
      :leechers,
      :seeders,
      :size_in_bytes,
      :magnet_hash,
      :magnet_url,
      :category_id,
      :source_id
    ])
    |> validate_required([
      :name,
      :canonical_url,
      :published_at,
      :size_in_bytes,
      :magnet_hash,
      :magnet_url,
      :category_id,
      :source_id
    ])
    |> validate_length(:magnet_hash, is: 40)
    |> validate_format(:magnet_hash, ~r/^[0-9a-f]{40}$/,
      message: "must be a 40-character lowercase hex BitTorrent v1 infohash"
    )
    |> validate_format(:magnet_url, ~r/^magnet:\?xt=urn:btih:/,
      message: "must be a complete magnet URI starting with magnet:?xt=urn:btih:"
    )
    |> unique_constraint(:magnet_hash)
    |> validate_inclusion(:category_id, Taxonomy.ids(), message: "is not a Torznab category")
    |> foreign_key_constraint(:source_id)
  end
end
