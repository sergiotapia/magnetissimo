defmodule Magnetissimo.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :magnet_url, :string
      add :canonical_url, :string
      add :leechers, :string
      add :seeders, :string
      add :size_in_bytes, :string
      add :published_at, :naive_datetime

      timestamps()
    end

  end
end
