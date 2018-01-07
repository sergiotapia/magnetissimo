defmodule Magnetissimo.Crawler.Zooqle do
  @moduledoc """
  Torrent parser for Zooqle in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.RSSParser
  use GenServer
  require Logger
  import Magnetissimo.Crawler.Helper
  alias Magnetissimo.Torrent

  def initial_queue do
    categories = [
      "movies",
      "music",
      "games",
      "apps",
      "books",
      "anime",
      "misc",
    ]
    urls = for category <- categories do
      {:page_link, "https://zooqle.com/search?q=#{category}&fmt=rss&s=dt&v=t&sd=d"}
    end

    :queue.from_list(urls)
  end

  def start_link(_) do
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
  end

  def init(queue) do
    Logger.info IO.ANSI.magenta <> "Starting Zooqle crawler" <> IO.ANSI.reset
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
          Logger.info "[Zooqle] Finished crawling the RSS feed, waiting 30 minutes…"
          wait = 1800000 # 30mn wait so we don't hammer the site too hard
          :timer.sleep(wait)
          initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[Zooqle] Downloading torrents from page: #{url}"
    with {:ok, body} <- download(url),
         torrent_list when is_list(torrent_list) <- torrent_information(body) do
          for torrent <- torrent_list do
            Torrent.save_torrent(torrent)
          end
    else
      {:error, message} ->
        Logger.error message
    end
    queue
  end

  defp item_to_map(item) do
    name = item
      |> Floki.find("title")
      |> Floki.text

    magnet = item
      |> Floki.find("torrent|magneturi")
      |> Floki.text

    size = item
      |> Floki.find("torrent|contentlength")
      |> Floki.text

    {seeders, _} = item
      |> Floki.find("torrent|seeds")
      |> Floki.text
      |> Integer.parse

    {leechers, _} = item
      |> Floki.find("torrent|peers")
      |> Floki.text
      |> Integer.parse

    outbound_url = item
      |> Floki.find("guid")
      |> Floki.text

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "zooqle",
      seeders: seeders,
      leechers: leechers,
      outbound_url: outbound_url,
    }
  end

  def torrent_information(rss_body) when is_binary(rss_body) and byte_size(rss_body) > 50 do
    items = Floki.find(rss_body, "channel > item")

    for item <- items do
      item_to_map(item)
    end
  end

  def torrent_information(_rss_body) do
    {:error, "Couldn't read rss feed"}
  end

end
