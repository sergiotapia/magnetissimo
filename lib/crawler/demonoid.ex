defmodule Magnetissimo.Crawler.Demonoid do
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
    Process.send_after(self(), :work, 1 * 1 * 300) # 5 seconds
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
      :queue.in({:torrent_link, torrent}, queue)
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
    urls = for i <- 1..200 do
      {:page_link, "https://www.demonoid.pw/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page=#{i}"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("td.tone_1_pad a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/files/details/") end)
    |> Enum.map(fn(url) -> "https://www.demonoid.pw" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("td.ctable_header")
      |> Floki.text
      |> String.replace("Details for ", "")
      |> String.replace(" Download this torrentExtra informationComments", "")
      |> String.replace("Download this torrentExtra informationComments", "")
      |> String.trim
      |> HtmlEntities.decode

    description = html_body
      |> Floki.find("span.adbriteinline")
      |> Floki.text

    magnet = html_body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(a) -> String.starts_with?(a, "magnet:") end)
      |> Enum.at(0)

    size = html_body
      |> Floki.find("td")
      |> Enum.filter(fn(a) ->
        size_container = Floki.attribute(a, "width") |> Enum.at(0)
        size_container == "50%"
      end)
      |> Enum.at(0)
      |> Floki.text
      |> String.replace("Size: ", "")
      |> String.trim
      |> String.split

    size_value = Enum.at(size, 0)
    unit = Enum.at(size, 1)
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "demonoid",
      seeders: 0,
      leechers: 0
    }
  end
end
