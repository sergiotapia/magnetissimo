defmodule Magnetissimo.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :name, :text
      add :slug, :text
      add :published_at, :utc_datetime_usec
      add :description, :text
      add :canonical_url, :text
      add :magnet_url, :text
      add :magnet_hash, :text
      add :leechers, :integer
      add :seeders, :integer
      add :size_in_bytes, :integer
      add :category_id, references(:categories, on_delete: :nothing)
      add :source_id, references(:sources, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:torrents, [:category_id])
    create index(:torrents, [:source_id])
    create index(:torrents, [:name])
    create index(:torrents, [:published_at])
  end
end
