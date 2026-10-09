defmodule Magnetissimo.Crawlers.Sukebei do
  @moduledoc """
  Crawls sukebei.nyaa.si, the non-work-safe Nyaa, through its RSS feed.
  """

  use Magnetissimo.Crawlers.Nyaa.Site,
    source: "Sukebei",
    rss_url: "https://sukebei.nyaa.si/?page=rss",
    tracker: "http://sukebei.tracker.wf:8888/announce"
end
