defmodule Magnetissimo.Crawler.Isohunt do
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
    urls = for i <- 0..40 do
      {:page_link, "https://isohunt.to/latest.php?Torrent_page=#{i * 40}"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("td.title-row a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "torrent_details") end)
    |> Enum.reject(fn(a) -> String.contains?(a, "bitlord") end)
    |> Enum.map(fn(url) -> "https://isohunt.to" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("h1.torrent-header")
      |> Floki.text
      |> String.trim
      |> String.replace(" [Isohunt.to]", "")

    magnet = html_body
      |> Floki.find("a.btn-magnet")
      |> Floki.attribute("href")
      |> Enum.at(0)

    attributes = html_body
      |> Floki.find(".text-lg.mb2")
      |> Floki.text
      |> String.split

    size_value = Enum.at(attributes, 0) |> String.replace("Size", "") |> String.trim
    unit = Enum.at(attributes, 1)
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    {seeders, _} = Enum.at(attributes, 2) |> String.replace("seeders", "") |> String.trim |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "isohunt",
      seeders: seeders,
      leechers: 0
    }
  end
end
