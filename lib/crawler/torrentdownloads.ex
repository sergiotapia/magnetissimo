defmodule Magnetissimo.Crawler.TorrentDownloads do
  use GenServer
  alias Magnetissimo.Torrent
  alias Magnetissimo.Crawler.Helper

  def start_link do
    queue = initial_queue
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    schedule_work()
    {:ok, queue}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1 * 1 * 100) # 5 seconds
  end

  # Callbacks

  def handle_info(:work, queue) do
    case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        queue = queue_2
        queue = process(item, queue)
      _ ->
        IO.puts "Queue is empty - restarting queue."
        queue = initial_queue
    end
    schedule_work()
    {:noreply, queue}
  end

  def process({:page_link, url}, queue) do
    IO.puts "Downloading page: #{url}"
    html_body = Helper.download(url)
    if html_body != nil do
      torrents = torrent_links(html_body)
      queue = Enum.reduce(torrents, queue, fn torrent, queue ->
        :queue.in({:torrent_link, torrent}, queue)
      end)
    end
    queue
  end

  def process({:torrent_link, url}, queue) do
    IO.puts "Downloading torrent: #{url}"
    html_body = Helper.download(url)
    if html_body != nil do
      torrent_struct = torrent_information(html_body)
      Torrent.save_torrent(torrent_struct)
    end
    queue
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

    description = html_body
      |> Floki.find("p.para1")
      |> Floki.text

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
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

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
