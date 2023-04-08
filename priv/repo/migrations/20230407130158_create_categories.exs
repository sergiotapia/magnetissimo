defmodule Magnetissimo.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:name, :text)
      add(:slug, :text)
      add(:alternative_names, {:array, :text})
      add(:parent_id, references(:categories, on_delete: :nothing, type: :string), null: true)

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:categories, [:slug]))
    create(index(:categories, [:parent_id]))
  end
end
