defmodule Magnetissimo.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :text
      add :slug, :text

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:categories, [:slug])
  end
end
