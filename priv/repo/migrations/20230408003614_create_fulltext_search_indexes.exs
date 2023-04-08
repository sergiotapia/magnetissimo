defmodule Magnetissimo.Repo.Migrations.CreateFulltextSearchIndexes do
  use Ecto.Migration

  def up do
    execute """
      ALTER TABLE torrents
      ADD COLUMN search_vector tsvector
      GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B')
      ) STORED;
    """

    execute """
      CREATE INDEX torrents_search_vector_idx ON torrents USING gin(search_vector);
    """
  end

  def down do
    execute "ALTER TABLE torrents DROP COLUMN search_vector;"

    execute "DROP INDEX IF EXISTS torrents_search_vector_idx;"
  end
end
