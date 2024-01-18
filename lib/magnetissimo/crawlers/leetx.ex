defmodule Magnetissimo.Crawlers.Leetx do
  require Logger

  alias Magnetissimo.Helpers
  alias Magnetissimo.Torrents

  @doc """
  Fetches the first page of each category and
  ingests each individual torrent to the database.
  """
  def crawl_latest() do
    Logger.info("[1337x] Importing latest torrents.")

    category_pages =
      [
        "Anime",
        "Apps",
        "Documentaries",
        "Games",
        "Movies",
        "Music",
        "Other",
        "TV",
        "XXX"
      ]
      |> Enum.map(&"https://1337x.to/cat/#{&1}/1/")

    category_pages
    |> Enum.map(fn category_page_url ->
      Req.get!(category_page_url).body
    end)
    |> Enum.each(fn html ->
      ingest_html(:search_results, html)
    end)
  end

  @doc """
  Performs a search on Leetx and ingests the first page of
  results to the database.
  """
  def search(search_term) do
    Logger.info("[1337x] Searching for: #{search_term}")

    search_term = URI.encode(search_term)
    url = "https://1337x.to/search/#{search_term}/1/"
    html = Req.get!(url).body
    ingest_html(:search_results, html)
  end

  defp ingest_html(:search_results, html) do
    torrent_urls =
      html
      |> Floki.parse_document!()
      |> Floki.find("table a")
      |> Enum.filter(fn a ->
        a |> Floki.attribute("href") |> List.first() |> String.starts_with?("/torrent/")
      end)
      |> Enum.map(fn a ->
        "https://www.1337x.to" <> (a |> Floki.attribute("href") |> List.first())
      end)

    torrent_urls
    |> Enum.each(fn torrent_url ->
      Logger.info("[1337x] Attempting to import url: #{torrent_url}")

      html = Req.get!(torrent_url).body
      ingest_html(:torrent_page, html, torrent_url)
    end)
  end

  defp ingest_html(:torrent_page, html, canonical_url) do
    source = Torrents.get_source_by_name!("1337x")

    torrent_page_html =
      html
      |> Floki.parse_document!()

    name =
      torrent_page_html
      |> Floki.find("title")
      |> Floki.text()
      |> String.replace(" Torrent | 1337x", "")
      |> String.replace_leading("Download ", "")
      |> String.trim()

    leechers =
      torrent_page_html
      |> Floki.find("span.leeches")
      |> Floki.text()
      |> String.to_integer()

    seeders =
      torrent_page_html
      |> Floki.find("span.seeds")
      |> Floki.text()
      |> String.to_integer()

    magnet_url =
      torrent_page_html
      |> Floki.find(".box-info a")
      |> Enum.filter(fn a ->
        a |> Floki.attribute("href") |> List.first() |> String.starts_with?("magnet:")
      end)
      |> List.first()
      |> Floki.attribute("href")
      |> List.first()
      |> String.replace("magnet:", "")

    magnet_hash =
      torrent_page_html
      |> Floki.find(".infohash-box")
      |> Floki.text()
      |> String.replace("Infohash :", "")

    description =
      torrent_page_html
      |> Floki.find("div#description")
      |> Floki.raw_html()

    # The datetime string is in relative string format.
    # I couldn't find a good way to convert "2 hours ago" to a datetime.
    # Timex doesn't support this, and the only other library I found
    # doesn't support past relative time strings.
    # Figure this out later.
    # published_at =
    #   torrent_page_html
    #   |> Floki.find(".torrent-detail-page ul.list li")
    #   |> Enum.filter(fn li ->
    #     li |> Floki.text() |> String.starts_with?("Date uploaded")
    #   end)
    #   |> List.first()
    #   |> Floki.text()
    #   |> String.replace("Date uploaded", "")

    published_at = DateTime.utc_now()

    size_in_bytes =
      torrent_page_html
      |> Floki.find(".torrent-detail-page ul.list li")
      |> Enum.filter(fn li ->
        li |> Floki.text() |> String.starts_with?("Total size")
      end)
      |> List.first()
      |> Floki.text()
      |> String.replace("Total size", "")
      |> Helpers.size_to_bytes()

    category =
      torrent_page_html
      |> Floki.find(".torrent-detail-page ul.list li")
      |> Enum.filter(fn li ->
        li |> Floki.text() |> String.starts_with?("Category")
      end)
      |> List.first()
      |> Floki.text()
      |> String.replace("Category", "")
      |> Torrents.get_category_by_name_or_alias!()

    %{
      canonical_url: canonical_url,
      leechers: leechers,
      magnet_url: magnet_url,
      magnet_hash: magnet_hash,
      name: name,
      description: description,
      published_at: published_at,
      seeders: seeders,
      size_in_bytes: size_in_bytes,
      category_id: category.id,
      source_id: source.id
    }
    |> Torrents.create_torrent()
  end
end
