# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Magnetissimo.Repo.insert!(%Magnetissimo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Magnetissimo.Torrents

{:ok, source} =
  Torrents.create_source(%{
    name: "Nyaa.si",
    url: "https://nyaa.si/"
  })

{:ok, category} =
  Torrents.create_category(%{
    name: "Anime"
  })

Torrents.create_torrent(%{
  name: "Hanma Baki - Son of Ogre - 01 ~ 12 [720p]",
  description: "Some description foobarbaz",
  canonical_url: "https://nyaa.si/view/1559131",
  leechers: 1,
  seeders: 10,
  magnet_url:
    "magnet:?xt=urn:btih:f768429614b2f113be9057de4790aa9384ac9233&dn=%5BErai-raws%5D%20Hanma%20Baki%20-%20Son%20of%20Ogre%20-%2001%20~%2012%20%5B720p%5D%5BMultiple%20Subtitle%5D%20%5BUS%5D%5BBR%5D%5BMX%5D%5BES%5D%5BSA%5D%5BFR%5D%5BDE%5D%5BIT%5D%5BRU%5D%5BJP%5D%5BPT%5D%5BPL%5D%5BNL%5D%5BNO%5D%5BFI%5D%5BTR%5D%5BSE%5D%5BGR%5D%5BIL%5D%5BRO%5D%5BID%5D%5BTH%5D%5BKR%5D%5BDK%5D%5BCN%5D%5BCN%5D%5BVN%5D%5BUA%5D%5BHU%5D%5BCZ%5D%5BHR%5D%5BMY%5D&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce",
  category_id: category.id,
  source_id: source.id
})
