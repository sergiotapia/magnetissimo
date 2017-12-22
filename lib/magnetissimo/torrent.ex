defmodule Magnetissimo.Torrent do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias Magnetissimo.{Contents,Torrent}

  schema "torrents" do
    field :magnet,         :string
    field :seeders,        :integer
    field :leechers,       :integer
    field :name,           :string
    field :website_source, :string
    field :size,           :string
    field :outbound_url,   :string

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
    |> unique_constraint(:magnet)
  end

  defdelegate save_torrent(torrent),                   to: Contents
  defdelegate total_by_website_source(website_source), to: Contents
end
