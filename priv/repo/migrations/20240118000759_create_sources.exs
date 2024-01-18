defmodule Magnetissimo.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources) do
      add :name, :text
      add :slug, :text
      add :url, :text

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:sources, [:name])
    create unique_index(:sources, [:slug])
  end
end
