defmodule Magnetissimo.Repo.Migrations.CreateTorrentsTable do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :leechers, :integer, null: false
      add :magnet_url, :text, null: false
      add :name, :text, null: false
      add :canonical_url, :text, null: false
      add :seeds, :integer, null: false
      add :size, :integer, null: false
      add :website_source, :text, null: false
      add :published_at, :naive_datetime

      timestamps()
    end

    create index(:torrents, [:name])
    create index(:torrents, [:website_source])
    create unique_index(:torrents, [:magnet_url], name: :unique_magnet_url)
  end
end
