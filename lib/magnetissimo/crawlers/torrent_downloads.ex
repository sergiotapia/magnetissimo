defmodule Magnetissimo.Crawlers.TorrentDownloads do
  import SweetXml
  require Logger

  alias Magnetissimo.Torrents

  def crawl_latest() do
    Logger.info("[TorrentDownloads] Crawling latest torrents.")

    %{torrents: torrents} =
      get_rss()
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./link/text()",
          published_at: ~x"./pubDate/text()",
          magnet_url: ~x"./info_hash/text()",
          seeders: ~x"./seeders/text()",
          leechers: ~x"./leechers/text()",
          category: ~x"./category/text()",
          size: ~x"./size/text()"
        ]
      )

    source = Torrents.get_source_by_name!("TorrentDownloads")

    torrents
    |> Enum.each(fn torrent ->
      category = torrent.category |> List.to_string() |> Torrents.get_category_by_name_or_alias!()
      magnet_hash = torrent.magnet_url |> List.to_string()
      magnet_name = torrent.name |> List.to_string() |> String.replace(" ", "+")

      magnet_url =
        "magnet:?xt=urn:btih:#{magnet_hash}&dn=#{magnet_name}&tr=udp%3A%2F%2Ftracker.open-internet.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.pirateparty.gr%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.si%3A1337%2Fannounce&tr=udp%3A%2F%2Fdenis.stalker.upeer.me%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.port443.xyz%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2720%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2770%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2740%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Feddie4.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce"

      torrent = %{
        canonical_url: "https://torrentdownloads.pro#{torrent.canonical_url |> List.to_string()}",
        leechers: torrent.leechers |> List.to_string() |> Integer.parse() |> elem(0),
        magnet_url: magnet_url,
        name: torrent.name |> List.to_string(),
        published_at: torrent.published_at |> List.to_string() |> parse_published_at(),
        seeders: torrent.seeders |> List.to_string() |> Integer.parse() |> elem(0),
        size_in_bytes: torrent.size |> List.to_string() |> Integer.parse() |> elem(0),
        category_id: category.id,
        source_id: source.id
      }

      case Torrents.create_torrent(torrent) do
        {:ok, torrent} ->
          Logger.info(
            "[TorrentDownloads] Creating torrent: #{torrent.name} (#{torrent.canonical_url})"
          )

        {:error, changeset} ->
          Logger.error(
            "[TorrentDownloads] Skipped creating torrent: #{torrent.name} (#{torrent.canonical_url}) - reason: #{inspect(changeset.errors)}"
          )
      end
    end)
  end

  @spec parse_published_at(String.t()) :: DateTime.t()
  def parse_published_at(published_at) do
    {:ok, parsed_datetime} = Timex.parse(published_at, "{RFC1123}")
    Timex.to_datetime(parsed_datetime, "Etc/UTC")
  end

  @spec get_rss :: binary()
  def get_rss do
    Logger.info("[TorrentDownloads] Fetching RSS feed.")

    %{status_code: 200, body: body} =
      "https://www.torrentdownloads.pro/rss.xml?type=today"
      |> HTTPoison.get!()

    body
  end
end
