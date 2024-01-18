defmodule MagnetissimoWeb.TorrentJSON do
  alias Magnetissimo.Torrents.Torrent

  @doc """
  Renders a list of Torrents.
  """
  def index(%{torrents: torrents}) do
    %{data: for(torrent <- torrents, do: data(torrent))}
  end

  @doc """
  Renders a single Torrent.
  """
  def show(%{torrent: torrent}) do
    %{data: data(torrent)}
  end

  defp data(%Torrent{} = torrent) do
    %{
      id: torrent.id,
      canonical_url: torrent.canonical_url,
      leechers: torrent.leechers,
      magnet_url: "magnet:" <> torrent.magnet_url,
      magnet_hash: torrent.magnet_hash,
      name: torrent.name,
      description: torrent.description,
      published_at: torrent.published_at,
      seeders: torrent.seeders,
      size_in_bytes: torrent.size_in_bytes,
      category: torrent.category.name,
      source: torrent.source.name
    }
  end
end
