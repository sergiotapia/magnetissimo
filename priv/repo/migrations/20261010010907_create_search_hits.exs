defmodule Magnetissimo.Repo.Migrations.CreateSearchHits do
  use Ecto.Migration

  # Remembers which torrents a source returned for a search term.
  #
  # A source's own search knows things the text index cannot: YTS answers
  # "spiderman" with "Spider-Man", and Nyaa answers a romanised title with the
  # Japanese one. Without this table those hits would land in the index and
  # still not show up for the very search that found them. The search unions
  # these rows into its matches, keyed by the normalised term.
  def change do
    create table(:search_hits) do
      add :term, :text, null: false
      add :torrent_id, references(:torrents, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create unique_index(:search_hits, [:term, :torrent_id])
    create index(:search_hits, [:torrent_id])
  end
end
