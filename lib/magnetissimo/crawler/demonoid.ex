defmodule Magnetissimo.Crawler.Demonoid do
  @moduledoc """
  Torrent parser for Demonoid in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.WebParser
  use GenServer
  require Logger
  import Magnetissimo.Crawler.Helper

  def initial_queue do
    urls = for i <- 1..5 do
      {:page_link, "https://www.demonoid.pw/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=#{i}"}
    end
    :queue.from_list(urls)
  end

  def start_link(_) do
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
  end

  def init(queue) do
    Logger.info IO.ANSI.magenta <> "[Demonoid] Starting the crawler" <> IO.ANSI.reset
    schedule_start()
    {:ok, queue}
  end

  def schedule_start() do
    wait = :rand.uniform(8) * 1000 # [1,8] seconds
    Logger.debug "[Demonoid] Starting work in #{wait / 1000}s…"
    Process.send_after(self(), :work, wait)
  end

  def schedule_work() do
    wait = 1800000 # 30mn
    Logger.info("[Demonoid] Finished crawling the RSS feed, waiting 30 minutes…")
    Process.send_after(self(), :work, wait)
  end

  def handle_info(:work, queue) do
    new_queue =
      case :queue.out(queue) do
        {{_value, item}, queue_2} ->
          process(item, queue_2)
      _ ->
        Logger.info "[Demonoid] Queue is empty, restarting scraping procedure."
        initial_queue()
    end
    Logger.debug("[Demonoid] New queue: " <> inspect new_queue)
    schedule_start()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[Demonoid] Finding torrents in listing page: #{url}"

    with {:ok, body}     <- download(url),
         {:ok, torrents} <- torrent_links(body) do
            Logger.debug "[Demonoid] Putting torrents in the queue"
            Enum.reduce(torrents, queue, fn torrent, queue ->
              :queue.in({:torrent_link, torrent}, queue)
            end)
    else
      {:error, message} ->
        Logger.error message
        queue
    end
  end

  def process({:torrent_link, url}, queue) do
    Logger.debug "[Demonoid] Processing #{url}"
    with {:ok, body}    <- download(url),
         {:ok, torrent} <- torrent_information(body) do

           torrent
           |> Map.put(:outbound_url, url)
           |> Magnetissimo.Torrent.save_torrent
    else
      {:error, message} ->
        Logger.error "[Demonoid] " <> message
    end
    queue
  end

  def torrent_links(html_body) when is_binary(html_body) and byte_size(html_body) > 50 do
    Logger.debug "[Demonoid] Getting torrents"
    result = html_body
    |> Floki.find("td.tone_1_pad a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/files/details/") end)
    |> Enum.map(fn(url) -> "https://www.demonoid.pw" <> url end)
    {:ok, result}
  end

  def torrent_links(_html_body) do
    Logger.debug "meh :/"
    {:error, "Couldn't parse torrents links."}
  end
  
  def torrent_information(html_body) when is_binary(html_body) and byte_size(html_body) > 50 do
    Logger.debug "Assembling informations"
    name = html_body
      |> Floki.find("td.ctable_header")
      |> Floki.text
      |> String.replace("Details for ", "")
      |> String.replace(" Download this torrentExtra informationComments", "")
      |> String.replace("Download this torrentExtra informationComments", "")
      |> String.trim
      |> HtmlEntities.decode

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
    size = size_to_bytes(size_value, unit) |> Sizeable.filesize

    {:ok, %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "demonoid",
      seeders: 0,
      leechers: 0
    }}
  end

  def torrent_information(_html_body) do
    {:error, "Couldn't parse torrent information"}
  end

end
