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

    # # Uncomment this section to scrape NSFW content
    # nsfw_categories = [
    #   '1_1', # Art/Anime
    #   '1_2', # Art/Doujinshi
    #   '1_3', # Art/Games
    #   '1_4', # Art/Manga
    #   '1_5', # Art/Picture
    #   '2_0', # Real Life
    # ]
    # nsfw_urls = for category <- nsfw_categories do
    #   {:page_link, "https://sukebei.nyaa.si/rss?c=#{category}&m"}
    # end
    # urls = Enum.concat(urls, nsfw_urls)

    :queue.from_list(urls)
  end

  def start_link(_) do
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
        wait_seconds = 10 * 1000 # 10 second wait so we don't hammer the site too hard
        :timer.sleep(wait_seconds)
        Logger.info "[NyaaSi] Queue is empty, restarting scraping procedure."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[NyaaSi] Downloading torrents from page: #{url}"
    case Magnetissimo.Crawler.Helper.download(url) do
      {:error, message} ->
        Logger.error message
      page ->
        result = page.body |> torrent_information
    end
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

  defp fix_size(size) do
    {number_part, unit_part} = Float.parse size
    # Largest file on nyaa as of 07/2017 is 4.6 TiB, so we go 1 order of magnitude higher for future-proofing
    case unit_part |> String.trim do
      "PiB" ->
        fixed_size = number_part * :math.pow(1024, 5)
      "TiB" ->
        fixed_size = number_part * :math.pow(1024, 4)
      "GiB" ->
        fixed_size = number_part * :math.pow(1024, 3)
      "MiB" ->
        fixed_size = number_part * :math.pow(1024, 2)
      "KiB" ->
        fixed_size = number_part * :math.pow(1024, 1)
      "Bytes" ->
        fixed_size = number_part
    end

    fixed_size
      |> round
      |> Integer.to_string
  end

  defp item_to_map(item) do
    name = item
      |> Floki.find("title")
      |> Floki.text

    magnet = item
      |> Floki.find("link")
      |> Floki.text

    size = item
      |> Floki.find("nyaa|size")
      |> Floki.text
      |> fix_size

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

  def torrent_information(rss_body) when is_binary(rss_body) and byte_size(rss_body) > 50 do
    items = rss_body
      |> Floki.find("channel > item")

    maps = for item <- items do
      item_to_map(item)
    end
    maps
  end

  def torrent_information(_rss_body) do
    {:error, "Couldn't read rss feed"}
  end

end
