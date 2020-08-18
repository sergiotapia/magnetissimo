defmodule Magnetissimo.Crawlers.Nyaa do
  use GenServer
  import SweetXml
  require Logger
  alias Magnetissimo.{Torrent, Crawler, Parser}

  @site_name "Nyaa"
  @site_display_name @site_name
  @site_url "https://nyaa.si/?page=rss"
  @period 15 * 60 * 1000

  @xml_map [
    ~x"//channel/item"l,
    name: ~x"./title/text()",
    canonical_url: ~x"./guid/text()",
    published_at: ~x"./pubDate/text()",
    seeds: ~x"./nyaa:seeders/text()",
    leechers: ~x"./nyaa:leechers/text()",
    magnet_hash: ~x"./nyaa:infoHash/text()",
    size: ~x"./nyaa:size/text()"
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :rss_fetch, 60 * 1000)
    {:ok, state}
  end

  def handle_info(:rss_fetch, state) do
    case Crawler.get_torrents_from_feed(@site_url, @xml_map) do
      {:ok, torrents} -> save_torrents(torrents)
      _ -> Logger.warn("[#{@site_name}] There was a problem getting the feed: #{@site_url}")
    end

    schedule_rss_fetch()
    {:noreply, state}
  end

  defp save_torrents(data) when is_list(data) do
    Logger.debug("[#{@site_name}] Saving torrents.")
    Enum.each(data, fn torrent_data -> save_torrents(torrent_data) end)
  end
  defp save_torrents(data) when is_map(data) do
    name = List.to_string(data.name)

    magnet_hash = Parser.magnet_hash(data.magnet_hash)
    magnet_url = "magnet:?xt=urn:btih:#{magnet_hash}&dn=#{String.replace(name, " ", "+")}&tr=udp%3A%2F%2Ftracker.open-internet.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.pirateparty.gr%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.si%3A1337%2Fannounce&tr=udp%3A%2F%2Fdenis.stalker.upeer.me%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.port443.xyz%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2720%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Feddie4.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce"

    [size, units] = List.to_string(data.size) |> String.split()

    Torrent.changeset(%Torrent{}, %{
      name: name,
      canonical_url: List.to_string(data.canonical_url),
      magnet_url: magnet_url,
      leechers: Parser.integer(data.leechers),
      seeds: Parser.integer(data.seeds),
      website_source: @site_display_name,
      published_at: Parser.pubdate(data.published_at, "{RFC1123}"),
      size: Parser.bytes(size, units),
      magnet_hash: magnet_hash
    }) |> Torrent.save
  end
  defp save_torrents(_data) do :ok end

  defp schedule_rss_fetch do
    Process.send_after(self(), :rss_fetch, @period)
  end
end
