defmodule Magnetissimo.Crawler.EZTV do
  @moduledoc """
  Torrent parser for EZTV in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.WebParser
  use GenServer
  require Logger

  def initial_queue do
    urls = for i <- 0..4 do
      {:page_link, "https://eztv.ag/page_#{i}"}
    end
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
          Logger.info "[EZTV] Queue is empty, restarting scraping procedure."
          initial_queue()
      end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[EZTV] Finding torrents in listing page: #{url}"
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
    Logger.info "[EZTV] Downloading torrent from page: #{url}"
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

  def torrent_links(html_body) when is_binary(html_body) and byte_size(html_body) > 50 do
    html_body
    |> Floki.find("a.epinfo")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/ep/") end)
    |> Enum.map(fn(url) -> "https://eztv.ag" <> url end)
  end

  def torrent_links(_html_body) do
    {:error, "Couldn't parse torrents links."}
  end

  def torrent_information(html_body) when is_binary(html_body) and byte_size(html_body) > 50 do
    name = html_body
      |> Floki.find("td.section_post_header")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim
      |> HtmlEntities.decode

    magnet = html_body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size_table = html_body
      |> Floki.find("table")
      |> Enum.at(8)
      |> Floki.text
      |> String.split(" ")
    
    size_value = 0
    unit = "MB"
    if Enum.count(size_table) == 18 do
      size_value = size_table
      |> Enum.at(6)

      unit = size_table
        |> Enum.at(7)
        |> String.split("\n")
        |> Enum.at(0)  
    end

    seeders = html_body
      |> Floki.find(".stat_red")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim

    leechers = html_body
      |> Floki.find(".stat_green")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim

    size = Magnetissimo.Crawler.Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "eztv",
      seeders: seeders,
      leechers: leechers
    }
  end

  def torrent_information(_html_body) do
    {:error, "Couldn't parse torrent information"}
  end
end
