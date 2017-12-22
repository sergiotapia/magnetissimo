defmodule Magnetissimo.Repo.Migrations.Createtorrents do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :leechers, :integer
      add :magnet, :text
      add :name, :text
      add :outbound_url, :string
      add :seeders, :integer
      add :size, :string
      add :website_source, :string

      timestamps()
    end

    create index(:torrents, [:name])
    create index(:torrents, [:website_source])
end
