# Populates the crawl sources, the canonical category tree, and — in
# development only — a set of demo torrents, so a fresh database has something
# to list and search before any crawler exists.
#
#     mix run priv/repo/seeds.exs
#
# Safe to run repeatedly. See Magnetissimo.Seeds for the sources and categories.
alias Magnetissimo.Repo
alias Magnetissimo.Torrents
alias Magnetissimo.Torrents.Category
alias Magnetissimo.Torrents.Source
alias Magnetissimo.Torrents.Torrent

Magnetissimo.Seeds.run()

# Fixture data, not knowledge: the taxonomy is what a crawler needs to file
# anything, these rows only exist to give the UI something real to render.
# {name, category name, source name, size_in_bytes, seeders, leechers, hours_since_published}
demo_torrents = [
  {"[SubsPlease] Frieren - 28 (1080p) [F5A2B1C3]", "Anime - English-translated", "Nyaa.si",
   1_400_000_000, 812, 34, 2},
  {"[SubsPlease] Jujutsu Kaisen - 47 (1080p) [A1B2C3D4]", "Anime - English-translated", "Nyaa.si",
   1_350_000_000, 654, 21, 3},
  {"[Erai-raws] Hanma Baki - Son of Ogre 01-12 [720p]", "Anime - English-translated", "Nyaa.si",
   4_100_000_000, 210, 12, 26},
  {"[Erai-raws] Spy x Family - 25 [1080p] [Multi-Sub]", "Anime - Non-English translated",
   "Nyaa.si", 1_400_000_000, 143, 9, 30},
  {"[HorribleSubs] One Piece - 1090 [1080p]", "Anime - English-translated", "Nyaa.si",
   1_450_000_000, 1_204, 88, 5},
  {"[Moozzi2] Mob Psycho 100 S03 (BD 1920x1080 x265)", "Anime - Raw", "Nyaa.si", 12_800_000_000,
   96, 4, 52},
  {"[Nekomoe kissaten] Chainsaw Man - 12 [JPTC]", "Anime - Non-English translated", "Nyaa.si",
   1_100_000_000, 77, 3, 74},
  {"Kessoku Band - Seishun Complex (Music Video) [1080p]", "Anime - Music Video", "Nyaa.si",
   220_000_000, 44, 1, 96},
  {"Oppenheimer (2023) [2160p] [WEB-DL] [x265] [10bit]", "Video - Movies", "YTS", 18_400_000_000,
   3_412, 210, 1},
  {"Dune Part Two (2024) 1080p BluRay x264 DTS", "Video - Movies", "YTS", 14_200_000_000, 2_876,
   143, 4},
  {"Everything Everywhere All at Once (2022) [1080p]", "Video - Movies", "TorrentDownloads",
   2_100_000_000, 1_098, 72, 9},
  {"Spirited Away (2001) [1080p] [Dual Audio]", "Video - Movies", "1337x", 3_300_000_000, 934, 55,
   14},
  {"The Grand Budapest Hotel (2014) 720p BRRip", "Video - Movies", "TorrentDownloads",
   900_000_000, 421, 19, 21},
  {"Blade Runner 2049 (2017) [2160p] [HDR] [x265]", "Video - Movies", "YTS", 21_000_000_000,
   1_765, 98, 36},
  {"Parasite (2019) [1080p] [BluRay] [5.1] [YTS.MX]", "Video - Movies", "YTS", 2_400_000_000,
   1_320, 61, 44},
  {"The Bear S03 COMPLETE 1080p WEB-DL x265", "Video - Television", "1337x", 22_500_000_000,
   2_233, 154, 2},
  {"Severance S02E01 1080p AMZN WEB-DL DDP5.1", "Video - Television", "TorrentDownloads",
   3_100_000_000, 1_876, 89, 6},
  {"Shogun S01E10 2160p DSNP WEB-DL DDP5.1 DV HDR", "Video - Television", "TorrentDownloads",
   8_900_000_000, 1_543, 67, 11},
  {"Silicon Valley S01-S06 Complete 1080p BluRay", "Video - Television", "1337x", 48_000_000_000,
   654, 31, 29},
  {"Planet Earth III S01 COMPLETE 2160p UHD BluRay", "Video - Documentaries", "1337x",
   62_000_000_000, 512, 22, 8},
  {"Cosmos A Spacetime Odyssey (2014) 1080p BluRay", "Video - Documentaries", "TorrentDownloads",
   16_800_000_000, 288, 14, 40},
  {"Free Solo (2018) [1080p] [WEBRip] [YTS.MX]", "Video - Documentaries", "YTS", 2_000_000_000,
   197, 8, 63},
  {"Pink Floyd - The Dark Side of the Moon [FLAC 24bit]", "Audio - Lossless", "1337x",
   1_200_000_000, 776, 12, 3},
  {"Radiohead - In Rainbows (2007) [FLAC] [Lossless]", "Audio - Lossless", "1337x", 780_000_000,
   433, 7, 18},
  {"Kendrick Lamar - GNX (2024) [MP3 320]", "Audio - Lossy", "TorrentDownloads", 130_000_000,
   1_204, 44, 1},
  {"Daft Punk - Discovery (2001) [FLAC]", "Audio - Lossless", "1337x", 620_000_000, 388, 5, 27},
  {"Various Artists - Hotline Miami OST [FLAC]", "Audio - Lossy", "TorrentDownloads", 540_000_000,
   155, 3, 58},
  {"Brandon Sanderson - The Way of Kings [EPUB] [MOBI]", "Books - English-translated",
   "TorrentDownloads", 24_000_000, 312, 4, 7},
  {"Project Hail Mary - Andy Weir [EPUB]", "Books - English-translated", "1337x", 3_500_000, 507,
   2, 13},
  {"Dune (Complete Saga) - Frank Herbert [Audiobook]", "Books - English-translated",
   "TorrentDownloads", 3_100_000_000, 265, 11, 22},
  {"Tolkien - The Lord of the Rings Illustrated [PDF]", "Books - English-translated", "1337x",
   480_000_000, 190, 6, 34},
  {"Clean Code - Robert C. Martin [PDF] [EPUB]", "Books - English-translated", "TorrentDownloads",
   40_000_000, 233, 3, 49},
  {"SICP - Structure and Interpretation of Programs [PDF]", "Books - Raw", "1337x", 18_000_000,
   88, 1, 71},
  {"Proxmox VE 8.2 ISO", "Software - Applications", "1337x", 1_300_000_000, 148, 2, 5},
  {"Blender 4.2 LTS (Windows / macOS / Linux)", "Software - Applications", "TorrentDownloads",
   400_000_000, 96, 1, 16},
  {"Arch Linux 2024.11.01 x86_64 ISO", "Software - Applications", "1337x", 1_150_000_000, 402, 9,
   25},
  {"Microsoft Office 2021 Pro Plus x64 (Activated)", "Software - Applications",
   "TorrentDownloads", 4_600_000_000, 1_015, 120, 38},
  {"Ableton Live 12 Suite (macOS) [AU/VST3]", "Software - Applications", "1337x", 3_800_000_000,
   321, 17, 55},
  {"Baldurs Gate 3 v4.1.1 [FitGirl Repack]", "Software - Games", "1337x", 62_000_000_000, 5_120,
   340, 1},
  {"Elden Ring Shadow of the Erdtree [DODI Repack]", "Software - Games", "1337x", 48_000_000_000,
   3_654, 201, 10},
  {"Stardew Valley 1.6.9 (GOG)", "Software - Games", "TorrentDownloads", 620_000_000, 1_233, 42,
   19},
  {"Hollow Knight Silksong [GOG] [Linux Native]", "Software - Games", "1337x", 1_900_000_000, 887,
   33, 41},
  {"Factorio Space Age (v2.0.11) + Crack", "Software - Games", "TorrentDownloads", 2_400_000_000,
   706, 28, 60},
  {"NASA Blue Marble Ultra High Resolution Wallpapers", "Images - Photos", "TorrentDownloads",
   2_700_000_000, 74, 1, 12},
  {"Unsplash Complete Photo Collection 2024 [HQ]", "Images - Photos", "1337x", 34_000_000_000, 55,
   2, 32},
  {"Design Assets Mega Pack - Icons, Mockups, Fonts", "Images - Graphics", "TorrentDownloads",
   8_100_000_000, 129, 5, 47},
  {"Ubuntu 24.04.1 LTS Desktop amd64 ISO", "Other", "TorrentDownloads", 5_800_000_000, 912, 14,
   15},
  {"Raspberry Pi OS Bookworm (2024-11-19) [All models]", "Other", "1337x", 2_200_000_000, 187, 4,
   66}
]

# Only in development, and only into an empty table: a real index must never
# get these rows, and once a crawler has written anything the demo set is no
# longer wanted. That also makes a second run a no-op.
if Mix.env() == :dev and Repo.aggregate(Torrent, :count) == 0 do
  now = DateTime.utc_now()

  for {name, category_name, source_name, size, seeders, leechers, hours_ago} <- demo_torrents do
    # SHA-1 is a stable 40-character lowercase hex string, which is exactly what
    # the torrent schema demands of `magnet_hash`.
    magnet_hash = :crypto.hash(:sha, name) |> Base.encode16(case: :lower)
    category = Repo.get_by!(Category, name: category_name)
    source = Repo.get_by!(Source, name: source_name)

    attrs = %{
      name: name,
      description: "#{name} - seeded demo torrent for local development.",
      canonical_url: "#{String.trim_trailing(source.url, "/")}/view/#{magnet_hash}",
      leechers: leechers,
      seeders: seeders,
      magnet_url: "magnet:?xt=urn:btih:#{magnet_hash}&dn=#{URI.encode_www_form(name)}",
      magnet_hash: magnet_hash,
      published_at: DateTime.add(now, -hours_ago, :hour),
      size_in_bytes: size,
      category_id: category.id,
      source_id: source.id
    }

    {:ok, _torrent} = Torrents.create_torrent(attrs)
  end
end
