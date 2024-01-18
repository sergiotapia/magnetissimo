defmodule Magnetissimo.Crawlers.Yts do
  require Logger

  alias Magnetissimo.Torrents

  @doc """
  Fetches the latest torrents from the list_movies.json endpoint.
  """
  def crawl_latest() do
    Logger.info("[YTS] Importing latest torrents.")

    json = Req.get!("https://yts.mx/api/v2/list_movies.json").body

    json["data"]["movies"]
    |> Enum.each(fn torrent_json ->
      ingest_torrent_json(torrent_json)
    end)
  end

  @doc """
  Performs a search on YTS and ingests the first 50 results
  to the database.
  """
  def search(search_term) do
    Logger.info("[YTS] Searching for: #{search_term}")

    search_term = URI.encode(search_term)

    json =
      Req.get!("https://yts.mx/api/v2/list_movies.json?query_term=#{search_term}&limit=50").body

    json["data"]["movies"]
    |> Enum.each(fn torrent_json ->
      ingest_torrent_json(torrent_json)
    end)
  end

  defp ingest_torrent_json(torrent_json) do
    category = Torrents.get_category_by_name_or_alias!("Movies")
    source = Torrents.get_source_by_name!("YTS")

    # YTS groups torrents by quality per movie. Each movie
    # typically has 2-4 torrents for different qualities.
    torrent_json["torrents"]
    |> Enum.map(fn quality_json ->
      name =
        "#{torrent_json["title_long"]} #{quality_json["video_codec"]} #{quality_json["quality"]}"

      magnet_hash = quality_json["hash"]

      magnet_url =
        "?xt=urn:btih:#{magnet_hash}&dn=#{name}&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Fopen.tracker.cl%3A1337%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2970%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Fipv4.tracker.harry.lu%3A80%2Fannounce&tr=https%3A%2F%2Fopentracker.i2p.rocks%3A443%2Fannounce"

      published_at =
        quality_json["date_uploaded_unix"]
        |> DateTime.from_unix!()

      %{
        canonical_url: torrent_json["url"],
        leechers: quality_json["peers"],
        seeders: quality_json["seeds"],
        magnet_url: magnet_url,
        magnet_hash: magnet_hash,
        name: name,
        published_at: published_at,
        size_in_bytes: quality_json["size_bytes"],
        description: torrent_json["description_full"],
        category_id: category.id,
        source_id: source.id
      }
      |> Torrents.create_torrent()
    end)
  end
end
