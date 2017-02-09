defmodule Magnetissimo.Crawler.ThePirateBay do
  use GenServer
  alias Magnetissimo.Torrent
  alias Magnetissimo.Crawler.Helper

  def start_link do
    queue = initial_queue
    GenServer.start_link(__MODULE__, {queue, %{}})
  end

  def init({queue, cache}) do
    schedule_work()
    {:ok, {queue, cache}}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1 * 1 * 100) # 5 seconds
  end

  # Callbacks

  def handle_info(:work, {queue, cache}) do
    case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        queue = queue_2
        {queue, cache} = process(item, {queue, cache})
      _ ->
        IO.puts "Queue is empty - restarting queue."
        queue = initial_queue
    end
    schedule_work()
    {:noreply, {queue, cache}}
  end

  def process({:page_link, url}, {queue, cache}) do
    IO.puts "Downloading page: #{url}"
    html_body = Helper.download(url)
    if html_body != nil do
      torrents = torrent_links(html_body)
      queue = Enum.reduce(torrents, queue, fn torrent, queue ->
      :queue.in({:torrent_link, torrent}, queue)
      end)
    end
    {queue, cache}
  end

  def process({:torrent_link, url}, {queue, cache}) do
    IO.puts "Downloading torrent: #{url}"
    html_body = Helper.download(url)
    if html_body != nil do
      torrent_struct = torrent_information(html_body)
      case Map.fetch(cache, torrent_struct.magnet) do
        :error ->
          cache = Map.put(cache, torrent_struct.magnet, DateTime.to_unix(DateTime.utc_now))
          :queue.in({:torrent_link, torrent_struct}, queue)
          Torrent.save_torrent(torrent_struct)
        {:ok, timestamp} ->
          if timestamp < DateTime.to_unix(DateTime.utc_now) - 1 * 24 * 60 * 60 do
            cache = Map.put(cache, torrent_struct.magnet, DateTime.to_unix(DateTime.utc_now))
            :queue.in({:torrent_link, torrent_struct}, queue)
            Torrent.save_torrent(torrent_struct)
          end

          IO.puts "Torrent already cached: #{url}"
          cache = cache
      end
    end
    {queue, cache}
  end

  # Parser functions


  def initial_queue do
    urls = for i <- 1..6, j <- 1..50 do
      {:page_link, "https://thepiratebay.org/browse/#{i}00/#{j}/3"}
    end
    :queue.from_list(urls)
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
