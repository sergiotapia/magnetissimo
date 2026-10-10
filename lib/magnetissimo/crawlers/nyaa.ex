defmodule Magnetissimo.Crawlers.Nyaa do
  @moduledoc """
  Crawls nyaa.si, the work-safe Nyaa, through its RSS feed.

  The category mapping starts from Prowlarr's `nyaasi` definition and is
  finer where Nyaa says more: lossless against lossy audio, and which books
  and live action are not in English.
  """

  use Magnetissimo.Crawlers.Nyaa.Site,
    source: "Nyaa.si",
    rss_url: "https://nyaa.si/?page=rss",
    tracker: "http://nyaa.tracker.wf:7777/announce",
    fallback: "Other",
    categories: %{
      # Anime, in whatever language. Torznab files all anime under TV, which
      # is also where Sonarr looks for it.
      "1_0" => "TV/Anime",
      "1_1" => "TV/Anime",
      "1_2" => "TV/Anime",
      "1_3" => "TV/Anime",
      "1_4" => "TV/Anime",
      "2_0" => "Audio",
      "2_1" => "Audio/Lossless",
      "2_2" => "Audio/MP3",
      # Literature: manga and light novels, in English, another language, or
      # untranslated.
      "3_0" => "Books",
      "3_1" => "Books",
      "3_2" => "Books/Foreign",
      "3_3" => "Books/Foreign",
      # Live action is East Asian drama and film, foreign-language even when
      # subtitled in English. Idol and promotional videos are neither shows
      # nor films.
      "4_0" => "TV/Foreign",
      "4_1" => "TV/Foreign",
      "4_2" => "TV/Other",
      "4_3" => "TV/Foreign",
      "4_4" => "TV/Foreign",
      # Pictures: artwork and photos. Torznab has no work-safe image category.
      "5_0" => "Other/Misc",
      "5_1" => "Other/Misc",
      "5_2" => "Other/Misc",
      "6_0" => "PC",
      "6_1" => "PC",
      "6_2" => "PC/Games"
    }
end
