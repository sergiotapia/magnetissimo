defmodule Magnetissimo.Repo.Migrations.SizeToBigIntAndHash do
  use Ecto.Migration

  def change do
    alter table "torrents" do
      modify :size, :bigint, [null: false, from: :integer]
      add :magnet_hash, :string, size: 40
    end
  end
end
