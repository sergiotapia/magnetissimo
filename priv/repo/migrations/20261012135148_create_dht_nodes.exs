defmodule Magnetissimo.Repo.Migrations.CreateDhtNodes do
  use Ecto.Migration

  # DHT nodes that answered the crawler, kept across restarts. A crawler that
  # starts from what it knew asks the public bootstrap routers nothing, and is
  # back at full speed in seconds rather than after a fresh walk.
  def change do
    create table(:dht_nodes) do
      add :ip, :string, null: false
      add :port, :integer, null: false
      add :node_id, :binary, null: false
      add :answered_at, :utc_datetime, null: false
    end

    create unique_index(:dht_nodes, [:ip, :port])
  end
end
