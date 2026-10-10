defmodule Magnetissimo.Repo.Migrations.AddCanonicalUrlIndexToTorrents do
  use Ecto.Migration

  # AudioBookBay lists no infohash, only a page per book, so its crawler asks
  # which pages are already indexed before fetching each one. Not unique: two
  # sources may one day share a page, and a hash is what identifies a torrent.
  def change do
    create index(:torrents, [:canonical_url])
  end
end
