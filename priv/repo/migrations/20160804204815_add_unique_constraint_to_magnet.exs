defmodule Magnetissimo.Repo.Migrations.AddUniqueConstraintToMagnet do
  use Ecto.Migration

  def change do
	create unique_index(:torrents, [:magnet])
  end
end
