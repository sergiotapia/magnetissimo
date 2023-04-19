defmodule Magnetissimo.DbSeeder do
  require Logger

  alias Magnetissimo.Torrents
  alias Magnetissimo.Torrents.Source
  alias Magnetissimo.Torrents.Category

  def run(repo) do
    existing_sources = repo.all(Magnetissimo.Torrents.Source)

    Logger.info("#{Enum.count(existing_sources)} sources found in database.}")

    if Enum.empty?(existing_sources) do
      Logger.info("Initializing necessary database records.")

      source = repo.insert!(%Source{name: "Nyaa.si", url: "https://nyaa.si"})

      repo.insert!(%Source{name: "TorrentDownloads", url: "https://torrentdownloads.pro"})
      repo.insert!(%Source{name: "YTS", url: "https://yts.mx/"})
      repo.insert!(%Source{name: "1337x", url: "https://www.1337x.to"})

      anime_category = repo.insert!(%Category{name: "Anime"})

      repo.insert!(%Category{
        parent_id: anime_category.id,
        name: "Anime - Music Video",
        alternative_names: ["Anime - Anime Music Video"],
        newznab_category_id: "5070"
      })

      repo.insert!(%Category{
        parent_id: anime_category.id,
        name: "Anime - English-translated",
        alternative_names: ["Anime"],
        newznab_category_id: "5070"
      })

      repo.insert!(%Category{
        parent_id: anime_category.id,
        name: "Anime - Non-English translated",
        alternative_names: ["Anime - Non-English-translated"],
        newznab_category_id: "5070"
      })

      repo.insert!(%Category{
        parent_id: anime_category.id,
        name: "Anime - Raw",
        newznab_category_id: "5070"
      })

      audio_category = repo.insert!(%Category{name: "Audio"})

      repo.insert!(%Category{
        parent_id: audio_category.id,
        name: "Audio - Lossless",
        newznab_category_id: "3000"
      })

      repo.insert!(%Category{
        parent_id: audio_category.id,
        name: "Audio - Lossy",
        alternative_names: ["Music"],
        newznab_category_id: "3000"
      })

      books_category = repo.insert!(%Category{name: "Books"})

      repo.insert!(%Category{
        parent_id: books_category.id,
        name: "Books - English-translated",
        alternative_names: [
          "Literature - English-translated",
          "Books",
          "Ebooks",
          "e-books",
          "ebook"
        ],
        newznab_category_id: "7000"
      })

      repo.insert!(%Category{
        parent_id: books_category.id,
        name: "Books - Non-English translated",
        alternative_names: ["Literature - Non-English-translated"],
        newznab_category_id: "7000"
      })

      repo.insert!(%Category{
        parent_id: books_category.id,
        name: "Books - Raw",
        alternative_names: ["Literature - Raw"],
        newznab_category_id: "7000"
      })

      video_category = repo.insert!(%Category{name: "Video"})

      repo.insert!(%Category{
        parent_id: video_category.id,
        name: "Video - Movies",
        alternative_names: [
          "Live Action - Raw",
          "Live Action - English-translated",
          "Live Action - Idol/Promotional Video",
          "Live Action - Non-English-translated",
          "Movies"
        ],
        newznab_category_id: "2040,2045,2050,2060"
      })

      repo.insert!(%Category{
        parent_id: video_category.id,
        name: "Video - Television",
        alternative_names: ["TV Shows", "TV", "television", "Television", "TV - Other"],
        newznab_category_id: "5000,5020,5030,5040,5045,5050,5060"
      })

      repo.insert!(%Category{
        parent_id: video_category.id,
        name: "Video - Documentaries",
        alternative_names: ["Documentaries", "Documentary"],
        newznab_category_id: "5080"
      })

      repo.insert!(%Category{
        parent_id: video_category.id,
        name: "Video - XXX",
        alternative_names: ["XXX"],
        newznab_category_id: "6000,6010,6020,6030,6040,6050,6070"
      })

      images_category = repo.insert!(%Category{name: "Images"})

      repo.insert!(%Category{
        parent_id: images_category.id,
        name: "Images - Graphics",
        alternative_names: ["Pictures - Graphics"],
        newznab_category_id: "8000"
      })

      repo.insert!(%Category{
        parent_id: images_category.id,
        name: "Images - Photos",
        alternative_names: ["Pictures - Photos"],
        newznab_category_id: "8000"
      })

      software_category = repo.insert!(%Category{name: "Software"})

      repo.insert!(%Category{
        parent_id: software_category.id,
        name: "Software - Applications",
        alternative_names: [
          "Software",
          "Mac",
          "Linux",
          "Windows",
          "Apps",
          "Apple",
          "Other operating systems"
        ],
        newznab_category_id: "4000,4010,4020,2030,4040,4050,4060,4070"
      })

      repo.insert!(%Category{
        parent_id: software_category.id,
        name: "Software - Games",
        alternative_names: ["Games"],
        newznab_category_id: "4000,4010,4020,2030,4040,4050,4060,4070"
      })

      other_category = repo.insert!(%Category{name: "Other", newznab_category_id: "8000"})

      {:ok, _} =
        Torrents.create_torrent(%{
          name: "Hanma Baki - Son of Ogre - 01 ~ 12 [720p]",
          description: "Some description foobarbaz",
          canonical_url: "https://nyaa.si/view/1559131",
          leechers: 1,
          seeders: 10,
          magnet_url:
            "?xt=urn:btih:f768429614b2f113be9057de4790aa9384ac9233&dn=%5BErai-raws%5D%20Hanma%20Baki%20-%20Son%20of%20Ogre%20-%2001%20~%2012%20%5B720p%5D%5BMultiple%20Subtitle%5D%20%5BUS%5D%5BBR%5D%5BMX%5D%5BES%5D%5BSA%5D%5BFR%5D%5BDE%5D%5BIT%5D%5BRU%5D%5BJP%5D%5BPT%5D%5BPL%5D%5BNL%5D%5BNO%5D%5BFI%5D%5BTR%5D%5BSE%5D%5BGR%5D%5BIL%5D%5BRO%5D%5BID%5D%5BTH%5D%5BKR%5D%5BDK%5D%5BCN%5D%5BCN%5D%5BVN%5D%5BUA%5D%5BHU%5D%5BCZ%5D%5BHR%5D%5BMY%5D&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce",
          magnet_hash: "f768429614b2f113be9057de4790aa9384ac9233",
          published_at: DateTime.utc_now(),
          size_in_bytes: 123,
          category_id: other_category.id,
          source_id: source.id
        })
    else
      Logger.info("Database is already initialized with necessary data.")
    end
  end
end
