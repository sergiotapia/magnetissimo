defmodule Magnetissimo.Torrent do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias Magnetissimo.Torrent

  schema "torrents" do
    field(:magnet_url, :string)
    field(:name, :string)
    field(:canonical_url, :string)
    field(:website_source, :string)
    field(:leechers, :integer)
    field(:seeds, :integer)
    field(:size, :integer)
    field(:published_at, :naive_datetime)

    timestamps()
  end

  def changeset(%Torrent{} = torrent, attrs \\ %{}) do
    torrent
    |> cast(attrs, [
      :magnet_url,
      :name,
      :canonical_url,
      :website_source,
      :leechers,
      :seeds,
      :size,
      :published_at
    ])
    |> validate_required([
      :magnet_url,
      :name,
      :canonical_url,
      :website_source,
      :leechers,
      :seeds,
      :size
    ])
    |> validate_number(:seeds, greater_than_or_equal_to: 0)
    |> validate_number(:leechers, greater_than_or_equal_to: 0)
    |> unique_constraint(:magnet_url, name: :unique_magnet_url)
  end
end
