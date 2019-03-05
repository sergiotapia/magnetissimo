defmodule Magnetissimo.Crawlers.Leetx do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def initial_pages do
    categories = [
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

    Enum.map(categories, fn category ->
      "https://1337x.to/cat/#{category}/1/"
    end)
  end

  def init(_) do
    pages = initial_pages()
    schedule_latest_crawl()
    {:ok, pages}
  end

  def handle_info(:latest_crawl, pages) do
    Enum.map(pages, fn page_url ->
      torrent_urls = parse_page(page_url)

      Enum.map(torrent_urls, fn torrent_url ->
        torrent_information(torrent_url)
      end)
    end)
    |> List.flatten()

    # TODO - Persist torrents into database.

    schedule_latest_crawl()
    {:noreply, pages}
  end

  defp parse_page(page_url) do
    html(page_url)
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn a -> String.contains?(a, "/torrent/") end)
    |> Enum.map(fn url -> "https://1337x.to" <> url end)
  end

  def torrent_information(torrent_url) do
    html_body = html(torrent_url)

    name =
      html_body
      |> Floki.find("title")
      |> Floki.text()
      |> String.replace("Download Torrent ", "")
      |> String.replace("| 1337x", "")
      |> String.replace("Download ", "")
      |> String.trim()

    name =
      if String.ends_with?(name, " Torrent") do
        String.replace(name, " Torrent", "")
      end

    magnet =
      html_body
      |> Floki.attribute("a", "href")
      |> Enum.filter(fn x -> String.starts_with?(x, "magnet") end)
      |> get_it

    size =
      html_body
      |> Floki.find(".torrent-category-detail ul.list")
      |> Enum.at(0)
      |> Floki.find("li")
      |> Enum.at(3)
      |> Floki.find("span")
      |> Floki.text()

    {leechers, _} =
      html_body
      |> Floki.find(".leeches")
      |> Enum.at(0)
      |> Floki.text()
      |> Integer.parse()

    {seeders, _} =
      html_body
      |> Floki.find(".seeds")
      |> Enum.at(0)
      |> Floki.text()
      |> Integer.parse()

    %{
      name: name,
      magnet: magnet,
      size: size,
      seeders: seeders,
      leechers: leechers
    }
  end

  defp html(url) do
    Logger.info("[leetx] Downloading url: #{url}")

    url
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  defp schedule_latest_crawl do
    Process.send_after(self(), :latest_crawl, 5_000)
  end

  defp get_it([h | _]), do: h
  defp get_it(h), do: h
end
