defmodule Magnetissimo.Parsers.Leetx do
  @behaviour Magnetissimo.Parser

  def root_urls do
    [
      "https://1337x.to/trending",
      "https://1337x.to/top-100",
      "https://1337x.to/cat/Anime/0/",
      "https://1337x.to/cat/Apps/0/",
      "https://1337x.to/cat/Documentaries/0/",
      "https://1337x.to/cat/Games/0/",
      "https://1337x.to/cat/Movies/0/",
      "https://1337x.to/cat/Music/0/",
      "https://1337x.to/cat/Other/0/",
      "https://1337x.to/cat/TV/0/",
      "https://1337x.to/cat/XXX/0/"
    ]
  end

  def paginated_links(html_body) do
    last_page_url = html_body
      |> Floki.find(".pagging-box ul li.last a")
      |> Floki.attribute("href")
      |> Enum.at(0)
    last_page_url = "https://1337x.to" <> last_page_url

    0..50
    |> Enum.map(fn i ->
      String.replace(last_page_url, "/50/", "/#{i}/")
    end)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/torrent/") end)
    |> Enum.map(fn(url) -> "https://1337x.to" <> url end)
  end

  def scrape_torrent_information(html_body) do
    name = html_body
      |> Floki.find("title")
      |> Floki.text
      |> String.replace("Download Torrent ", "")
      |> String.replace("| 1337x", "")
      |> String.trim

    description = html_body
      |> Floki.find("span.bbcode-text")
      |> Floki.text

    magnet = html_body
      |> Floki.find("a#magnetdl")
      |> Floki.attribute("href")
      |> Enum.at(0)

    size = html_body
      |> Floki.find(".category-detail ul.list")
      |> Enum.at(0)
      |> Floki.find("li")
      |> Enum.at(3)
      |> Floki.find("span")
      |> Floki.text
      |> String.split
    size_value = Enum.at(size, 0)
    unit = Enum.at(size, 1)
    size = Magnetissimo.SizeConverter.size_to_bytes(size_value, unit) |> Kernel.to_string

    {leechers, _} = html_body
      |> Floki.find(".red")
      |> Enum.at(0)
      |> Floki.text
      |> Integer.parse

    {seeders, _} = html_body
      |> Floki.find(".green")
      |> Enum.at(0)
      |> Floki.text  
      |> Integer.parse

    %{
      name: name,
      description: description,
      magnet: magnet,
      filesize: size,
      source: "1337x",
      seeders: seeders,
      leechers: leechers
    }
  end
end
