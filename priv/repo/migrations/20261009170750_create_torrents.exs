defmodule Magnetissimo.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :name, :text, null: false
      add :description, :text
      add :canonical_url, :text, null: false
      add :published_at, :utc_datetime_usec, null: false
      add :leechers, :integer, null: false, default: 0
      add :seeders, :integer, null: false, default: 0
      add :size_in_bytes, :bigint, null: false
      add :magnet_hash, :text, null: false
      add :magnet_url, :text, null: false
      # A Torznab category number. The taxonomy lives in code
      # (Magnetissimo.Taxonomy), so there is no table to reference.
      add :category_id, :integer, null: false
      add :source_id, references(:sources, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:torrents, [:magnet_hash])

    # Every listing is `order by published_at desc limit 50`, which the old
    # schema left unindexed.
    create index(:torrents, [:published_at])
    create index(:torrents, [:category_id])
    create index(:torrents, [:source_id])
  end
end
