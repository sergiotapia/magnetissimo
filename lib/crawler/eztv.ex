defmodule Magnetissimo.Crawler.EZTV do
  @moduledoc """
  Torrent parser for EZTV in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.WebParser
  use GenServer
  require Logger

  def initial_queue do
    urls = for i <- 1..2 do
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
    wait = :rand.uniform(9)
    Process.send_after(self(), :work, wait * 1000) # 5 seconds
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
    torrents = Magnetissimo.Crawler.Helper.download(url) |> torrent_links
    queue = Enum.reduce(torrents, queue, fn torrent, queue ->
      :queue.in({:torrent_link, torrent}, queue)
    end)
    queue
  end

  def process({:torrent_link, url}, queue) do
    Logger.info "[EZTV] Downloading torrent from page: #{url}"
    torrent_struct = Magnetissimo.Crawler.Helper.download(url) |> torrent_information
    Magnetissimo.Torrent.save_torrent(torrent_struct)
    queue
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("a.epinfo")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/ep/") end)
    |> Enum.map(fn(url) -> "https://eztv.ag" <> url end)
  end

  def torrent_information(html_body) do
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

    size_value = html_body
      |> Floki.find("table")
      |> Enum.at(8)
      |> Floki.text
      |> String.split(" ")
      |> Enum.at(6)

    unit = html_body
      |> Floki.find("table")
      |> Enum.at(8)
      |> Floki.text
      |> String.split(" ")
      |> Enum.at(7)
      |> String.split("\n")
      |> Enum.at(0)

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
end
