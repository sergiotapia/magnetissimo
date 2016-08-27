defmodule Magnetissimo.Parsers.EZTV do
  @behaviour Magnetissimo.Parser

  def root_urls do
    [
      "https://eztv.ag"
    ]
  end

  def paginated_links(_) do
    for i <- 1..1720, do: "https://eztv.ag/page_#{i}"
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("td.forum_thread_post a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(url) -> String.starts_with?(url, "/ep/") end)
    |> Enum.map(fn(url) -> "https://eztv.ag" <> url end)
  end

  def scrape_torrent_information(html_body) do
    name = html_body
      |> Floki.find("td.section_post_header")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim

    magnet = html_body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size = html_body
      |> Floki.find("table")
      |> Enum.at(8)
      |> Floki.text
      |> String.replace("\n", "")
      |> String.replace("Released", "")
      |> String.replace(":", "")
      |> String.split(" ")

    size_value = Enum.at(size, 6)
    unit = Enum.at(size, 7)
    size = Magnetissimo.SizeConverter.size_to_bytes(size_value, unit) |> Kernel.to_string

    {seeders, _} = html_body
      |> Floki.find("span.stat_red")
      |> Floki.text
      |> Integer.parse

    {leechers, _} = html_body
      |> Floki.find("span.stat_green")
      |> Floki.text
      |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      filesize: size,
      source: "EZTV",
      seeders: seeders,
      leechers: leechers
    }
  end
end
