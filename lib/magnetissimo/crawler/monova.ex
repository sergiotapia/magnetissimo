defmodule Magnetissimo.Crawler.Monova do
  use GenServer
  alias Magnetissimo.Torrent
  import Magnetissimo.Crawler.Helper
  require Logger

  def start_link(_) do
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
  end

  def init(queue) do
    Logger.info IO.ANSI.magenta <> "Starting Monova crawler" <> IO.ANSI.reset
    schedule_work()
    {:ok, queue}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1 * 1 * 100)
  end
  # Callbacks

  def handle_info(:work, queue) do
    new_queue = case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        process(item, queue_2)
      _ ->
        Logger.debug "[Monova] Queue is empty - restarting queue."
        wait = 1800000 # 30mn wait so we don't hammer the site too hard
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    # Logger.debug "[Monova] Downloading page: " <> url
    case download(url) do
      {:ok, body} -> 
        torrents = torrent_links(body)
        Enum.reduce(torrents, queue, fn torrent, queue ->
          :queue.in({:torrent_link, torrent}, queue)
        end)
      {:error, msg} ->
        Logger.error "[Monova] #{inspect msg}"
        queue
    end
  end

  def process({:torrent_link, url}, queue) do
    torrent_struct = url |> download |> torrent_information
    Torrent.save_torrent(torrent_struct)
    queue
  end

  ##       ##
  # Parsing #
  ##       ##

  def initial_queue do
  urls =
    for i <- 1..50 do
      {:page_link, "https://monova.org/latest?page=#{i}"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(cat_body) do
    cat_body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/torrent/") end)
    |> Enum.map(fn(url) -> "https:" <> url end)
  end

  def torrent_information(torrent_body) do
    name = torrent_body
      |> Floki.find("title")
      |> Floki.text
      |> String.replace(" - Torrent", "")
      |> String.trim

    magnet = torrent_body
      |> Floki.find("#download-magnet")
      |> Floki.attribute("href")
      |> Enum.at(0)

    size_html = get_size(torrent_body) |> String.split(" ")
    size_value = Enum.at(size_html, 0)
    unit = Enum.at(size_html, 1)
    size = size_to_bytes(size_value, unit) |> Kernel.to_string

    ## Leechers and Seeders informations are not provided by Monova.
    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "Monova",
      seeders: 0,
      leechers: 0
    }

  end

  @spec get_size(String.t) :: String.t
  def get_size(torrent_body) do
    size = torrent_body
      |> Floki.find(".general-table")
      |> Floki.find("tr")
      |> Enum.sort
      |> Enum.reverse
      |> Enum.at(1)
      |> extract_size

    case size do
        {:error, :bad_tree} ->
          Logger.error "[Monova] Couldn't properly parse this page!"
          "0"
        {:ok, torrent_size} ->
          torrent_size
    end
  end


  # A tiny helper.
  defp extract_size({"tr", [], [{"td", [], ["Total Size:"]}, {"td", [], [size]}]}) do
    {:ok, size}
  end
  defp extract_size(_), do: {:error, :bad_tree}
end
