defmodule Magnetissimo.Crawler.Monova do
  use GenServer
  alias Magnetissimo.Crawler.Helper
  alias Magnetissimo.Torrent
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
      {{_value, {:page_link, url}}, queue_2} ->
        Helper.process({:page_link, url}, queue_2, fn x -> torrent_links(x) end)
      {{_value, {:torrent_link, url}}, queue_2} ->
        Helper.process({:torrent_link, url}, queue_2, fn x -> torrent_information(x) end)
      _ ->
        Logger.debug "[Monova] Queue is empty - restarting queue."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
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

  @spec torrent_links(String.t) :: [String.t]
  def torrent_links(cat_body) when is_binary(cat_body) do
    Logger.debug "[Monova] Extracting Torrent.Ts"
    cat_body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/torrent/") end)
    |> Enum.map(fn(url) -> "https:" <> url end)
  end

  @spec torrent_information(String.t) :: T.t
  def torrent_information(torrent_body) when is_binary(torrent_body) do
    name = torrent_body
      |> Floki.find("title")
      |> Floki.text
      |> String.replace(" - Torrent.T", "")
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
