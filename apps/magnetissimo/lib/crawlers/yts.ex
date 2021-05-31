defmodule Magnetissimo.Crawlers.Yts do
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
    Logger.debug("[YTS] Downloading url: https://yts.mx/rss")

    "https://yts.mx/rss"
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
          description: ~x"./description/text()",
          canonical_url: ~x"./link/text()",
          published_at: ~x"./pubDate/text()",
          magnet_url: ~x"./enclosure/@url"
        ]
      )

    %{torrents: torrents}
  end

  def create_torrent(torrent_params) do
    name = List.to_string(torrent_params.name)
    canonical_url = List.to_string(torrent_params.canonical_url)

    infohash = List.to_string(torrent_params.magnet_url)
    magnet_url = Helpers.format_infohash(infohash)

    published_at =
      torrent_params.published_at
      |> List.to_string()
      |> Timex.parse!("%a, %d %B %Y %H:%M:%S %z", :strftime)

    size_in_bytes =
      torrent_params.description
      |> List.to_string()
      |> String.split("<br />")
      |> Enum.at(3)
      |> String.split(": ")
      |> List.last()
      |> Helpers.convert_filesize!("b")
      |> String.split(".")
      |> List.first()

    torrent_params =
      torrent_params
      |> Map.delete(:description)
      |> Map.put(:seeders, "0")
      |> Map.put(:leechers, "0")
      |> Map.put(:size_in_bytes, size_in_bytes)
      |> Map.put(:name, name)
      |> Map.put(:canonical_url, canonical_url)
      |> Map.put(:magnet_url, magnet_url)
      |> Map.put(:published_at, published_at)
      |> Map.put(:source, "YTS")
      |> IO.inspect()

    Torrents.create_torrent(torrent_params)
  end
end
