defmodule Magnetissimo.Crawler.Leetx do
  use GenServer
  alias Magnetissimo.Crawler.Helper
  require Logger
  alias Magnetissimo.Torrent.T 

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
        Logger.debug "[Leetx] Queue is empty - restarting queue."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end

  # Parser functions

  def initial_queue do
    categories = [
      "Anime",
      "Apps",
      "Documentaries",
      "Games",
      "Movies",
      "Music",
      "Other",
      "TV",
      "XXX"
    ]
    urls = for i <- 1..50, category <- categories do
      {:page_link, "https://1337x.to/cat/#{category}/#{i}/"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(html_body) when is_binary(html_body) do
    html_body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/torrent/") end)
    |> Enum.map(fn(url) -> "https://1337x.to" <> url end)
  end

  @spec torrent_information(String.t) :: T.t
  def torrent_information(html_body) when is_binary(html_body) do
    name = html_body
      |> Floki.find("title")
      |> Floki.text
      |> String.replace("Download Torrent.T ", "")
      |> String.replace("| 1337x", "")
      |> String.replace("Download ", "")
      |> String.trim

    magnet = html_body
      |> Floki.find("a.btn-magnet")
      |> Floki.attribute("href")
      |> Enum.at(0)

    size = html_body
      |> Floki.find(".torrent-category-detail ul.list")
      |> Enum.at(0)
      |> Floki.find("li")
      |> Enum.at(3)
      |> Floki.find("span")
      |> Floki.text
      |> String.split
    size_value = Enum.at(size, 0)
    unit = Enum.at(size, 1)
    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    {leechers, _} = html_body
      |> Floki.find(".leeches")
      |> Enum.at(0)
      |> Floki.text
      |> Integer.parse

    {seeders, _} = html_body
      |> Floki.find(".seeds")
      |> Enum.at(0)
      |> Floki.text
      |> Integer.parse

    %T{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "1337x",
      seeders: seeders,
      leechers: leechers
    }
  end
end
