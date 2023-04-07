defmodule Magnetissimo.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :text
      add :url, :text

      timestamps(type: :utc_datetime_usec)
    end
  end
end
