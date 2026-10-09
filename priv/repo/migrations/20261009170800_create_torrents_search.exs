defmodule Magnetissimo.Repo.Migrations.CreateTorrentsSearch do
  use Ecto.Migration

  # SQLite FTS5 full-text index over torrents.name and torrents.description.
  #
  # `content='torrents'` makes this an external-content index: FTS5 stores only
  # the inverted index and reads the text back from `torrents`, so the names and
  # descriptions are not duplicated on disk. Because `torrents.id` is an
  # INTEGER PRIMARY KEY it *is* the rowid, so `content_rowid='id'` aligns
  # exactly and the FTS rowid can be joined straight onto `torrents.id`.
  #
  # `prefix='2 3 4'` indexes 2-, 3- and 4-character prefixes so that
  # search-as-you-type queries like `"mat"*` are index lookups rather than
  # table scans. `unicode61 remove_diacritics 2` keeps accented characters
  # searchable without a stemmer, which would mangle release tags such as
  # "x265" and "1080p".
  #
  # The triggers keep the index in sync. The delete path must use FTS5's
  # special 'delete' command: a plain INSERT of the old values re-adds the
  # tokens instead of removing them, silently corrupting the index.
  def up do
    execute("""
    CREATE VIRTUAL TABLE torrents_search USING fts5(
      name,
      description,
      content='torrents',
      content_rowid='id',
      tokenize="unicode61 remove_diacritics 2",
      prefix='2 3 4'
    )
    """)

    execute("""
    CREATE TRIGGER torrents_search_ai AFTER INSERT ON torrents BEGIN
      INSERT INTO torrents_search(rowid, name, description)
      VALUES (new.id, new.name, new.description);
    END
    """)

    execute("""
    CREATE TRIGGER torrents_search_ad AFTER DELETE ON torrents BEGIN
      INSERT INTO torrents_search(torrents_search, rowid, name, description)
      VALUES ('delete', old.id, old.name, old.description);
    END
    """)

    execute("""
    CREATE TRIGGER torrents_search_au AFTER UPDATE ON torrents BEGIN
      INSERT INTO torrents_search(torrents_search, rowid, name, description)
      VALUES ('delete', old.id, old.name, old.description);
      INSERT INTO torrents_search(rowid, name, description)
      VALUES (new.id, new.name, new.description);
    END
    """)
  end

  def down do
    # Dropping the table drops its shadow tables; the triggers outlive it, so
    # they go first.
    execute("DROP TRIGGER IF EXISTS torrents_search_au")
    execute("DROP TRIGGER IF EXISTS torrents_search_ad")
    execute("DROP TRIGGER IF EXISTS torrents_search_ai")
    execute("DROP TABLE IF EXISTS torrents_search")
  end
end
