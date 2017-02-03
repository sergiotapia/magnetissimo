defmodule Magnetissimo.Crawler.LimeTorrents do
  use GenServer
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
      {{_value, {:page_link, url}}, queue_2} ->
        Helper.process({:page_link, url}, queue_2, fn x -> torrent_links(x) end)
      {{_value, {:torrent_link, url}}, queue_2} ->
        Helper.process({:torrent_link, url}, queue_2, fn x -> torrent_information(x) end)
      _ ->
        Logger.debug "[LimeTorrents] Queue is empty - restarting queue."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  # Parser functions

  def initial_queue do
    categories = [
      "Movies",
      "Applications",
      "TV-shows",
      "Music",
      "Anime",
      "Other",
      "Games"
    ]
    urls = for i <- 1..10, category <- categories do
      {:page_link, "https://www.limetorrents.cc/browse-torrents/#{category}/date/#{i}/"}
    end
    :queue.from_list(urls)
  end

  @spec torrent_links(nil) :: nil
  @spec torrent_links(String.t) :: list(String.t)

  def torrent_links(nil), do: nil
  def torrent_links(html_body) when is_binary(html_body) do
    html_body
    |> Floki.find(".tt-name a")
    |> Enum.drop_every(2)
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> "https://www.limetorrents.cc" <> url end)
  end

  def torrent_information(html_body) when is_binary(html_body) do
    name = html_body
      |> Floki.find("h1")
      |> Floki.text
      |> String.trim

    magnet = html_body
      |> Floki.find(".dltorrent a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size_html = html_body
      |> Floki.find(".torrentinfo table td")
      |> Enum.at(5)
      |> Floki.text
    size_value = String.split(size_html) |> Enum.at(0)
    unit = String.split(size_html) |> Enum.at(1)
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "limetorrents",
      seeders: 0,
      leechers: 0
    }
  end
end
