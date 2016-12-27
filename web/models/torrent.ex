defmodule Magnetissimo.Torrent do
  use Magnetissimo.Web, :model
  require Logger
  alias Magnetissimo.Repo
  alias Magnetissimo.Torrent

  schema "torrents" do
    field :magnet, :string
    field :seeders, :integer
    field :leechers, :integer
    field :name, :string
    field :website_source, :string
    field :size, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:magnet, :seeders, :leechers, :name, :website_source, :size])
    |> validate_required([:magnet, :seeders, :leechers, :name, :website_source, :size])
    |> validate_number(:seeders, greater_than_or_equal_to: 0)
    |> validate_number(:leechers, greater_than_or_equal_to: 0)
    |> unique_constraint(:magnet)
  end

  def save_torrent(torrent) do
    changeset = Torrent.changeset(%Torrent{}, torrent)
    case Repo.insert(changeset) do
      {:ok, _torrent} ->
        Logger.info "Torrent saved to database: #{torrent.name}"
      {:error, changeset} ->
        Logger.error "Couldn't save: #{torrent.name}"
        IO.inspect changeset.errors
    end
  end
end
