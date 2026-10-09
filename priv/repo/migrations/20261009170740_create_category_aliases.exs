defmodule Magnetissimo.Repo.Migrations.CreateCategoryAliases do
  use Ecto.Migration

  def change do
    create table(:category_aliases) do
      add :name, :text, null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Replaces the old Postgres text[] column plus its
    # `? = ANY(alternative_names)` fragment, which had no SQLite equivalent.
    # An exact-match index also avoids the substring false positives a JSON or
    # LIKE lookup would have ("TV" matching "TV Shows").
    create unique_index(:category_aliases, [:name])
    create index(:category_aliases, [:category_id])
  end
end
