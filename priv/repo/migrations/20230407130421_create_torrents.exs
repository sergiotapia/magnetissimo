defmodule Magnetissimo.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :text
      add :slug, :text
      add :description, :text
      add :canonical_url, :text
      add :published_at, :utc_datetime_usec
      add :leechers, :integer
      add :seeders, :integer
      add :size_in_bytes, :bigint
      add :magnet_url, :text
      add :category_id, references(:categories, on_delete: :nothing, type: :string)
      add :source_id, references(:sources, on_delete: :nothing, type: :string)

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:torrents, [:canonical_url])

    create index(:torrents, [:category_id])
    create index(:torrents, [:source_id])
  end
end
