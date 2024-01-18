defmodule Magnetissimo.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :text
      add :slug, :text
      add :alternative_names, {:array, :text}
      add :newznab_category_id, :text

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:categories, [:name])
    create unique_index(:categories, [:slug])
    create index(:categories, [:newznab_category_id])
  end
end
