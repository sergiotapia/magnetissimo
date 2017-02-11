defmodule Magnetissimo.Crawler.Leetx do
  use GenServer
  use Magnetissimo.Crawler.Cachable
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
    torrents = Helper.download(url) |> torrent_links
    queue = Enum.reduce(torrents, queue, fn torrent, queue ->
      :queue.in({:torrent_link_cache, torrent}, queue)
    end)
    queue
  end

  def process({:torrent_link, url}, queue) do
    IO.puts "Downloading torrent: #{url}"
    torrent_struct = Helper.download(url) |> torrent_information
    Torrent.save_torrent(torrent_struct)
    queue
  end

  # Parser functions

  def initial_queue do
    categories = [
      "Anime",
      "Apps",
      "Documentaries",
      "Games",
      "Movies",
      "Music",
      "Other",
      "TV",
      "XXX"
    ]
    urls = for i <- 1..50, category <- categories do
      {:page_link, "https://1337x.to/cat/#{category}/#{i}/"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/torrent/") end)
    |> Enum.map(fn(url) -> "https://1337x.to" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("title")
      |> Floki.text
      |> String.replace("Download Torrent ", "")
      |> String.replace("| 1337x", "")
      |> String.replace("Download ", "")
      |> String.trim

    magnet = html_body
      |> Floki.find("a.btn-magnet")
      |> Floki.attribute("href")
      |> Enum.at(0)

    size = html_body
      |> Floki.find(".torrent-category-detail ul.list")
      |> Enum.at(0)
      |> Floki.find("li")
      |> Enum.at(3)
      |> Floki.find("span")
      |> Floki.text
      |> String.split
    size_value = Enum.at(size, 0)
    unit = Enum.at(size, 1)
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    {leechers, _} = html_body
      |> Floki.find(".leeches")
      |> Enum.at(0)
      |> Floki.text
      |> Integer.parse

    {seeders, _} = html_body
      |> Floki.find(".seeds")
      |> Enum.at(0)
      |> Floki.text
      |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "1337x",
      seeders: seeders,
      leechers: leechers
    }
  end
end
