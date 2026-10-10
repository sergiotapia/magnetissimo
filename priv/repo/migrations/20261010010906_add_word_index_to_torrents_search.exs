defmodule Magnetissimo.Repo.Migrations.AddWordIndexToTorrentsSearch do
  use Ecto.Migration

  # Adds `torrents_words`, a word-level FTS5 index next to the trigram one.
  #
  # The trigram index cannot answer a token shorter than three characters. On
  # its own such a token matches nothing, and next to longer tokens SQLite drops
  # it from the query without saying so: "toy story 4" returned every Toy Story,
  # "last of us" ignored "of" and "us", and "4k" or "Up" found nothing at all.
  # `unicode61` splits on punctuation, so "Toy.Story.4.2019" indexes the whole
  # word "4", and the search uses this index for short tokens.
  #
  # `prefix='1 2'` keeps a short last token cheap while it is still being typed.
  #
  # The update triggers on both indexes now fire only on `name` and
  # `description`. Crawls refresh seeders and leechers on torrents already
  # indexed, and re-indexing the text on every swarm change would be pure cost.
  def up do
    execute("""
    CREATE VIRTUAL TABLE torrents_words USING fts5(
      name,
      description,
      content='torrents',
      content_rowid='id',
      tokenize="unicode61 remove_diacritics 2",
      prefix='1 2'
    )
    """)

    execute("INSERT INTO torrents_words(torrents_words) VALUES('rebuild')")

    execute("DROP TRIGGER IF EXISTS torrents_search_au")
    execute("DROP TRIGGER IF EXISTS torrents_search_ad")
    execute("DROP TRIGGER IF EXISTS torrents_search_ai")

    for index <- ["torrents_search", "torrents_words"] do
      create_triggers(index, "AFTER UPDATE OF name, description ON torrents")
    end
  end

  def down do
    for index <- ["torrents_search", "torrents_words"] do
      drop_triggers(index)
    end

    execute("DROP TABLE IF EXISTS torrents_words")
    create_triggers("torrents_search", "AFTER UPDATE ON torrents")
  end

  defp create_triggers(index, update_event) do
    execute("""
    CREATE TRIGGER #{index}_ai AFTER INSERT ON torrents BEGIN
      INSERT INTO #{index}(rowid, name, description)
      VALUES (new.id, new.name, new.description);
    END
    """)

    # A delete must go through FTS5's 'delete' command: inserting the old
    # values re-adds the tokens instead of removing them.
    execute("""
    CREATE TRIGGER #{index}_ad AFTER DELETE ON torrents BEGIN
      INSERT INTO #{index}(#{index}, rowid, name, description)
      VALUES ('delete', old.id, old.name, old.description);
    END
    """)

    execute("""
    CREATE TRIGGER #{index}_au #{update_event} BEGIN
      INSERT INTO #{index}(#{index}, rowid, name, description)
      VALUES ('delete', old.id, old.name, old.description);
      INSERT INTO #{index}(rowid, name, description)
      VALUES (new.id, new.name, new.description);
    END
    """)
  end

  defp drop_triggers(index) do
    execute("DROP TRIGGER IF EXISTS #{index}_au")
    execute("DROP TRIGGER IF EXISTS #{index}_ad")
    execute("DROP TRIGGER IF EXISTS #{index}_ai")
  end
end
