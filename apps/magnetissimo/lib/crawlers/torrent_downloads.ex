defmodule Magnetissimo.Crawlers.TorrentDownloads do
  import SweetXml
  require Logger
  use Timex

  alias Magnetissimo.Torrents
  alias Magnetissimo.Helpers

  def perform() do
    %{torrents: torrents} =
      download_rss()
      |> parse_rss()

    Enum.each(torrents, fn torrent_params ->
      create_torrent(torrent_params)
    end)
  end

  def download_rss do
    Logger.debug(
      "[TorrentDownloads.me] Downloading url: https://www.torrentdownloads.me/rss.xml?type=today"
    )

    "https://www.torrentdownloads.me/rss.xml?type=today"
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  def parse_rss(rss_body) do
    %{torrents: torrents} =
      rss_body
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./link/text()",
          published_at: ~x"./pubDate/text()",
          magnet_url: ~x"./info_hash/text()",
          seeders: ~x"./seeders/text()",
          leechers: ~x"./leechers/text()",
          size_in_bytes: ~x"./size/text()"
        ]
      )

    %{torrents: torrents}
  end

  def create_torrent(torrent_params) do
    seeders = List.to_string(torrent_params.seeders)
    leechers = List.to_string(torrent_params.leechers)
    name = List.to_string(torrent_params.name)
    canonical_url = "https://torrentdownloads.me" <> List.to_string(torrent_params.canonical_url)

    infohash = List.to_string(torrent_params.magnet_url)
    magnet_url = Helpers.format_infohash(infohash)

    published_at =
      torrent_params.published_at
      |> List.to_string()
      |> Timex.parse!("%a, %d %B %Y %H:%M:%S %z", :strftime)

    size_in_bytes = List.to_string(torrent_params.size_in_bytes)

    torrent_params =
      torrent_params
      |> Map.put(:seeders, seeders)
      |> Map.put(:leechers, leechers)
      |> Map.put(:name, name)
      |> Map.put(:canonical_url, canonical_url)
      |> Map.put(:magnet_url, magnet_url)
      |> Map.put(:published_at, published_at)
      |> Map.put(:size_in_bytes, size_in_bytes)
      |> IO.inspect()

    # Torrents.create_torrent(torrent_params)
  end
end
