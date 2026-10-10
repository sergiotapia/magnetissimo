defmodule Magnetissimo.Crawlers do
  @moduledoc """
  Runs crawlers and indexes what they return.

  Every crawler implements `Magnetissimo.Crawlers.Crawler`: it fetches and
  parses, and this module writes. Both entry points never raise on a site
  being down or answering badly, because the scheduler and the source search
  that call them would otherwise turn an outage into a crash loop.
  """

  require Logger

  alias Magnetissimo.Crawlers.Nyaa
  alias Magnetissimo.Crawlers.Sukebei
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.Torrents

  @crawlers [Yts, Nyaa, Sukebei, TorrentDownloads]

  @doc "Every crawler, one per live source."
  @spec all() :: [module()]
  def all, do: @crawlers

  @doc """
  Fetches the newest torrents from `crawler`'s site and indexes them.

  A crawl the site answered is recorded as the source's last crawl, even when
  it brought nothing new. A failed one is not, so a source that keeps failing
  shows its last crawl getting older.
  """
  @spec crawl_latest(module()) :: :ok
  def crawl_latest(crawler) do
    source = crawler.source_name()

    case crawler.latest() do
      {:ok, attrs} ->
        %{inserted: inserted, ids: ids} = index(source, attrs)
        :ok = Torrents.mark_source_crawled(source)

        Logger.info(
          "[#{source}] indexed #{inserted} new torrents, refreshed #{length(ids) - inserted}"
        )

      {:error, reason} ->
        Logger.error("[#{source}] crawl failed: #{inspect(reason)}")
    end
  end

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
        %{inserted: inserted, ids: ids} = index(source, attrs, search_term: term)

        Logger.info("[#{source}] search #{inspect(term)}: #{length(ids)} found, #{inserted} new")
        {:ok, %{inserted: inserted, found: length(ids)}}

      {:error, reason} = error ->
        Logger.error("[#{source}] search #{inspect(term)} failed: #{inspect(reason)}")
        error
    end
  end

  defp index(source, attrs, opts \\ []) do
    result = Torrents.index_torrents(attrs, opts)

    # Attrs that fail validation mean the crawler is building them wrong, and
    # the torrent is being dropped silently unless it is logged.
    for {attrs, errors} <- result.rejected do
      Logger.warning("[#{source}] skipped #{inspect(attrs[:name])}: #{inspect(errors)}")
    end

    result
  end
end
