defmodule Magnetissimo.Crawler.NyaaSi do
  @moduledoc """
  Torrent parser for Nyaa.si in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.WebParser
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
      {:page_link, "https://nyaa.si/rss?c=#{category}"}
    end

    ## Uncomment this section to scrape NSFW content
    # nsfw_categories = [
    #   '1_1', # Art/Anime
    #   '1_2', # Art/Doujinshi
    #   '1_3', # Art/Games
    #   '1_4', # Art/Manga
    #   '1_5', # Art/Picture
    #   '2_0', # Real Life
    # ]
    # nsfw_urls = for category <- nsfw_categories do
    #   {:page_link, "https://sukebei.nyaa.si/rss?c=#{category}"}
    # end
    # urls = Enum.concat(urls, nsfw_urls)

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
        Logger.info "[Nyaa] Queue is empty, restarting scraping procedure."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[Nyaa] Getting torrent info from RSS feed: #{url}"
    result = Magnetissimo.Crawler.Helper.download(url) |> torrent_links
    case result do
      {:error, message} ->
        Logger.error message
        queue
      torrents ->
        Enum.reduce(torrents, queue, fn torrent, queue ->
          :queue.in({:torrent_link, torrent}, queue)
        end)
    end
  end

  def process({:torrent_link, url}, queue) do
    Logger.info "[Nyaa] Downloading torrent from page: #{url}"
    result = Magnetissimo.Crawler.Helper.download(url) |> torrent_information
    case result do
      {:error, message} ->
        Logger.error message
      torrent_struct ->
        torrent_struct = Map.put(torrent_struct, :outbound_url, url)
        Magnetissimo.Torrent.save_torrent(torrent_struct)
    end
    queue
  end

  def torrent_links(rss_body) do
    rss_body
      |> Floki.find("channel > item > guid")
      |> Enum.map(fn(url) -> Floki.text(url) end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("h3.panel-title")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim
      |> HtmlEntities.decode

    magnet = html_body
      |> Floki.find("div.panel-footer a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size = html_body
      |> Floki.find("div.panel-body .row:nth-child(4) div.col-md-5")
      |> Enum.at(0)
      |> Floki.text

    {seeders, _} = html_body
      |> Floki.find("div.panel-body .row:nth-child(2) div.col-md-5")
      |> Enum.at(1)
      |> Floki.text
      |> Integer.parse

    {leechers, _} = html_body
      |> Floki.find("div.panel-body .row:nth-child(3) div.col-md-5")
      |> Enum.at(1)
      |> Floki.text
      |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "nyaa",
      seeders: seeders,
      leechers: leechers
    }
  end

end
