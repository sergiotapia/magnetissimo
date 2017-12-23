defmodule Magnetissimo.Crawler.EZTV do
  @moduledoc """
  Torrent parser for EZTV in charge of parsing the RSS feed
  """

  use GenServer
  require Logger
  import Magnetissimo.Crawler.Helper
  alias Magnetissimo.Torrent

  def initial_queue do
    url = "https://eztv.ag/ezrss.xml"
    case download(url) do
      {:ok, body} ->
        body
        |> Floki.find("channel")
        |> Floki.find("item")
        |> Enum.map(fn x -> elem(x,2) end)
      {:error, :wrong_headers} ->
        Logger.error "[EZTV] Wrong headers in the HTTP Response!"
        []
    end
  end

  def start_link(_) do
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
  end

  def init(queue) do
    schedule_start()
    {:ok, queue}
  end

  def schedule_start() do
    wait = :rand.uniform(8) * 1000 # [1,8] seconds
    Process.send_after(self(), :work, wait)
  end

  def schedule_work() do
    wait = 1800000 # 30mn
    Logger.info("[EZTV] Finished crawling the RSS feed, waiting 30 minutes…")
    Process.send_after(self(), :work, wait)
  end

  def handle_info(:work, queue) do
    queue
    |> Enum.each(&(process(&1)))
    schedule_work()
    {:noreply, initial_queue()}
  end

  def process(item) do
    item
    |> torrent_information
    |> Torrent.save_torrent()
  end

  def torrent_information(item) do
    attributes = [["title"], ["torrent:magneturi"], ["torrent:seeds"], ["torrent:peers"], ["link"]]
    data = item
           |> Enum.map(fn f -> %{elem(f,0) => elem(f, 2)} end)
           |> Enum.filter(fn f -> Enum.member?(attributes, Map.keys(f)) end)
           |> Enum.reduce(fn(map, acc) -> Map.merge(map, acc) end)

    %{
      name: hd(data["title"]),
      magnet: hd(data["torrent:magneturi"]),
      size: "0MB",
      website_source: "eztv",
      seeders:  String.to_integer(hd(data["torrent:seeds"])),
      leechers: String.to_integer(hd(data["torrent:peers"])),
      outbound_url: hd(data["link"])
    }
  end
end
