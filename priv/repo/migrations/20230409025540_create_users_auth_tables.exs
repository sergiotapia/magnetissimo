defmodule Magnetissimo.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    create table(:users, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:email, :citext, null: false)
      add(:hashed_password, :string, null: false)
      add(:confirmed_at, :naive_datetime)

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:users, [:email]))

    create table(:users_tokens, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:user_id, references(:users, type: :string, on_delete: :delete_all), null: false)
      add(:token, :binary, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create(index(:users_tokens, [:user_id]))
    create(unique_index(:users_tokens, [:context, :token]))
  end
end
