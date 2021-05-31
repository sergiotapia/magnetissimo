defmodule Magnetissimo.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text
      add :magnet_url, :text
      add :canonical_url, :text
      add :leechers, :text
      add :seeders, :text
      add :size_in_bytes, :text
      add :published_at, :naive_datetime

      timestamps()
    end

  end
end
