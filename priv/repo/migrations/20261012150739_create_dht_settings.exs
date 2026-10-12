defmodule Magnetissimo.Repo.Migrations.CreateDhtSettings do
  use Ecto.Migration

  # The DHT crawler's settings, switched on the /dht page: one row, written
  # the first time someone changes them. Until then the crawler is off, at
  # the gentle rate.
  def change do
    create table(:dht_settings) do
      add :enabled, :boolean, null: false, default: false
      add :rate, :string, null: false, default: "gentle"

      timestamps(type: :utc_datetime_usec)
    end
  end
end
