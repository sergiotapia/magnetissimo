defmodule Magnetissimo.Repo.Migrations.CreateTorrent do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add :name, :text
      add :magnet, :text
      add :leechers, :integer
      add :seeders, :integer
      add :source, :text

      timestamps()
    end

  end
end
