defmodule Magnetissimo.Crawlers.Sukebei do
  @moduledoc """
  Crawls sukebei.nyaa.si, the non-work-safe Nyaa, through its RSS feed.

  Same feed shape as `Magnetissimo.Crawlers.Nyaa`; only the host, the tracker
  and the source row differ.
  """

  alias Magnetissimo.Crawlers.Nyaa.Feed

  @site [
    source: "Sukebei",
    rss_url: "https://sukebei.nyaa.si/?page=rss",
    tracker: "http://sukebei.tracker.wf:8888/announce"
  ]

  @doc "Fetches the newest items and indexes them."
  @spec crawl_latest() :: :ok
  def crawl_latest, do: Feed.crawl_latest(@site)
end
