defmodule Magnetissimo.Torrent do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias Magnetissimo.{Contents,Torrent}

  schema "torrents" do
    field :leechers,       :integer
    field :magnet,         :string
    field :name,           :string
    field :outbound_url,   :string
    field :seeders,        :integer
    field :size,           :string
    field :website_source, :string
    field :category,       :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `torrent` and `params`.
  """
  def changeset(%Torrent{}=torrent, attrs \\ %{}) do
    torrent
    |> cast(attrs, [:magnet, :seeders, :leechers, :name, :website_source, :size, :outbound_url])
    |> validate_required([:magnet, :seeders, :leechers, :name, :website_source, :size, :outbound_url])
    |> validate_number(:seeders, greater_than_or_equal_to: 0)
    |> validate_number(:leechers, greater_than_or_equal_to: 0)
    |> unique_constraint(:magnet, name: :unique_magnet_name)
    |> unique_constraint(:magnet, name: :torrents_magnet_index)
  end

  defdelegate save_torrent(torrent),                   to: Contents
  defdelegate total_by_website_source(website_source), to: Contents
end
