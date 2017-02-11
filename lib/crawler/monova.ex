defmodule Magnetissimo.Crawler.Monova do
  use GenServer
  use Magnetissimo.Crawler.Cachable
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
    Process.send_after(self(), :work, 1 * 1 * 100)
  end
  # Callbacks

  def handle_info(:work, queue) do
    new_queue = case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        process(item, queue_2)
      _ ->
        Logger.debug "[Monova] Queue is empty - restarting queue."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    IO.puts "Downloading page: " <> url
    torrents = Helper.download(url) |> torrent_links
    queue = Enum.reduce(torrents, queue, fn torrent, queue ->
      :queue.in({:torrent_link_cache, torrent}, queue)
    end)
    queue
  end

  def process({:torrent_link, url}, queue) do
    torrent_struct = Helper.download(url) |> torrent_information
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
    Logger.debug "[Monova] Extracting Torrents"
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
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

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
          Logger.error "Couldn't properly parse this page!"
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
