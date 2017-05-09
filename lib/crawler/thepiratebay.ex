defmodule Magnetissimo.Crawler.ThePirateBay do
  @moduledoc """
  Torrent parser for ThePirateBay in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.WebParser
  use GenServer
  require Logger

  def initial_queue do
    urls = for i <- 1..6, j <- 1..50 do
      {:page_link, "https://thepiratebay.org/browse/#{i}00/#{j}/3"}
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
    Process.send_after(self(), :work, 1 * 1 * 100) # 5 seconds
  end

  def handle_info(:work, queue) do
    queue =
      case :queue.out(queue) do
        {{_value, item}, queue_2} ->
          process(item, queue_2)
      _ ->
        Logger.info "[ThePirateBay] Queue is empty, restarting scraping procedure."
        initial_queue()
    end
    schedule_work()
    {:noreply, queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[ThePirateBay] Finding torrents in listing page: #{url}"
    html_body = Magnetissimo.Crawler.Helper.download(url)
    queue =
      if html_body != nil do
        torrents = torrent_links(html_body)
        Enum.reduce(torrents, queue, fn torrent, queue ->
          :queue.in({:torrent_link, torrent}, queue)
        end)
      end
    queue
  end

  def process({:torrent_link, url}, queue) do
    Logger.info "[ThePirateBay] Downloading torrent from page: #{url}"
    html_body = Magnetissimo.Crawler.Helper.download(url)
    if html_body != nil do
      torrent_struct = torrent_information(html_body)
      Magnetissimo.Torrent.save_torrent(torrent_struct)
    end
    queue
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find(".detName a")
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> "https://thepiratebay.org" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("#title")
      |> Floki.text
      |> String.trim
      |> HtmlEntities.decode

    magnet = html_body
      |> Floki.find(".download a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size = html_body
      |> Floki.find("#detailsframe #details .col1 dd")
      |> Enum.at(2)
      |> Floki.text
      |> String.split(<<194, 160>>)
      |> Enum.at(2)
      |> String.replace("(", "")

    {seeders, _} = html_body
      |> Floki.find("#detailsframe #details .col2 dd")
      |> Enum.at(2)
      |> Floki.text
      |> Integer.parse

    {leechers, _} = html_body
      |> Floki.find("#detailsframe #details .col2 dd")
      |> Enum.at(3)
      |> Floki.text
      |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "thepiratebay",
      seeders: seeders,
      leechers: leechers
    }
  end
end
