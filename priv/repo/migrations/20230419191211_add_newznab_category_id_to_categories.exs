defmodule Magnetissimo.Repo.Migrations.AddNewznabCategoryIdToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :newznab_category_id, :text
    end

    create index(:categories, [:newznab_category_id])
  end
end
