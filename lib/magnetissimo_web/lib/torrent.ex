defmodule Magnetissimo.Torrent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Magnetissimo.Torrent
  alias Magnetissimo.Repo

  schema "torrents" do
    field :title, :string
    field :magnet_url, :string
    field :seeders, :integer
    field :leechers, :integer
    field :size, :string
    field :publication_date, :utc_datetime
    field :source_url, :string

    timestamps()
  end

  def save(torrent_params) do
    IO.inspect torrent_params
    result =
      %Torrent{}
      |> changeset(torrent_params)
      |> Repo.insert()

    case result do
      {:ok, torrent} ->
        IO.puts "Saved: #{torrent.id} - #{torrent.title}"
      {:error, changeset} ->
        IO.inspect changeset
    end
  end

  def changeset(%Torrent{} = struct, params) do
    struct
    |> cast(params, [:title, :magnet_url, :seeders, :leechers, :size, :publication_date, :source_url])
    |> validate_required([:title, :magnet_url, :seeders, :leechers, :size, :publication_date, :source_url])
  end
end