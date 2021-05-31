defmodule Magnetissimo.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text
      add :magnet_url, :text
      add :canonical_url, :text
      add :leechers, :text, default: "0"
      add :seeders, :text, default: "0"
      add :size_in_bytes, :text
      add :published_at, :naive_datetime

      timestamps()
    end

    create unique_index(:torrents, [:magnet_url], name: :unique_magnet_url)
  end
end
