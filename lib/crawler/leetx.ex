defmodule Magnetissimo.Crawler.Leetx do
  @moduledoc """
  Torrent parser for Leetx in charge of scraping and saving
  the latest torrents on the website.
  """

  @behaviour Magnetissimo.WebParser
  use GenServer
  require Logger

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
    urls = for category <- categories do
      {:page_link, "https://1337x.to/cat/#{category}/1/"}
    end
    :queue.from_list(urls)
  end

  def start_link do
    queue = initial_queue()
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    schedule_work()
    {:ok, queue}
  end

  defp schedule_work do
    wait_seconds = :rand.uniform(8) * 1000
    Process.send_after(self(), :work, wait_seconds)
  end

  def handle_info(:work, queue) do
    new_queue =
      case :queue.out(queue) do
        {{_value, item}, queue_2} ->
          process(item, queue_2)
        _ ->
          Logger.info "[Leetx] Queue is empty, restarting scraping procedure."
          initial_queue()
      end
    schedule_work()
    {:noreply, new_queue}
  end

  def process({:page_link, url}, queue) do
    Logger.info "[Leetx] Finding torrents in listing page: #{url}"
    result = Magnetissimo.Crawler.Helper.download(url) |> torrent_links
    case result do
      {:error, message} ->
        Logger.error message
        queue
      torrents ->
        Enum.reduce(torrents, queue, fn torrent, queue ->
          :queue.in({:torrent_link, torrent}, queue)
        end)
    end
  end

  def process({:torrent_link, url}, queue) do
    Logger.info "[Leetx] Downloading torrent from page: #{url}"
    result = Magnetissimo.Crawler.Helper.download(url) |> torrent_information
    case result do
      {:error, message} -> 
        Logger.error message
      torrent_struct -> 
        torrent_struct = Map.put(torrent_struct, :outbound_url, url)
        Magnetissimo.Torrent.save_torrent(torrent_struct)
    end
    queue
  end

  def torrent_links(html_body) when is_binary(html_body) and byte_size(html_body) > 50 do
    html_body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/torrent/") end)
    |> Enum.map(fn(url) -> "https://1337x.to" <> url end)
  end

  def torrent_links(_html_body) do
    {:error, "Couldn't parse torrents links."}
  end

  def torrent_information(html_body) when is_binary(html_body) and byte_size(html_body) > 50 do
    name = html_body
      |> Floki.find("title")
      |> Floki.text
      |> String.replace("Download Torrent ", "")
      |> String.replace("| 1337x", "")
      |> String.replace("Download ", "")
      |> String.trim

    name =
      if String.ends_with?(name, " Torrent") do
        String.replace(name, " Torrent", "")
      end

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
    size = Magnetissimo.Crawler.Helper.size_to_bytes(size_value, unit) |> Kernel.to_string

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

    %{
      name: name,
      magnet: magnet,
      size: size,
      website_source: "1337x",
      seeders: seeders,
      leechers: leechers
    }
  end

  def torrent_information(_html_body) do
    {:error, "Couldn't parse torrent information"}
  end
end
