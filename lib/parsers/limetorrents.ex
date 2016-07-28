defmodule Magnetissimo.Parsers.Limetorrents do
  @behaviour Magnetissimo.Parser

  def root_urls do
    [
      "https://www.limetorrents.cc/browse-torrents/Movies/",
      "https://www.limetorrents.cc/browse-torrents/TV-shows/",
      "https://www.limetorrents.cc/browse-torrents/Music/",
      "https://www.limetorrents.cc/browse-torrents/Games/",
      "https://www.limetorrents.cc/browse-torrents/Applications/",
      "https://www.limetorrents.cc/browse-torrents/Anime/",
      "https://www.limetorrents.cc/browse-torrents/Other/"
    ]
  end

  def download_url(url) do
    response = HTTPoison.get(url)
    response.body
  end

  def paginated_links(html_body) do
    urls = html_body
      |> Floki.find(".search_stat a")
      |> Floki.attribute("href")
    last_page_url = Enum.at(urls, Enum.count(urls) - 2)
    last_page_url = "https://www.limetorrents.cc" <> last_page_url

    1..1000
    |> Enum.map(fn i -> String.replace(last_page_url, "1000", Integer.to_string(i)) end)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find(".tt-name a")
    |> Enum.drop_every(2)
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> "https://www.limetorrents.cc" <> url end)
  end

  def scrape_torrent_information(html_body) do
    name = html_body
      |> Floki.find("h1")
      |> Floki.text
      |> String.trim

    magnet = html_body
      |> Floki.find(".dltorrent a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size_html = html_body
      |> Floki.find(".torrentinfo table tr td")
      |> Enum.at(5)
      |> Floki.text
    size_value = String.split(size_html) |> Enum.at(0)
    unit = String.split(size_html) |> Enum.at(1)
    size = Magnetissimo.SizeConverter.size_to_bytes(size_value, unit)

    seeders = html_body
      |> Floki.find("#content .greenish")
      |> Floki.text
      |> String.split(":")
      |> Enum.at(1)
      |> String.trim
      |> String.replace("Updating", "")
      |> String.slice(0..-2)

    leechers = html_body
      |> Floki.find("#content .reddish")
      |> Floki.text
      |> String.split(":")
      |> Enum.at(1)
      |> String.trim
      |> String.replace("Updating", "")
      |> String.slice(0..-2)

    %{
      name: name,
      magnet: magnet,
      size: size,
      seeders: seeders,
      leechers: leechers
    }
  end
end
