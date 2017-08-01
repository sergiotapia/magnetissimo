defmodule Magnetissimo.Crawler.NyaaSi do
  @moduledoc """
  Torrent parser for Nyaa.si in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.RSSParser
  use GenServer
  require Logger

  def initial_queue do
    categories = [
      '1_0', # Anime
      '2_0', # Audio
      '3_0', # Literature
      '4_0', # Live Action
      '5_0', # Pictures
      '6_0', # Software
    ]
    urls = for category <- categories do
      {:page_link, "https://nyaa.si/rss?c=#{category}&m"}
    end

    # Uncomment this section to scrape NSFW content
    nsfw_categories = [
      '1_1', # Art/Anime
      '1_2', # Art/Doujinshi
      '1_3', # Art/Games
      '1_4', # Art/Manga
      '1_5', # Art/Picture
      '2_0', # Real Life
    ]
    nsfw_urls = for category <- nsfw_categories do
      {:page_link, "https://sukebei.nyaa.si/rss?c=#{category}&m"}
    end
    urls = Enum.concat(urls, nsfw_urls)

    :queue.from_list(urls)
  end

  def start_link do
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    schedule_work()
    {:ok, queue}
  end

  defp schedule_work do
    wait_seconds = :rand.uniform(8) * 1000
    Process.send_after(self(), :work, wait_seconds)
  end

  def handle_info(:work, queue) do
    new_queue =
      case :queue.out(queue) do
        {{_value, item}, queue_2} ->
          process(item, queue_2)
      _ ->
        Logger.info "[NyaaSi] Queue is empty, restarting scraping procedure."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[NyaaSi] Downloading torrents from page: #{url}"
    result = Magnetissimo.Crawler.Helper.download(url) |> torrent_information
    case result do
      {:error, message} ->
        Logger.error message
      torrent_list ->
        for torrent <- torrent_list do
          Magnetissimo.Torrent.save_torrent(torrent)
        end
    end
    queue
  end

  def item_to_map(item) do
    name = item
      |> Floki.find("title")
      |> Floki.text

    magnet = item
      |> Floki.find("link")
      |> Floki.text

    size = item
      |> Floki.find("nyaa|size")
      |> Floki.text

    {seeders, _} = item
      |> Floki.find("nyaa|seeders")
      |> Floki.text
      |> Integer.parse

    {leechers, _} = item
      |> Floki.find("nyaa|leechers")
      |> Floki.text
      |> Integer.parse

    outbound_url = item
      |> Floki.find("guid")
      |> Floki.text

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "nyaasi",
      seeders: seeders,
      leechers: leechers,
      outbound_url: outbound_url,
    }
  end

  def torrent_information(rss_body) do
    items = rss_body
      |> Floki.find("channel > item")

    maps = for item <- items do
      item_to_map(item)
    end
    maps
  end

end
