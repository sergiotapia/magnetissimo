defmodule Magnetissimo.Crawler.Zooqle do
  @moduledoc """
  Torrent parser for Zooqle in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.WebParser

  use GenServer
  require Logger
  alias Magnetissimo.Torrent
  import Magnetissimo.Crawler.Helper

  def initial_queue do
    urls = [
      {:page_link, "https://zooqle.com/browse/movies/?s=dt&v=t&sd=d"},
      {:page_link, "https://zooqle.com/browse/music/?s=dt&v=t&sd=d"},
      {:page_link, "https://zooqle.com/browse/games/?s=dt&v=t&sd=d"},
      {:page_link, "https://zooqle.com/browse/apps/?s=dt&v=t&sd=d"},
      {:page_link, "https://zooqle.com/browse/books/?s=dt&v=t&sd=d"},
      {:page_link, "https://zooqle.com/browse/anime/?s=dt&v=t&sd=d"},
      {:page_link, "https://zooqle.com/browse/misc/?s=dt&v=t&sd=d"}
    ]
    :queue.from_list(urls)
  end

  def start_link(_) do
    Logger.info IO.ANSI.magenta <> "Starting Zooqle crawler" <> IO.ANSI.reset
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
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
          Logger.info "[Zooqle] Queue is empty, restarting scraping procedure."
          initial_queue()
      end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[Zooqle] Finding torrents in listing page: #{url}"
    torrents = download(url) |> torrent_links
    Enum.reduce(torrents, queue, fn torrent, queue ->
      :queue.in({:torrent_link, torrent}, queue)
    end)
  end

  def process({:torrent_link, url}, queue) do
    Logger.info "[Zooqle] Downloading torrent from page: #{url}"
    torrent_struct = download(url) |> torrent_information
    Torrent.save_torrent(torrent_struct)
    queue
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("table.table-torrents tr td td.text-trunc a.small")
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> "https://zooqle.com" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("h4#torname")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim
      |> HtmlEntities.decode

    name =
      if String.ends_with?(name, ".torrent") do
        String.replace(name, ".torrent", "")
      end

    magnet = html_body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    seeders = html_body
      |> Floki.find(".progress .prog-green")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim

    leechers = html_body
      |> Floki.find(".progress .prog-yellow")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim

    %{
      name: name,
      magnet: magnet,
      size: "0",
      website_source: "zooqle",
      seeders: seeders,
      leechers: leechers
    }
  end
end
