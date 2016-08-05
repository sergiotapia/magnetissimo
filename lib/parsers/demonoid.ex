defmodule Magnetissimo.Parsers.Demonoid do
  @behaviour Magnetissimo.Parser

  def root_urls do
    [
      "https://www.demonoid.ooo/files/"
    ]
  end

  def download_url(url) do
    response = HTTPoison.get(url)
    response.body
  end

  def paginated_links(_) do
    1..200
    |> Enum.map(fn i -> "https://www.demonoid.ooo/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=#{i}" end)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("td.tone_1_pad a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/files/details/") end)
    |> Enum.map(fn(url) -> "https://www.demonoid.ooo" <> url end)
  end

  def scrape_torrent_information(html_body) do
    name = html_body
      |> Floki.find("td.ctable_header")
      |> Floki.text
      |> String.replace("Details for ", "")
      |> String.replace("Download this torrentExtra informationCommentsDMCA", "")
      |> String.trim

    description = html_body
      |> Floki.find("span.adbriteinline")
      |> Floki.text

    magnet = html_body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(a) -> String.starts_with?(a, "magnet:") end)
      |> Enum.at(0)

    size = html_body
      |> Floki.find("td")
      |> Enum.filter(fn(a) ->
        size_container = Floki.attribute(a, "width") |> Enum.at(0)
        size_container == "50%"
      end)
      |> Enum.at(0)
      |> Floki.text
      |> String.replace("Size: ", "")
      |> String.trim
      |> String.split

    size_value = Enum.at(size, 0)
    unit = Enum.at(size, 1)
    size = Magnetissimo.SizeConverter.size_to_bytes(size_value, unit) |> Kernel.to_string

    %{
      name: name,
      description: description,
      magnet: magnet,
      filesize: size,
      source: "Demonoid",
      seeders: 0,
      leechers: 0
    }
  end
end
