defmodule Magnetissimo.Seeds do
  @moduledoc """
  The crawl sources: one row per site a crawler files torrents under.

  The categories are not seeded. They are the Torznab standard and live in
  code, in `Magnetissimo.Taxonomy`, and each crawler maps its own site's
  categories onto them.

  It lives in `lib/` so a release task can reach it too.
  """

  alias Magnetissimo.Repo
  alias Magnetissimo.Torrents.Source

  # Every source here has a crawler in Magnetissimo.Crawlers.all/0.
  @sources [
    # The crawler hardcodes the domain too; the site moves every so often.
    {"AudioBookBay", "https://audiobookbay.lu"},
    # The crawler asks the site's API, the only part not behind Cloudflare's
    # challenge, and finds shows through IMDb's title suggestions.
    {"EZTV", "https://eztvx.to"},
    {"Nyaa.si", "https://nyaa.si"},
    # The crawler hardcodes the domain too; the site moves every so often.
    {"OxTorrent", "https://ww1.oxtorrent.run"},
    {"Sukebei", "https://sukebei.nyaa.si"},
    # The crawler asks apibay.org, the API the site's own pages are built from.
    {"The Pirate Bay", "https://thepiratebay.org"},
    {"TorrentDownloads", "https://www.torrentdownloads.pro"},
    # The site moved off yts.mx; the crawler talks to movies-api.accel.li,
    # the API base URL the site itself advertises.
    {"YTS", "https://yts.gg/"}
  ]

  @doc """
  Inserts the sources, and refreshes the `url` of one that has moved. Safe to
  run repeatedly.
  """
  @spec run() :: :ok
  def run do
    Enum.each(@sources, fn {name, url} -> upsert_source(name, url) end)
  end

  defp upsert_source(name, url) do
    case Repo.get_by(Source, name: name) do
      nil -> Repo.insert!(Source.changeset(%Source{}, %{name: name, url: url}))
      source -> Repo.update!(Source.changeset(source, %{url: url}))
    end
  end
end
