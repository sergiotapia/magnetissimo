defmodule Magnetissimo.Crawler.WorldWideTorrents do
  use GenServer
  alias Magnetissimo.Torrent
  alias Magnetissimo.Crawler.Helper
  require Logger

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

  # Callbacks

  def handle_info(:work, queue) do
    new_queue = case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        process(item, queue_2)
      _ ->
        Logger.debug "[World Wide Torrent.Ts] Queue is empty - restarting queue."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  # Custom process function.
  def process({:page_link, url}, queue) do
    IO.puts "Downloading page: #{url}"
    html_body = Helper.download(url)
    if html_body != nil do
      torrent_information(html_body)
      |> Enum.each(fn(torrent) -> Torrent.save_torrent(torrent) end)
    end
    queue
  end

  # Parser functions

  # WorldWideTorrent.Ts offers all of it's content on it's pagination page.
  # There's no need to go into a torrent detail page.
  def initial_queue do
    urls = for i <- 1..50 do
      {:page_link, "https://worldwidetorrents.eu/torrents.php?page=#{i}"}
    end
    :queue.from_list(urls)
  end

  def torrent_information(html_body) when is_binary(html_body) do
    torrents = html_body
      |> Floki.find(".ttable_headinner .t-row")
      |> Enum.map(fn(row) -> parse_row(row) end)
    torrents
  end

  @spec parse_row(tuple()) :: T.t
  def parse_row(row) when is_tuple(row) do
    name = row
      |> Floki.find("td")
      |> Enum.at(0)
      |> Floki.find("a b")
      |> Floki.text
      |> String.trim

    magnet = row
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size_html = row
      |> Floki.find("td")
      |> Enum.at(4)
      |> Floki.text
      |> String.replace(",", "")
      |> String.split
    size_value = Enum.at(size_html, 0)
    unit = Enum.at(size_html, 1)
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    seeders = row
      |> Floki.find("td")
      |> Enum.at(5)
      |> Floki.text
      |> String.replace(",", "")

    leechers = row
      |> Floki.find("td")
      |> Enum.at(6)
      |> Floki.text
      |> String.replace(",", "")

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "worldwidetorrents",
      seeders: seeders,
      leechers: leechers
    }
  end
end
