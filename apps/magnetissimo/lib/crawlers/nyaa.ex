defmodule Magnetissimo.Crawlers.Nyaa do
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
    Logger.debug("[Nyaa] Downloading url: https://nyaa.si/?page=rss")

    "https://nyaa.si/?page=rss"
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
          canonical_url: ~x"./guid/text()",
          published_at: ~x"./pubDate/text()",
          seeders: ~x"./nyaa:seeders/text()",
          leechers: ~x"./nyaa:leechers/text()",
          magnet_url: ~x"./nyaa:infoHash/text()",
          size_in_bytes: ~x"./nyaa:size/text()"
        ]
      )

    %{torrents: torrents}
  end

  def create_torrent(torrent_params) do
    seeders = List.to_string(torrent_params.seeders)
    leechers = List.to_string(torrent_params.leechers)
    name = List.to_string(torrent_params.name)
    canonical_url = List.to_string(torrent_params.canonical_url)

    infohash = List.to_string(torrent_params.magnet_url)
    magnet_url = Helpers.format_infohash(infohash)

    # 'Thu, 27 May 2021 19:50:17 -0000'
    published_at =
      torrent_params.published_at
      |> List.to_string()
      |> Timex.parse!("%a, %d %B %Y %H:%M:%S %z", :strftime)

    size_in_bytes =
      torrent_params.size_in_bytes
      |> List.to_string()
      |> Helpers.convert_filesize!("b")
      |> String.split(".")
      |> List.first()

    torrent_params =
      torrent_params
      |> Map.put(:seeders, seeders)
      |> Map.put(:leechers, leechers)
      |> Map.put(:name, name)
      |> Map.put(:canonical_url, canonical_url)
      |> Map.put(:magnet_url, magnet_url)
      |> Map.put(:published_at, published_at)
      |> Map.put(:size_in_bytes, size_in_bytes)

    Torrents.create_torrent(torrent_params)
  end
end
