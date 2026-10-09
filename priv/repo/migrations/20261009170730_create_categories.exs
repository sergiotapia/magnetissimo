defmodule Magnetissimo.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :text, null: false
      add :parent_id, references(:categories, on_delete: :restrict), null: true

      timestamps(type: :utc_datetime_usec)
    end

    # Names are fully qualified ("Video - Movies"), so a global unique index
    # replaces the old slug column, which nothing read.
    create unique_index(:categories, [:name])
    create index(:categories, [:parent_id])
  end
end
