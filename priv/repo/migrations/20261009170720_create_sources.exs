defmodule Magnetissimo.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources) do
      add :name, :text, null: false
      add :url, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # The old schema looked sources up by name with Repo.one!/1 but never
    # constrained name, so a duplicate seed would raise at runtime instead of
    # at insert time.
    create unique_index(:sources, [:name])
  end
end
