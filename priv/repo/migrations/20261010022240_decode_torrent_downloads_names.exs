defmodule Magnetissimo.Repo.Migrations.DecodeTorrentDownloadsNames do
  use Ecto.Migration

  # TorrentDownloads escapes & as &amp; in its feed titles, and until the
  # crawler decoded them the names were stored that way. A crawl never fixes
  # a name it has already indexed, since only the swarm is refreshed, so the
  # stored ones are decoded here. &amp; is the only entity that feed was seen
  # to send. The magnet's display name carries the same escape, URL-encoded.
  #
  # The FTS update triggers fire on `name`, so both indexes follow.
  def up do
    execute("""
    UPDATE torrents
    SET name = replace(name, '&amp;', '&'),
        magnet_url = replace(magnet_url, '%26amp%3B', '%26')
    WHERE name LIKE '%&amp;%'
      AND source_id = (SELECT id FROM sources WHERE name = 'TorrentDownloads')
    """)
  end

  # The escaped names were wrong, so there is nothing to put back.
  def down, do: :ok
end
