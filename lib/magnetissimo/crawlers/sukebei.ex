defmodule Magnetissimo.Crawlers.Sukebei do
  @moduledoc """
  Crawls sukebei.nyaa.si, the adult Nyaa, through its RSS feed.

  Everything on Sukebei is adult, so every id maps into XXX, and so does an
  id the mapping does not know: nothing from here may land next to
  work-safe torrents. Torznab's XXX children describe formats, so pictures,
  photobooks, doujinshi and manga (all scanned image sets) go to
  XXX/ImageSet, games to XXX/Other, and video, animated or not, to XXX.
  Prowlarr's `sukebeinyaasi` definition files all of it under plain XXX.

  Sukebei reuses Nyaa's ids for different things (`1_1` is AMV on Nyaa), so
  the two mappings are kept apart.
  """

  use Magnetissimo.Crawlers.Nyaa.Site,
    source: "Sukebei",
    rss_url: "https://sukebei.nyaa.si/?page=rss",
    tracker: "http://sukebei.tracker.wf:8888/announce",
    fallback: "XXX",
    categories: %{
      # Art
      "1_0" => "XXX",
      "1_1" => "XXX",
      "1_2" => "XXX/ImageSet",
      "1_3" => "XXX/Other",
      "1_4" => "XXX/ImageSet",
      "1_5" => "XXX/ImageSet",
      # Real Life
      "2_0" => "XXX",
      "2_1" => "XXX/ImageSet",
      "2_2" => "XXX"
    }
end
