defmodule Magnetissimo.Repo.Migrations.UseTrigramForTorrentsSearch do
  use Ecto.Migration

  # Rebuilds the FTS5 index with the trigram tokenizer.
  #
  # `unicode61` treats every CJK character as one long token, so a search for a
  # substring of a Japanese title — the normal case on Nyaa and Sukebei — never
  # matched, even when the torrent was already indexed. The trigram tokenizer
  # indexes every three-character sequence, which makes MATCH a substring
  # search for any query of three characters or more, in any script.
  #
  # `remove_diacritics 2` keeps accented titles searchable without the accent,
  # as `unicode61` did. Queries shorter than three characters cannot use a
  # trigram index and match nothing on their own; the search box is typed into,
  # so a shorter query is only ever an intermediate state.
  #
  # The index is an external-content one, so CREATE leaves it empty and the
  # existing torrents are read back in with FTS5's `rebuild` command.
  def up do
    replace("trigram remove_diacritics 2")
  end

  def down do
    replace("unicode61 remove_diacritics 2", prefix: "2 3 4")
  end

  defp replace(tokenizer, opts \\ []) do
    # Dropping the table drops its shadow tables; the triggers outlive it, so
    # they go first.
    execute("DROP TRIGGER IF EXISTS torrents_search_au")
    execute("DROP TRIGGER IF EXISTS torrents_search_ad")
    execute("DROP TRIGGER IF EXISTS torrents_search_ai")
    execute("DROP TABLE IF EXISTS torrents_search")

    prefix = if prefix = opts[:prefix], do: ",\n      prefix='#{prefix}'", else: ""

    execute("""
    CREATE VIRTUAL TABLE torrents_search USING fts5(
      name,
      description,
      content='torrents',
      content_rowid='id',
      tokenize="#{tokenizer}"#{prefix}
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

    execute("INSERT INTO torrents_search(torrents_search) VALUES('rebuild')")
  end
end
