defmodule Magnetissimo.Repo.Migrations.AddFilesizeToTorrents do
  use Ecto.Migration

  def change do
    alter table(:torrents) do
      add :filesize, :text
    end  
  end
end
