defmodule Magnetissimo.Repo.Migrations.AddTorrentsTable do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :title, :text
      add :magnet_url, :text
      add :seeders, :integer
      add :leechers, :integer
      add :size, :text
      add :publication_date, :utc_datetime, null: false
      add :source_url, :text

      timestamps()
    end
  end
end