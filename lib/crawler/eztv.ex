defmodule Magnetissimo.Crawler.EZTV do
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
        Logger.debug "[EZTV] Queue is empty - restarting queue."
        initial_queue()
    end
    schedule_work()
    {:noreply, new_queue}
  end


  # Parser functions

  def initial_queue do
    urls = for i <- 1..300 do
      {:page_link, "https://eztv.ag/page_#{i}"}
    end
    :queue.from_list(urls)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find("a.epinfo")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/ep/") end)
    |> Enum.map(fn(url) -> "https://eztv.ag" <> url end)
  end

  def torrent_information(html_body) do
    name = html_body
      |> Floki.find("td.section_post_header")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim
      |> HtmlEntities.decode

    magnet = html_body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size_value = html_body
      |> Floki.find("table")
      |> Enum.at(8)
      |> Floki.text
      |> String.split(" ")
      |> Enum.at(6)

    unit = html_body
      |> Floki.find("table")
      |> Enum.at(8)
      |> Floki.text
      |> String.split(" ")
      |> Enum.at(7)
      |> String.split("\n")
      |> Enum.at(0)

    seeders = html_body
      |> Floki.find(".stat_red")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim

    leechers = html_body
      |> Floki.find(".stat_green")
      |> Enum.at(0)
      |> Floki.text
      |> String.trim

    size = Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "eztv",
      seeders: seeders,
      leechers: leechers
    }
  end
end
