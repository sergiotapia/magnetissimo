defmodule Magnetissimo.Crawlers.Magnet do
  @moduledoc """
  Builds a magnet URI for a source that hands back only an infohash.

  The YTS API and the TorrentDownloads feed both publish the infohash and no
  tracker at all, so a client has no tracker to announce to without this public
  list attached. Nyaa is not a caller: its feed carries the site's own tracker,
  which is prepended to its own shorter list in that crawler.
  """

  @trackers [
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://open.tracker.cl:1337/announce",
    "udp://9.rarbg.me:2970/announce",
    "udp://p4p.arenabg.com:1337/announce",
    "udp://tracker.torrent.eu.org:451/announce",
    "udp://tracker.dler.org:6969/announce",
    "udp://open.stealth.si:80/announce",
    "udp://ipv4.tracker.harry.lu:80/announce",
    "https://opentracker.i2p.rocks:443/announce"
  ]

  @doc "Returns a complete magnet URI, name and public trackers included."
  @spec url(String.t(), String.t()) :: String.t()
  def url(hash, name) do
    trackers = Enum.map_join(@trackers, "&tr=", &URI.encode_www_form/1)

    "magnet:?xt=urn:btih:#{hash}&dn=#{URI.encode_www_form(name)}&tr=#{trackers}"
  end
end
