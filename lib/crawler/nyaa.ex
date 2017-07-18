defmodule Magnetissimo.Crawler.NyaaSi do
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
    case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        queue = queue_2
        queue = process(item, queue)
      _ ->
        Logger.debug "[Nyaa] Queue is empty - restarting queue."
        queue = initial_queue()
    end
    schedule_work()
    {:noreply, queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[Nyaa] Downloading page: #{url}"
    html_body = Helper.download(url)
    if html_body != nil do
      torrents = torrent_links(html_body)
      queue = Enum.reduce(torrents, queue, fn torrent, queue ->
        :queue.in({:torrent_link, torrent}, queue)
      end)
    else
      Logger.warn "[Nyaa] html_body is nil"
    end
    queue
  end

  def process({:torrent_link, url}, queue) do
    Logger.info "[Nyaa] Downloading torrent: #{url}"
    html_body = Helper.download(url)
    if html_body != nil do
      torrent_struct = torrent_information(html_body)
      Torrent.save_torrent(torrent_struct)
    else
      Logger.warn "[Nyaa] html_body is nil"
    end
    queue
  end

  # Parser functions

  def initial_queue do
    urls = for i <- 1..50 do
      {:page_link, "https://nyaa.si/?p=#{i}"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(html_body) do
    Logger.debug "[Nyaa] Extracting Torrents"
    html_body
    |> Floki.find(".default td[colspan=\"2\"] a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(url) -> String.starts_with?(url, "/view/") end)
    |> Enum.map(fn(url) -> "https://nyaa.si" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("h3.panel-title")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim
      |> HtmlEntities.decode

    magnet = html_body
      |> Floki.find("div.panel-footer a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size = html_body
      |> Floki.find("div.panel-body .row:nth-child(4) div.col-md-5")
      |> Enum.at(0)
      |> Floki.text

    {seeders, _} = html_body
      |> Floki.find("div.panel-body .row:nth-child(2) div.col-md-5")
      |> Enum.at(1)
      |> Floki.text
      |> Integer.parse

    {leechers, _} = html_body
      |> Floki.find("div.panel-body .row:nth-child(3) div.col-md-5")
      |> Enum.at(1)
      |> Floki.text
      |> Integer.parse

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "nyaa",
      seeders: seeders,
      leechers: leechers
    }
  end
end
