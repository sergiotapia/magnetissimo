defmodule Magnetissimo.Repo.Migrations.AddOutboundUrlToTorrents do
  use Ecto.Migration

  def change do
    alter table(:torrents) do
      add :outbound_url, :string
    end
  end
end
