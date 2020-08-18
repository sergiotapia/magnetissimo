defmodule Magnetissimo.Torrent do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias Magnetissimo.{Repo, Torrent}

  schema "torrents" do
    field(:magnet_url, :string)
    field(:name, :string)
    field(:canonical_url, :string)
    field(:website_source, :string)
    field(:leechers, :integer, default: 0)
    field(:seeds, :integer, default: 0)
    field(:size, :integer, default: 0)
    field(:published_at, :utc_datetime)
    field(:magnet_hash, :string, default: "")

    timestamps([type: :utc_datetime])
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
      :published_at,
      :magnet_hash
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

  def save(torrent) do
    with {:error, changeset} <- Repo.insert(torrent, on_conflict: :nothing) do
      Logger.error("[#{__MODULE__}] Error inserting: #{get_field(torrent, :name)} (#{get_field(torrent, :canonical_url)})")
      Logger.error("[#{__MODULE__}] #{get_field(torrent, :errors)}")
      Logger.debug("#{IO.inspect(changeset)}")
      {:error, changeset}
    end
  end

end
