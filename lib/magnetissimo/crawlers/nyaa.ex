defmodule Magnetissimo.Crawlers.Nyaa do
  import SweetXml
  require Logger

  alias Magnetissimo.Torrents
  alias Magnetissimo.Utils

  def crawl_latest() do
    Logger.info("[Nyaa] Crawling latest torrents.")

    %{torrents: torrents} =
      get_rss()
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./guid/text()",
          published_at: ~x"./pubDate/text()",
          seeders: ~x"./nyaa:seeders/text()",
          leechers: ~x"./nyaa:leechers/text()",
          magnet_url: ~x"./nyaa:infoHash/text()",
          category: ~x"./nyaa:category/text()",
          size: ~x"./nyaa:size/text()"
        ]
      )

    source = Torrents.get_source_by_name!("Nyaa.si")

    torrents
    |> Enum.map(fn torrent ->
      category = torrent.category |> List.to_string() |> Torrents.get_category_by_name_or_alias!()

      torrent = %{
        canonical_url: torrent.canonical_url |> List.to_string(),
        leechers: torrent.leechers |> List.to_string() |> Integer.parse() |> elem(0),
        magnet_url: torrent.magnet_url |> List.to_string(),
        name: torrent.name |> List.to_string(),
        published_at: torrent.published_at |> List.to_string() |> parse_published_at(),
        seeders: torrent.seeders |> List.to_string() |> Integer.parse() |> elem(0),
        size_in_bytes: torrent.size |> List.to_string() |> Utils.size_to_bytes(),
        description: get_torrent_description(torrent.canonical_url),
        category_id: category.id,
        source_id: source.id
      }

      Logger.info("[Nyaa] Creating torrent: #{torrent.name} (#{torrent.canonical_url})")
      Torrents.create_torrent(torrent)
    end)
  end

  @spec parse_published_at(String.t()) :: DateTime.t()
  def parse_published_at(published_at) do
    {:ok, parsed_datetime} = Timex.parse(published_at, "{RFC1123}")
    Timex.to_datetime(parsed_datetime, "Etc/UTC")
  end

  @spec get_torrent_description(String.t()) :: String.t()
  def get_torrent_description(url) do
    # Put some respek on they servers.
    Process.sleep(350)
    %{status_code: 200, body: body} = HTTPoison.get!(url)

    body
    |> Floki.parse_document!()
    |> Floki.find("#torrent-description")
    |> Floki.text()
  end

  @spec get_rss :: binary()
  def get_rss do
    Logger.info("[Nyaa] Fetching RSS feed.")

    %{status_code: 200, body: body} =
      "https://nyaa.si/?page=rss"
      |> HTTPoison.get!()

    body
  end
end
