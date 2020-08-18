defmodule Magnetissimo.Crawlers.Leetx do
  use GenServer
  require Logger
  alias Magnetissimo.{Torrent, Crawler, Parser}

  @site_name "1337x"
  @site_display_name @site_name
  @site_url "https://1337x.to"
  @period 15 * 60 * 1000

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
      "#{@site_url}/cat/#{category}/1/"
    end)
  end

  def init(_) do
    pages = initial_pages()
    Process.send_after(self(), :latest_crawl, 60 * 1000)
    {:ok, pages}
  end

  def handle_info(:latest_crawl, pages) do
    Enum.map(pages, fn page_url ->
      with  {:ok, torrent_pages} <- parse_index_page(page_url),
            torrents = parse_torrent_pages(torrent_pages) do
        
        Logger.debug("[#{@site_name}] Saving torrent data for: #{page_url}")
        save_torrents(torrents)
      end
    end)

    schedule_latest_crawl()
    {:noreply, pages}
  end

  defp parse_index_page(page_url) do
    Logger.debug("[#{@site_name}] Attempting to fetch page: #{page_url}")

    with {:ok, page_body} <- Crawler.get_page_body(page_url) do
      Logger.debug("[#{@site_name}] Successfully fetched page: #{page_url}")
      {:ok, page_body
        |> Floki.find("a")
        |> Floki.attribute("href")
        |> Enum.filter(fn a -> String.contains?(a, "/torrent/") end)
        |> Enum.map(fn url -> @site_url <> url end)}
    end
  end

  defp parse_torrent_pages(urls) do
    Enum.map(urls, fn url -> 
      case Crawler.get_page_body(url) do
        {:ok, torrent_page} -> torrent_information(torrent_page) |> Map.put(:canonical_url, url)
        _ -> nil
      end
    end) |> List.flatten()
  end

  defp torrent_information(html_body) do
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

    magnet_url =
      html_body
      |> Floki.attribute("a", "href")
      |> Enum.filter(fn x -> String.starts_with?(x, "magnet") end)
      |> get_it

    [size, units] = html_body
      |> Floki.find(".torrent-detail-page ul.list")
      |> Enum.at(0)
      |> Floki.find("li")
      |> Enum.at(3)
      |> Floki.find("span")
      |> Floki.text()
      |> String.split()

    {leechers, _} =
      html_body
      |> Floki.find(".torrent-detail-page ul.list")
      |> Enum.at(1)
      |> Floki.find("li")
      |> Enum.at(4)
      |> Floki.find("span")
      |> Floki.text()
      |> Integer.parse()

    {seeds, _} =
      html_body
      |> Floki.find(".torrent-detail-page ul.list")
      |> Enum.at(1)
      |> Floki.find("li")
      |> Enum.at(3)
      |> Floki.find("span")
      |> Floki.text()
      |> Integer.parse()

    %{
      name: name,
      magnet_url: magnet_url,
      size: Parser.bytes(size, units),
      seeds: seeds,
      leechers: leechers,
      magnet_hash: Parser.magnet_hash(magnet_url)
    }
  end

  defp save_torrents(torrents) do
    Enum.each(torrents, fn data ->
      if !!data do
        Torrent.changeset(%Torrent{}, %{
          name: data.name,
          canonical_url: data.canonical_url,
          magnet_url: data.magnet_url,
          leechers: data.leechers,
          seeds: data.seeds,
          website_source: @site_display_name,
          size: data.size,
          magnet_hash: data.magnet_hash
        }) |> Torrent.save
      end
    end)
  end

  defp schedule_latest_crawl do
    Process.send_after(self(), :latest_crawl, @period)
  end

  defp get_it([h | _]), do: h
  defp get_it(h), do: h
end
