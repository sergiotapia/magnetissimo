defmodule Magnetissimo.Repo.Migrations.AddIndexToTorrentName do
  use Ecto.Migration

  def change do
    create index(:torrents, [:name])
  end
end
