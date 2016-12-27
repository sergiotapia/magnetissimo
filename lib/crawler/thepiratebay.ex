defmodule Magnetissimo.Crawler.ThePirateBay do
  use GenServer
  alias Magnetissimo.Torrent

  def initial_queue do
    # urls = for i <- 1..6, j <- 1..50 do
    urls = for i <- 1..2, j <- 1..2 do
      {:page_link, "https://thepiratebay.org/browse/#{i}00/#{j}/3"}
    end
    :queue.from_list(urls)
  end

  def start_link do
    queue = initial_queue
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    schedule_work()
    {:ok, queue}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1 * 1 * 300) # 5 seconds
  end

  # Callbacks

  def handle_info(:work, queue) do
    case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        queue = queue_2
        queue = process(item, queue)
      _ ->
        IO.puts "Queue is empty."
    end
    schedule_work()
    {:noreply, queue}
  end

  def process({:page_link, url}, queue) do
    IO.puts "Downloading page: #{url}"
    torrents = download(url) |> torrent_links
    queue = Enum.reduce(torrents, queue, fn torrent, queue ->
      :queue.in({:torrent_link, torrent}, queue)
    end)
    queue
  end

  def process({:torrent_link, url}, queue) do
    IO.puts "Downloading torrent: #{url}"
    torrent_struct = download(url) |> torrent_information
    Torrent.save_torrent(torrent_struct)
    queue
  end

  # Parser functions

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

  def download(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Error: #{url} is 404."
        nil
      {:error, %HTTPoison.Error{reason: _}} ->
        IO.puts "Error: #{url} just ain't workin."
        nil
    end
  end
end
