defmodule Magnetissimo.Crawlers.TorrentDownloads do
  import SweetXml
  require Logger

  alias Magnetissimo.Torrents
  alias Magnetissimo.Helpers

  @doc """
  Fetches the rss feed with `type=today` and ingests
  each individual torrent to the database.
  """
  def crawl_latest() do
    Logger.info("[TorrentDownloads] Importing latest torrents.")

    source = Torrents.get_source_by_name!("TorrentDownloads")

    %{torrents: torrents} =
      Req.get!("https://www.torrentdownloads.pro/rss.xml?type=today").body
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./link/text()",
          published_at: ~x"./pubDate/text()",
          magnet_hash: ~x"./info_hash/text()",
          seeders: ~x"./seeders/text()",
          leechers: ~x"./leechers/text()",
          category: ~x"./category/text()",
          size: ~x"./size/text()"
        ]
      )

    torrents
    |> Enum.each(fn torrent ->
      category = torrent.category |> List.to_string() |> Torrents.get_category_by_name_or_alias!()
      magnet_hash = torrent.magnet_hash |> List.to_string()
      magnet_name = torrent.name |> List.to_string() |> String.replace(" ", "+")

      magnet_url =
        "?xt=urn:btih:#{magnet_hash}&dn=#{magnet_name}&tr=udp%3A%2F%2Ftracker.open-internet.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.pirateparty.gr%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.si%3A1337%2Fannounce&tr=udp%3A%2F%2Fdenis.stalker.upeer.me%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.port443.xyz%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2720%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Feddie4.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce"

      %{
        canonical_url:
          "https://www.torrentdownloads.pro#{torrent.canonical_url |> List.to_string()}",
        leechers: torrent.leechers |> List.to_string() |> Integer.parse() |> elem(0),
        magnet_url: magnet_url,
        magnet_hash: magnet_hash,
        name: torrent.name |> List.to_string(),
        published_at: torrent.published_at |> List.to_string() |> parse_published_at(),
        seeders: torrent.seeders |> List.to_string() |> Integer.parse() |> elem(0),
        size_in_bytes: torrent.size |> List.to_string() |> Integer.parse() |> elem(0),
        category_id: category.id,
        source_id: source.id
      }
      |> Torrents.create_torrent()
    end)
  end

  @doc """
  Performs a search on TorrentDownloads and ingests the first page of
  50 results to the database.
  """
  def search(search_term) do
    Logger.info("[TorrentDownloads] Searching for: #{search_term}")
    # source = Torrents.get_source_by_name!("TorrentDownloads")

    search_term = URI.encode(search_term)

    url =
      "https://www.torrentdownloads.pro/search/?page=#{1}&search=#{search_term}&s_cat=&srt=seeds&pp=50&order=desc"

    html =
      Req.get!(url).body

    ingest_html(:search_results, html)
  end

  defp ingest_html(:search_results, search_html) do
    torrent_urls =
      search_html
      |> Floki.parse_document!()
      |> Floki.find(".grey_bar3 p a")
      |> Enum.filter(fn link ->
        Floki.attribute(link, "href") |> List.first() |> String.starts_with?("/torrent/")
      end)
      |> Floki.attribute("href")
      |> Enum.map(fn href -> "https://www.torrentdownloads.pro#{href}" end)

    torrent_urls
    |> Enum.each(fn torrent_url ->
      Logger.info("[TorrentDownloads] Attempting to import url: #{torrent_url}")

      html = Req.get!(torrent_url).body
      ingest_html(:torrent_page, html, torrent_url)
    end)
  end

  defp ingest_html(:torrent_page, html, canonical_url) do
    source = Torrents.get_source_by_name!("TorrentDownloads")

    torrent_page_html =
      html
      |> Floki.parse_document!()

    name = torrent_page_html |> Floki.find("h1.titl_1") |> Floki.text()

    description = torrent_page_html |> Floki.find("p.para1") |> Floki.text()

    leechers =
      torrent_page_html
      |> Floki.find(".grey_bar1, .grey_bara1")
      |> Enum.filter(fn item ->
        item |> Floki.text() |> String.contains?("Leechers")
      end)
      |> List.first()
      |> Floki.text()
      |> String.split(": ")
      |> List.last()
      |> Integer.parse()
      |> elem(0)

    seeders =
      torrent_page_html
      |> Floki.find(".grey_bar1, .grey_bara1")
      |> Enum.filter(fn item ->
        item |> Floki.text() |> String.contains?("Seeds")
      end)
      |> List.first()
      |> Floki.text()
      |> String.split(": ")
      |> List.last()
      |> Integer.parse()
      |> elem(0)

    magnet_url =
      torrent_page_html
      |> Floki.find("a[href^='magnet:?']")
      |> Floki.attribute("href")
      |> List.first()
      |> String.replace("magnet:", "")

    magnet_hash =
      torrent_page_html
      |> Floki.find(".grey_bar1, .grey_bara1")
      |> Enum.filter(fn item ->
        item |> Floki.text() |> String.contains?("Infohash")
      end)
      |> List.first()
      |> Floki.text()
      |> String.split(": ")
      |> List.last()
      |> String.trim()

    size_in_bytes =
      torrent_page_html
      |> Floki.find(".grey_bar1, .grey_bara1")
      |> Enum.filter(fn item ->
        item |> Floki.text() |> String.contains?("Total Size")
      end)
      |> List.first()
      |> Floki.text()
      |> String.split(": ")
      |> List.last()
      |> Helpers.size_to_bytes()

    {:ok, published_at} =
      torrent_page_html
      |> Floki.find(".grey_bar1, .grey_bara1")
      |> Enum.filter(fn item ->
        item |> Floki.text() |> String.contains?("Torrent added")
      end)
      |> List.first()
      |> Floki.text()
      |> String.split(": ")
      |> List.last()
      |> Timex.parse("{YYYY}-{0M}-{0D} {h24}:{m}:{s}")

    category_name = torrent_page_html |> Floki.find("h1.movies") |> Floki.text()
    category = Torrents.get_category_by_name_or_alias!(category_name)

    %{
      name: name,
      description: description,
      canonical_url: canonical_url,
      leechers: leechers,
      seeders: seeders,
      magnet_url: magnet_url,
      magnet_hash: magnet_hash,
      source_id: source.id,
      size_in_bytes: size_in_bytes,
      published_at: published_at,
      category_id: category.id
    }
    |> Torrents.create_torrent()
  end

  @spec parse_published_at(String.t()) :: DateTime.t()
  def parse_published_at(published_at) do
    {:ok, parsed_datetime} = Timex.parse(published_at, "{RFC1123}")
    Timex.to_datetime(parsed_datetime, "Etc/UTC")
  end
end
