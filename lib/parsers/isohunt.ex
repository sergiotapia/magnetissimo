defmodule Magnetissimo.Parsers.Isohunt do
  @behaviour Magnetissimo.Parser

  def root_urls do
    [
      "https://isohunt.to/torrents/?iht=1&age=0",
      "https://isohunt.to/torrents/?iht=2&age=0",
      "https://isohunt.to/torrents/?iht=3&age=0",
      "https://isohunt.to/torrents/?iht=4&age=0",
      "https://isohunt.to/torrents/?iht=5&age=0",
      "https://isohunt.to/torrents/?iht=6&age=0",
      "https://isohunt.to/torrents/?iht=7&age=0",
      "https://isohunt.to/torrents/?iht=8&age=0",
      "https://isohunt.to/torrents/?iht=9&age=0"
    ]
  end

  def paginated_links(html_body) do
    last_page_url = html_body
      |> Floki.find(".pagination .last a")
      |> Floki.attribute("href")
      |> Enum.at(0)
    last_page_url = "https://isohunt.to" <> last_page_url
    uri = URI.parse(last_page_url)
    query_params = URI.query_decoder(uri.query) |> Enum.to_list() |> Enum.into(%{})
    {page, _} = Integer.parse(query_params["Torrent_page"])
    total_pages = div(page, 40)

    0..total_pages
    |> Enum.map(fn i -> i * 40 end)
    |> Enum.map(fn i ->
      String.replace(last_page_url, "Torrent_page=#{page}", "Torrent_page=#{i}")
    end)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("td.title-row a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "torrent_details") end)
    |> Enum.map(fn(url) -> "https://isohunt.to" <> url end)
  end

  def scrape_torrent_information(html_body) do
    name = html_body
      |> Floki.find("h1.torrent-header")
      |> Floki.text
      |> String.trim

    description = html_body
      |> Floki.find("#torrent_details pre")
      |> Floki.text

    magnet = html_body
      |> Floki.find("a.btn-magnet")
      |> Floki.attribute("href")
      |> Enum.at(0)

    attributes = html_body
      |> Floki.find(".text-lg.mb2")
      |> Floki.text
      |> String.split

    size_value = Enum.at(attributes, 0) |> String.replace("Size", "") |> String.trim
    unit = Enum.at(attributes, 1)
    size = Magnetissimo.SizeConverter.size_to_bytes(size_value, unit) |> Kernel.to_string

    {seeders, _} = Enum.at(attributes, 2) |> String.replace("seeders", "") |> String.trim |> Integer.parse

    %{
      name: name,
      description: description,
      magnet: magnet,
      source: "Isohunt",
      filesize: size,
      seeders: seeders
    }
  end
end
