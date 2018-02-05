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
      "1_0", # Anime
      "2_0", # Audio
      "3_0", # Literature
      "4_0", # Live Action
      "5_0", # Pictures
      "6_0", # Software
    ]
    urls = for category <- categories do
      {:page_link, "https://nyaa.si/rss?c=#{category}&m"}
    end

    nsfw_categories = [
      "1_1", # Art/Anime
      "1_2", # Art/Doujinshi
      "1_3", # Art/Games
      "1_4", # Art/Manga
      "1_5", # Art/Picture
      "2_0", # Real Life
    ]
    nsfw_urls = for category <- nsfw_categories do
      {:page_link, "https://sukebei.nyaa.si/rss?c=#{category}&m"}
    end
    urls = Enum.concat(urls, nsfw_urls)

    :queue.from_list(urls)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    Logger.info IO.ANSI.magenta <> "Starting NyaaSi crawler" <> IO.ANSI.reset
    try do
      queue = initial_queue()
      schedule_work()
      {:ok, queue}
    rescue
      exception ->
         Logger.error inspect exception
         :ignore
    end
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
          wait = 1800000 # 30mn wait so we don't hammer the site too hard
          :timer.sleep(wait)
          Logger.info "[NyaaSi] Queue is empty, restarting scraping procedure."
          initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[NyaaSi] Downloading torrents from page: #{url}"
    with {:ok, body} <- Magnetissimo.Crawler.Helper.download(url),
         torrent_list when is_list(torrent_list) <- torrent_information(body) do
          for torrent <- torrent_list do
            Magnetissimo.Torrent.save_torrent(torrent)
          end
    else
      {:error, message} ->
        Logger.error message
    end
    queue
  end

  defp fix_size(size) do
    {number_part, unit_part} = Float.parse size
    # Largest file on nyaa as of 07/2017 is 4.6 TiB, so we go 1 order of magnitude higher for future-proofing
    fixed_size = case String.trim(unit_part) do
      "PiB" ->
        number_part * :math.pow(1024, 5)
      "TiB" ->
        number_part * :math.pow(1024, 4)
      "GiB" ->
        number_part * :math.pow(1024, 3)
      "MiB" ->
        number_part * :math.pow(1024, 2)
      "KiB" ->
        number_part * :math.pow(1024, 1)
      "Bytes" ->
        number_part
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

    category = item
      |> Floki.find("nyaa|category")
      |> Floki.text

    nsfw = is_nsfw?(category)

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "nyaasi",
      seeders: seeders,
      leechers: leechers,
      outbound_url: outbound_url,
      category: category,
      nsfw: nsfw,
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

  defp is_nsfw?(category) do
    case category do
      "Software - Applications" -> false
      "Software - Games" -> false
      "Audio - Lossless" -> false
      "Audio - Lossy" -> false
      "Anime - English-translated" -> false
      "Anime - Raw" -> false
      "Anime - Anime Music Video" -> false
      "Anime - Non-English-translated" -> false
      "Literature - English-translated" -> false
      "Literature - Raw" -> false
      "Literature - Non-English-translated" -> false
      "Live Action - English-translated" -> false
      "Live Action - Idol/Promotional Video" -> false
      "Live Action - Raw" -> false
      "Live Action - Non-English-translated" -> false
      "Pictures - Graphics" -> false
      "Pictures - Photos" -> false
      "Art - Anime" -> true
      "Art - Doujinshi" -> true
      "Art - Games" -> true
      "Art - Manga" -> true
      "Art - Pictures" -> true
      "Real Life - Photobooks and Pictures" -> true
      "Real Life - Videos" -> true
    end
  end

end
