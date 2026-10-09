defmodule Magnetissimo.Crawlers.Nyaa do
  @moduledoc """
  Crawls nyaa.si, the work-safe Nyaa, through its RSS feed.
  """

  use Magnetissimo.Crawlers.Nyaa.Site,
    source: "Nyaa.si",
    rss_url: "https://nyaa.si/?page=rss",
    tracker: "http://nyaa.tracker.wf:7777/announce"
end
