defmodule Magnetissimo.Parsers.ThePirateBay do
  @behaviour Magnetissimo.Parser

  def root_urls do
    [
      "https://thepiratebay.org/browse/100"
    ]
  end

  def paginated_links(_) do
    for i <- 1..6, j <- 1..50, do: "https://thepiratebay.org/browse/#{i}00/#{j}/3"
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find(".detName a")
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> "https://thepiratebay.org" <> url end)
  end

  def scrape_torrent_information(html_body) do
    name = html_body
      |> Floki.find("#title")
      |> Floki.text
      |> String.trim

    magnet = html_body
      |> Floki.find(".download a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size = html_body
      |> Floki.find("#detailsframe #details .col1 dd")
      |> Enum.at(2)
      |> Floki.text
      |> String.split(<<194, 160>>)
      |> Enum.at(2)
      |> String.replace("(", "")

    {seeders, _} = html_body
      |> Floki.find("#detailsframe #details .col2 dd")
      |> Enum.at(2)
      |> Floki.text
      |> Integer.parse

    {leechers, _} = html_body
      |> Floki.find("#detailsframe #details .col2 dd")
      |> Enum.at(3)
      |> Floki.text
      |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      filesize: size,
      source: "ThePirateBay",
      seeders: seeders,
      leechers: leechers
    }
  end
end
