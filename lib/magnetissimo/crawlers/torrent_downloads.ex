defmodule Magnetissimo.Crawlers.TorrentDownloads do
  import SweetXml
  require Logger

  alias Magnetissimo.Torrents
  alias Magnetissimo.Utils

  def search(search_term) do
    source = Torrents.get_source_by_name!("TorrentDownloads")

    1..20
    |> Enum.each(fn page ->
      search_term
      |> get_search_page_html(page)
      |> parse_search_page(source)
    end)
  end

  def parse_search_page(search_page_html, source) do
    search_page_html
    |> Floki.parse_document!()
    |> Floki.find(".grey_bar3 p a")
    |> Enum.filter(fn link ->
      Floki.attribute(link, "href") |> List.first() |> String.starts_with?("/torrent/")
    end)
    |> Floki.attribute("href")
    |> Enum.map(fn href -> "https://www.torrentdownloads.pro#{href}" end)
    |> Enum.each(fn torrent_url ->
      torrent_url
      |> get_torrent_page_html()
      |> parse_torrent_page(torrent_url, source)
    end)
  end

  def parse_torrent_page(torrent_page_html, canonical_url, source) do
    torrent_page_html =
      torrent_page_html
      |> Floki.parse_document!()

    name = torrent_page_html |> Floki.find("h1.titl_1") |> Floki.text()

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
      |> Utils.size_to_bytes()

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
    |> Torrents.create_torrent_for_source(source.name)
  end

  def crawl_latest() do
    Logger.info("[TorrentDownloads] Crawling latest torrents.")

    %{torrents: torrents} =
      get_rss()
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

    source = Torrents.get_source_by_name!("TorrentDownloads")

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
      |> Torrents.create_torrent_for_source(source.name)
    end)
  end

  @spec parse_published_at(String.t()) :: DateTime.t()
  def parse_published_at(published_at) do
    {:ok, parsed_datetime} = Timex.parse(published_at, "{RFC1123}")
    Timex.to_datetime(parsed_datetime, "Etc/UTC")
  end

  @spec get_search_page_html(binary(), integer()) :: binary()
  def get_search_page_html(search_term, page \\ 1) do
    # Put some respek on they servers.
    sleep_ms = 350 + :rand.uniform(200)
    Process.sleep(sleep_ms)
    Logger.info("[TorrentDownloads] Fetching search results page.")

    search_term =
      search_term
      |> String.replace(" ", "+")

    %{status_code: 200, body: body} =
      "https://www.torrentdownloads.pro/search/?page=#{page}&search=#{search_term}&s_cat=&srt=seeds&pp=50&order=desc"
      |> HTTPoison.get!()

    body
  end

  @spec get_torrent_page_html(binary()) :: binary()
  def get_torrent_page_html(torrent_page_url) do
    # Put some respek on they servers.
    sleep_ms = 350 + :rand.uniform(200)
    Process.sleep(sleep_ms)
    Logger.info("[TorrentDownloads] Fetching torrent page: #{torrent_page_url}")

    %{status_code: 200, body: body} =
      torrent_page_url
      |> HTTPoison.get!()

    body
  end

  @spec get_rss :: binary()
  def get_rss do
    Logger.info("[TorrentDownloads] Fetching RSS feed.")

    %{status_code: 200, body: body} =
      "https://www.torrentdownloads.pro/rss.xml?type=today"
      |> HTTPoison.get!()

    body
  end
end
