defmodule Magnetissimo.Crawler.TorrentDownloads do
  use GenServer
  alias Magnetissimo.Torrent
  import Magnetissimo.Crawler.Helper
  require Logger

  def start_link(_) do
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    schedule_work()
    {:ok, queue}
  end

  defp schedule_work do
    wait = :rand.uniform(9)
    Process.send_after(self(), :work, wait * 100) # 5 seconds
  end

  # Callbacks

  def handle_info(:work, queue) do
    new_queue = 
      case :queue.out(queue) do
        {{_value, item}, queue_2} ->
          process(item, queue_2)
        _ ->
          Logger.info "[TorrentDownloads] Queue is empty, restarting scraping procedure."
          initial_queue()
      end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[TorrentDownloads] Finding torrents in listing page: #{url}"
    case download(url) do
      {:error, :empty} -> Logger.warn "[TorrentDownloads] Empty page! for URL " <> url
      html_body ->
        torrents = torrent_links(html_body.body)
        Enum.reduce(torrents, queue, fn torrent, queue ->
          :queue.in({:torrent_link, torrent}, queue)
        end)
    end
  end

  def process({:torrent_link, url}, queue) do
    Logger.info "[TorrentDownloads] Downloading torrent from page: #{url}"
    html_body = download(url)
    if html_body do
      torrent_struct = torrent_information(html_body)
      Torrent.save_torrent(torrent_struct)
      queue
    end
  end

  # Parser functions

  def initial_queue do
    categories = [
      "TV_Shows",
      "Movies",
      "Music",
      "Games",
      "Software",
      "Anime",
      "Books",
      "Other"
    ]
    urls = for i <- 1..10, category <- categories do
      {:page_link, "https://www.torrentdownloads.me/view/popular/#{category}.html?page=#{i}"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find(".grey_bar3 p a")
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> "https://www.torrentdownloads.me" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("h1.titl_1 span")
      |> Floki.text
      |> String.trim

    magnet = html_body
      |> Floki.find(".grey_bar1 p a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size_html = html_body
      |> Floki.find(".grey_bar1 p")
      |> Enum.at(1)
      |> Floki.text
      |> String.replace("Total Size: ", "")
      |> String.trim
      |> String.split(<<194, 160>>)
    size_value = Enum.at(size_html, 0)
    unit = Enum.at(size_html, 1)
    size = size_to_bytes(size_value, unit) |> Kernel.to_string

    {seeders, _} = html_body
      |> Floki.find(".grey_bar1 p")
      |> Enum.at(3)
      |> Floki.text
      |> String.split(":")
      |> Enum.at(1)
      |> String.trim
      |> Integer.parse

    {leechers, _} = html_body
      |> Floki.find(".grey_bar1 p")
      |> Enum.at(4)
      |> Floki.text
      |> String.split(":")
      |> Enum.at(1)
      |> String.trim
      |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "torrentdownloads",
      seeders: seeders,
      leechers: leechers
    }
  end
end
