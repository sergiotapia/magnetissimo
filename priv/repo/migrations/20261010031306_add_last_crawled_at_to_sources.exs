defmodule Magnetissimo.Repo.Migrations.AddLastCrawledAtToSources do
  use Ecto.Migration

  # When the scheduler last crawled each source and got an answer back. The
  # newest torrent's `published_at` is not a stand-in: it is the source's own
  # upload time, and a quiet hour on every site looks like a stalled crawler.
  def change do
    alter table(:sources) do
      add :last_crawled_at, :utc_datetime_usec
    end
  end
end
