defmodule Magnetissimo.Repo.Migrations.RemoveLastCrawledAtFromSources do
  use Ecto.Migration

  # Sources are no longer crawled on a timer, only asked when someone
  # searches, so there is no last crawl to record.
  def change do
    alter table(:sources) do
      remove :last_crawled_at, :utc_datetime_usec
    end
  end
end
