defmodule Magnetissimo.Crawlers.TorrentDownloads do
  use GenServer
  import SweetXml
  require Logger
  alias Magnetissimo.{Repo, Torrent}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    schedule_rss_fetch()
    {:ok, state}
  end

  def handle_info(:rss_fetch, state) do
    rss_body = rss()

    %{torrents: torrents} =
      rss_body
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./link/text()",
          published_at: ~x"./pubDate/text()",
          magnet_url: ~x"./info_hash/text()",
          seeds: ~x"./seeders/text()",
          leechers: ~x"./leechers/text()"
        ]
      )

    Enum.each(torrents, fn torrent_data ->
      save_torrent(torrent_data)
    end)

    schedule_rss_fetch()
    {:noreply, state}
  end

  defp save_torrent(data) do
    {seeds, _} = List.to_string(data.seeds) |> Integer.parse()
    {leechers, _} = List.to_string(data.leechers) |> Integer.parse()
    name = List.to_string(data.name)
    parsed_magnet_name = String.replace(name, " ", "+")
    canonical_url = "https://torrentdownloads.me" <> List.to_string(data.canonical_url)
    magnet_hash = List.to_string(data.magnet_url)

    magnet_url =
      "magnet:?xt=urn:btih:#{magnet_hash}&dn=#{parsed_magnet_name}&tr=udp%3A%2F%2Ftracker.open-internet.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.pirateparty.gr%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.si%3A1337%2Fannounce&tr=udp%3A%2F%2Fdenis.stalker.upeer.me%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.port443.xyz%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2720%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Feddie4.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce"

    torrent =
      Torrent.changeset(%Torrent{}, %{
        name: name,
        canonical_url: canonical_url,
        magnet_url: magnet_url,
        leechers: leechers,
        seeds: seeds,
        website_source: "TorrentDownloads",
        size: 0
      })

    Repo.insert(torrent)
  end

  defp rss do
    Logger.debug(
      "[TorrentDownloads] Downloading url: https://www.torrentdownloads.me/rss.xml?type=today"
    )

    "https://www.torrentdownloads.me/rss.xml?type=today"
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  defp schedule_rss_fetch do
    Process.send_after(self(), :rss_fetch, 15_000)
  end
end
