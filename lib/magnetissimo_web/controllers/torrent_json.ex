defmodule MagnetissimoWeb.TorrentJSON do
  @moduledoc """
  Shapes torrents for the JSON API, keeping the 2.0.0 field names.
  `category` is the Torznab name and `category_id` its number.
  """

  alias Magnetissimo.Taxonomy

  def index(%{torrents: torrents}) do
    %{data: Enum.map(torrents, &data/1)}
  end

  defp data(torrent) do
    %{
      id: torrent.id,
      name: torrent.name,
      description: torrent.description,
      canonical_url: torrent.canonical_url,
      published_at: torrent.published_at,
      leechers: torrent.leechers,
      seeders: torrent.seeders,
      size_in_bytes: torrent.size_in_bytes,
      magnet_hash: torrent.magnet_hash,
      magnet_url: torrent.magnet_url,
      category: Taxonomy.fetch!(torrent.category_id).name,
      # The Torznab number, which Sonarr and Radarr filter on.
      category_id: torrent.category_id,
      source: torrent.source.name
    }
  end
end
