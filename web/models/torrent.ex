defmodule Magnetissimo.Torrent do
  use Magnetissimo.Web, :model
  alias Magnetissimo.Repo
  alias Magnetissimo.Torrent

  require Logger

  schema "torrents" do
    field :name, :string
    field :magnet, :string
    field :leechers, :integer
    field :seeders, :integer
    field :source, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :magnet, :leechers, :seeders, :source])
    |> validate_required([:name, :magnet, :leechers, :seeders, :source])
    |> validate_number(:leechers, greater_than: 0)
    |> validate_number(:seeders, greater_than: 0)
    |> unique_constraint(:magnet)
  end

  def save_torrent(torrent) do
    changeset = Torrent.changeset(%Torrent{}, torrent)
    case Repo.insert(changeset) do
      {:ok, _torrent} ->
        Logger.info "Torrent saved to database: #{torrent.name}"
      {:error, _changeset} ->
        Logger.info "Duplicate torrent: #{torrent.name}"
    end
  end
end
