defmodule Magnetissimo.Crawlers do
  @moduledoc """
  Runs crawlers and indexes what they return.

  Every crawler implements `Magnetissimo.Crawlers.Crawler`: it fetches and
  parses, and this module writes. `search/2` never raises on a site being
  down or answering badly; it says why, for `Magnetissimo.SourceSearch` to
  show.
  """

  require Logger

  alias Magnetissimo.Crawlers.AudioBookBay
  alias Magnetissimo.Crawlers.Eztv
  alias Magnetissimo.Crawlers.Nyaa
  alias Magnetissimo.Crawlers.OxTorrent
  alias Magnetissimo.Crawlers.Sukebei
  alias Magnetissimo.Crawlers.ThePirateBay
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.Torrents

  @crawlers [Yts, Nyaa, Sukebei, TorrentDownloads, AudioBookBay, ThePirateBay, Eztv, OxTorrent]

  @doc "Every crawler, one per live source."
  @spec all() :: [module()]
  def all, do: @crawlers

  @doc """
  Asks `crawler`'s site to search for `term`, indexes the hits and records
  them as matches for the term.

  Returns how many of the hits were new to the index and how many there were
  in all, or the reason the site could not be asked.
  """
  @spec search(module(), String.t()) ::
          {:ok, %{inserted: non_neg_integer(), found: non_neg_integer()}} | {:error, term()}
  def search(crawler, term) do
    source = crawler.source_name()

    case crawler.search(term) do
      {:ok, attrs} ->
        %{inserted: inserted, ids: ids} = index(source, attrs, term)

        Logger.info("[#{source}] search #{inspect(term)}: #{length(ids)} found, #{inserted} new")
        {:ok, %{inserted: inserted, found: length(ids)}}

      {:error, reason} = error ->
        Logger.error("[#{source}] search #{inspect(term)} failed: #{inspect(reason)}")
        error
    end
  end

  defp index(source, attrs, term) do
    result = Torrents.index_torrents(attrs, search_term: term)

    # Attrs that fail validation mean the crawler is building them wrong, and
    # the torrent is being dropped silently unless it is logged.
    for {attrs, errors} <- result.rejected do
      Logger.warning("[#{source}] skipped #{inspect(attrs[:name])}: #{inspect(errors)}")
    end

    result
  end
end
