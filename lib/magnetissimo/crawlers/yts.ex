defmodule Magnetissimo.Crawlers.Yts do
  import SweetXml
  require Logger

  alias Magnetissimo.Torrents
  alias Magnetissimo.Utils

  def search(search_term) do
    search_term = search_term |> String.replace(" ", "+")
    url = "https://yts.mx/api/v2/list_movies.json?query_term=#{search_term}&limit=50"
  end

  def crawl_latest() do
    Logger.info("[YTS] Crawling latest torrents.")
    url = "https://yts.mx/api/v2/list_movies.json"

    # HIT THOSE TWO JSON ENDPOINTS and save data, you're done!

    # torrent = %{
    #   canonical_url: torrent.canonical_url |> List.to_string(),
    #   leechers: 0,
    #   seeders: 0,
    #   magnet_url: torrent.magnet_url |> List.to_string(),
    #   name: torrent.name |> List.to_string(),
    #   published_at: torrent.published_at |> List.to_string() |> parse_published_at(),
    #   size_in_bytes: torrent.description |> List.to_string() |> parse_size_string(),
    #   description: torrent.description |> List.to_string(),
    #   category_id: category.id,
    #   source_id: source.id
    # }

    # Torrents.create_torrent_for_source(torrent, source.name)
  end
end
