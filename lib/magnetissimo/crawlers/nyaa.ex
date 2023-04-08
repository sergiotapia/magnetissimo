defmodule Magnetissimo.Crawlers.Nyaa do
  import SweetXml
  require Logger

  alias Magnetissimo.Torrents
  alias Magnetissimo.Utils

  def search(search_term) do
    source = Torrents.get_source_by_name!("Nyaa.si")

    search_term
    |> get_search_page_html()
    |> Floki.parse_document!()
    |> Floki.find("table.torrent-list tr")
    # Drop the header of the table
    |> Enum.drop(1)
    |> Enum.each(fn row ->
      canonical_url =
        row
        |> Floki.find("a")
        |> Enum.at(1)
        |> Floki.attribute("href")
        |> List.first()

      canonical_url = "https://nyaa.si#{canonical_url}"
      leechers = row |> Floki.find("td") |> Enum.at(6) |> Floki.text() |> String.to_integer()
      seeders = row |> Floki.find("td") |> Enum.at(5) |> Floki.text() |> String.to_integer()

      magnet_url =
        row
        |> Floki.find("a")
        |> Enum.filter(fn a ->
          a |> Floki.attribute("href") |> List.first() |> String.starts_with?("magnet:")
        end)
        |> List.first()
        |> Floki.attribute("href")
        |> List.first()

      name = row |> Floki.find("td") |> Enum.at(1) |> Floki.text()
      size = row |> Floki.find("td") |> Enum.at(3) |> Floki.text() |> Utils.size_to_bytes()

      category =
        row
        |> Floki.find("a")
        |> Enum.at(0)
        |> Floki.attribute("title")
        |> List.first()
        |> Torrents.get_category_by_name_or_alias!()

      # Published at comes in timestamp format, like: "1680594232"
      published_at =
        row
        |> Floki.find("td")
        |> Enum.at(4)
        |> Floki.attribute("data-timestamp")
        |> List.first()
        |> String.to_integer()
        |> DateTime.from_unix!()

      torrent = %{
        canonical_url: canonical_url,
        leechers: leechers,
        magnet_url: magnet_url,
        name: name,
        published_at: published_at,
        seeders: seeders,
        size_in_bytes: size,
        category_id: category.id,
        source_id: source.id
      }

      Torrents.create_torrent_for_source(torrent, source.name)
    end)
  end

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
    |> Enum.each(fn torrent ->
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

      Torrents.create_torrent_for_source(torrent, source.name)
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

  @spec get_search_page_html(binary()) :: binary()
  def get_search_page_html(search_term) do
    Logger.info("[Nyaa] Fetching search results page.")

    search_term =
      search_term
      |> String.replace(" ", "+")

    %{status_code: 200, body: body} =
      "https://nyaa.si/?f=0&c=0_0&q=#{search_term}"
      |> HTTPoison.get!()

    body
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
