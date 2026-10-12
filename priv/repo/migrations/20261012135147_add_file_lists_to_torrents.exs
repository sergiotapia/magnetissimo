defmodule Magnetissimo.Repo.Migrations.AddFileListsToTorrents do
  use Ecto.Migration

  # Adds a torrent's file list, and makes the file names searchable.
  #
  # A DHT source fetches each torrent's info dictionary, which lists every
  # file in it. `files` keeps the first thousand as JSON, `[{"path", "size"}]`,
  # for the torrent page; `file_count` is the real total. `file_names` holds
  # the same paths, one per line, and exists only for the two FTS5 indexes:
  # an index over the JSON would index the sizes too, and "2019" would match
  # a file of 2,019,xxx bytes. An FTS5 index over a view that reads the paths
  # out of the JSON failed its integrity-check, so the paths are a real
  # column. Sites give no file list, so all three stay NULL for them.
  #
  # Both indexes gain a third column, `file_names`, and are rebuilt.
  #
  # The update triggers now say WHEN a text column changed. SQLite fires an
  # `AFTER UPDATE OF` trigger whenever a column is in the SET list, changed or
  # not, and the upsert that refreshes a torrent's swarm now also sets the file
  # columns, so without the WHEN every refresh would re-index the text.
  def up do
    alter table(:torrents) do
      add :files, :text
      add :file_count, :integer
      add :file_names, :text
    end

    for index <- ["torrents_search", "torrents_words"], do: drop_index_and_triggers(index)

    create_index(
      "torrents_search",
      "trigram remove_diacritics 2",
      nil,
      ~w(name description file_names)
    )

    create_index(
      "torrents_words",
      "unicode61 remove_diacritics 2",
      "1 2",
      ~w(name description file_names)
    )
  end

  def down do
    for index <- ["torrents_search", "torrents_words"], do: drop_index_and_triggers(index)

    create_index("torrents_search", "trigram remove_diacritics 2", nil, ~w(name description))
    create_index("torrents_words", "unicode61 remove_diacritics 2", "1 2", ~w(name description))

    alter table(:torrents) do
      remove :file_names
      remove :file_count
      remove :files
    end
  end

  # Dropping the table drops its shadow tables; the triggers outlive it, so
  # they go first.
  defp drop_index_and_triggers(index) do
    execute("DROP TRIGGER IF EXISTS #{index}_au")
    execute("DROP TRIGGER IF EXISTS #{index}_ad")
    execute("DROP TRIGGER IF EXISTS #{index}_ai")
    execute("DROP TABLE IF EXISTS #{index}")
  end

  # The index is an external-content one, so CREATE leaves it empty and the
  # existing torrents are read back in with FTS5's `rebuild` command.
  defp create_index(index, tokenizer, prefix, columns) do
    prefix = if prefix, do: ",\n  prefix='#{prefix}'", else: ""

    execute("""
    CREATE VIRTUAL TABLE #{index} USING fts5(
      #{Enum.join(columns, ",\n  ")},
      content='torrents',
      content_rowid='id',
      tokenize="#{tokenizer}"#{prefix}
    )
    """)

    list = Enum.join(columns, ", ")
    new = Enum.map_join(columns, ", ", &"new.#{&1}")
    old = Enum.map_join(columns, ", ", &"old.#{&1}")
    changed = Enum.map_join(columns, " OR ", &"old.#{&1} IS NOT new.#{&1}")

    execute("""
    CREATE TRIGGER #{index}_ai AFTER INSERT ON torrents BEGIN
      INSERT INTO #{index}(rowid, #{list}) VALUES (new.id, #{new});
    END
    """)

    # A delete must go through FTS5's 'delete' command: inserting the old
    # values re-adds the tokens instead of removing them.
    execute("""
    CREATE TRIGGER #{index}_ad AFTER DELETE ON torrents BEGIN
      INSERT INTO #{index}(#{index}, rowid, #{list}) VALUES ('delete', old.id, #{old});
    END
    """)

    execute("""
    CREATE TRIGGER #{index}_au AFTER UPDATE OF #{list} ON torrents
    WHEN #{changed}
    BEGIN
      INSERT INTO #{index}(#{index}, rowid, #{list}) VALUES ('delete', old.id, #{old});
      INSERT INTO #{index}(rowid, #{list}) VALUES (new.id, #{new});
    END
    """)

    execute("INSERT INTO #{index}(#{index}) VALUES('rebuild')")
  end
end
