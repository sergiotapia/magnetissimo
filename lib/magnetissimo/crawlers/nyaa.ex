defmodule Magnetissimo.Crawlers.Nyaa do
  @moduledoc """
  Crawls nyaa.si, the work-safe Nyaa, through its RSS feed.
  """

  alias Magnetissimo.Crawlers.Nyaa.Feed

  @site [
    source: "Nyaa.si",
    rss_url: "https://nyaa.si/?page=rss",
    tracker: "http://nyaa.tracker.wf:7777/announce"
  ]

  @doc "Fetches the newest items and indexes them."
  @spec crawl_latest() :: :ok
  def crawl_latest, do: Feed.crawl_latest(@site)
end
