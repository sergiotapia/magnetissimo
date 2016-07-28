defmodule Magnetissimo.Parser do
  @callback root_urls() :: [String.t]
  @callback download_url(String.t) :: String.t
  @callback paginated_links(String.t) :: [String.t]
  @callback torrent_links(String.t) :: [String.t]
  @callback scrape_torrent_information(String.t) :: Map
end
