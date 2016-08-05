defmodule Magnetissimo.Parsers.TorrentDownloads do
  @behaviour Magnetissimo.Parser

  def root_urls do
    [
      "https://www.torrentdownloads.me/category/8/TV+Shows",
      "https://www.torrentdownloads.me/category/419/Action",
      "https://www.torrentdownloads.me/category/29/Animation",
      "https://www.torrentdownloads.me/category/28/Adventure",
      "https://www.torrentdownloads.me/category/30/Asian",
      "https://www.torrentdownloads.me/category/32/Automotive/Cars",
      "https://www.torrentdownloads.me/category/33/Comedy",
      "https://www.torrentdownloads.me/category/34/Concerts",
      "https://www.torrentdownloads.me/category/35/Documentary",
      "https://www.torrentdownloads.me/category/37/Drama",
      "https://www.torrentdownloads.me/category/36/DVD+/+Film+Extras",
      "https://www.torrentdownloads.me/category/149/Family",
      "https://www.torrentdownloads.me/category/38/Fantasy",
      "https://www.torrentdownloads.me/category/39/Gore+Flicks",
      "https://www.torrentdownloads.me/category/40/Horror",
      "https://www.torrentdownloads.me/category/41/Kids",
      "https://www.torrentdownloads.me/category/150/KVCD",
      "https://www.torrentdownloads.me/category/42/Martial+Arts",
      "https://www.torrentdownloads.me/category/43/Mystery",
      "https://www.torrentdownloads.me/category/44/Movies+-+Other",
      "https://www.torrentdownloads.me/category/45/Romance",
      "https://www.torrentdownloads.me/category/46/Samples+/+Trailers",
      "https://www.torrentdownloads.me/category/47/Sci-Fi",
      "https://www.torrentdownloads.me/category/48/Sports+related",
      "https://www.torrentdownloads.me/category/49/Thriller",
      "https://www.torrentdownloads.me/category/307/War",
      "https://www.torrentdownloads.me/category/54/Alternative",
      "https://www.torrentdownloads.me/category/160/Anime",
      "https://www.torrentdownloads.me/category/55/Asian",
      "https://www.torrentdownloads.me/category/56/Blues",
      "https://www.torrentdownloads.me/category/57/Christian",
      "https://www.torrentdownloads.me/category/58/Classic",
      "https://www.torrentdownloads.me/category/515/Compilation+/+Various+Artists+%28VA%29",
      "https://www.torrentdownloads.me/category/59/Country+/+Western",
      "https://www.torrentdownloads.me/category/60/Drum+N+Bass",
      "https://www.torrentdownloads.me/category/61/Electronic",
      "https://www.torrentdownloads.me/category/519/Folk",
      "https://www.torrentdownloads.me/category/62/Game+Music",
      "https://www.torrentdownloads.me/category/233/Gothic",
      "https://www.torrentdownloads.me/category/63/Hardcore",
      "https://www.torrentdownloads.me/category/78/HardHouse/Old+School+Radio+Mixes",
      "https://www.torrentdownloads.me/category/306/Heavy/Death+Metal",
      "https://www.torrentdownloads.me/category/64/Hip+Hop",
      "https://www.torrentdownloads.me/category/511/Indie+/+Britpop",
      "https://www.torrentdownloads.me/category/65/Industrial",
      "https://www.torrentdownloads.me/category/66/Jazz",
      "https://www.torrentdownloads.me/category/67/Karaoke",
      "https://www.torrentdownloads.me/category/521/Latin",
      "https://www.torrentdownloads.me/category/68/Metal",
      "https://www.torrentdownloads.me/category/526/Motown",
      "https://www.torrentdownloads.me/category/522/Non-English",
      "https://www.torrentdownloads.me/category/507/Now+That%27s+What+I+Call+Music",
      "https://www.torrentdownloads.me/category/79/Music+-+Other",
      "https://www.torrentdownloads.me/category/70/Pop",
      "https://www.torrentdownloads.me/category/71/Punk",
      "https://www.torrentdownloads.me/category/72/R%26B",
      "https://www.torrentdownloads.me/category/73/Rap",
      "https://www.torrentdownloads.me/category/74/Reggae",
      "https://www.torrentdownloads.me/category/75/Rock",
      "https://www.torrentdownloads.me/category/527/Rock+%27n%27+Roll",
      "https://www.torrentdownloads.me/category/514/Singer+Songwriter",
      "https://www.torrentdownloads.me/category/230/Ska",
      "https://www.torrentdownloads.me/category/505/Soul",
      "https://www.torrentdownloads.me/category/77/Soundtracks",
      "https://www.torrentdownloads.me/category/420/Trance+/+House+/+Dance",
      "https://www.torrentdownloads.me/category/76/Unsigned/Amateur",
      "https://www.torrentdownloads.me/category/69/Music+Videos",
      "https://www.torrentdownloads.me/category/136/Game+fixes/patches",
      "https://www.torrentdownloads.me/category/26/Mac",
      "https://www.torrentdownloads.me/category/231/Mobile+phones",
      "https://www.torrentdownloads.me/category/11/PS+2",
      "https://www.torrentdownloads.me/category/12/PS+X",
      "https://www.torrentdownloads.me/category/158/PSP",
      "https://www.torrentdownloads.me/category/13/ROMS+/+Retro",
      "https://www.torrentdownloads.me/category/15/Sega+Saturn",
      "https://www.torrentdownloads.me/category/14/Video+Demonstrations",
      "https://www.torrentdownloads.me/category/10/Windows+-+Kids+Games",
      "https://www.torrentdownloads.me/category/16/XBox",
      "https://www.torrentdownloads.me/category/421/Windows",
      "https://www.torrentdownloads.me/category/422/Games+-+Other",
      "https://www.torrentdownloads.me/category/532/KeyGen+/+Tools",
      "https://www.torrentdownloads.me/category/17/Linux",
      "https://www.torrentdownloads.me/category/27/Mac",
      "https://www.torrentdownloads.me/category/232/Mobile+phones",
      "https://www.torrentdownloads.me/category/18/Other+operating+systems",
      "https://www.torrentdownloads.me/category/19/Palm%2C+PocketPC+%26+IPAQ",
      "https://www.torrentdownloads.me/category/20/Windows+-+CD/DVD+Tools",
      "https://www.torrentdownloads.me/category/25/Windows+-+Other",
      "https://www.torrentdownloads.me/category/21/Windows+-+Photo+Editing",
      "https://www.torrentdownloads.me/category/22/Windows+-+Security",
      "https://www.torrentdownloads.me/category/23/Windows+-+Sound+Editing",
      "https://www.torrentdownloads.me/category/24/Windows+-+Video+Apps",
      "https://www.torrentdownloads.me/category/86/Battle+Programer+Shirase",
      "https://www.torrentdownloads.me/category/87/Big+O",
      "https://www.torrentdownloads.me/category/267/Bleach",
      "https://www.torrentdownloads.me/category/88/Cardcaptor+Sakura",
      "https://www.torrentdownloads.me/category/89/Chobits",
      "https://www.torrentdownloads.me/category/142/Comics",
      "https://www.torrentdownloads.me/category/151/Dragon+ball",
      "https://www.torrentdownloads.me/category/90/Dragonball+GT",
      "https://www.torrentdownloads.me/category/91/Dragonball+Z",
      "https://www.torrentdownloads.me/category/156/DVD-R",
      "https://www.torrentdownloads.me/category/92/Flame+of+Recca",
      "https://www.torrentdownloads.me/category/93/Full+Metal+Alchemist",
      "https://www.torrentdownloads.me/category/95/Ghost+In+The+Shell+SAC",
      "https://www.torrentdownloads.me/category/94/Gundam",
      "https://www.torrentdownloads.me/category/145/Hunter+X+Hunter",
      "https://www.torrentdownloads.me/category/96/InuYasha",
      "https://www.torrentdownloads.me/category/97/Konkiki+No+Gash+Bell",
      "https://www.torrentdownloads.me/category/98/Last+Exile",
      "https://www.torrentdownloads.me/category/101/Naruto",
      "https://www.torrentdownloads.me/category/100/Onegai+Twins",
      "https://www.torrentdownloads.me/category/99/Anime+-+Other",
      "https://www.torrentdownloads.me/category/102/PlaES",
      "https://www.torrentdownloads.me/category/146/Prince+of+Tennis",
      "https://www.torrentdownloads.me/category/103/Ranma+1/2",
      "https://www.torrentdownloads.me/category/104/Ruroni+Kenshin",
      "https://www.torrentdownloads.me/category/105/Samurai+Champloo",
      "https://www.torrentdownloads.me/category/107/Scrapped+Princess",
      "https://www.torrentdownloads.me/category/106/Stellvia+of+the+Universe",
      "https://www.torrentdownloads.me/category/51/Audio+books",
      "https://www.torrentdownloads.me/category/50/Ebooks",
      "https://www.torrentdownloads.me/category/465/Magazines",
      "https://www.torrentdownloads.me/category/80/Articles",
      "https://www.torrentdownloads.me/category/143/Comics",
      "https://www.torrentdownloads.me/category/84/Flash/Shockwave",
      "https://www.torrentdownloads.me/category/85/Funny+clips",
      "https://www.torrentdownloads.me/category/81/Manuals",
      "https://www.torrentdownloads.me/category/83/Other",
      "https://www.torrentdownloads.me/category/413/Radio+shows",
      "https://www.torrentdownloads.me/category/82/Religion"
    ]
  end

  def download_url(url) do
    response = HTTPoison.get(url)
    response.body
  end

  def paginated_links(html_body) do
    base_url = html_body
      |> Floki.find(".pagination_box a[title='2']")
      |> Floki.attribute("href")
      |> Enum.at(0)
    page_url = "https://www.torrentdownloads.me" <> base_url

    1..1000
    |> Enum.map(fn i -> String.replace(page_url, "page=2", "page=#{i}") end)
  end

  def torrent_links(html_body) do
    html_body
    |> Floki.find(".grey_bar3 p a")
    |> Floki.attribute("href")
    |> Enum.map(fn(url) -> "https://www.torrentdownloads.me" <> url end)
  end

  def scrape_torrent_information(html_body) do
    name = html_body
      |> Floki.find("h1.titl_1 span")
      |> Floki.text
      |> String.trim

    description = html_body
      |> Floki.find("p.para1")
      |> Floki.text

    magnet = html_body
      |> Floki.find(".grey_bar1 p a")
      |> Floki.attribute("href")
      |> Enum.filter(fn(url) -> String.starts_with?(url, "magnet:") end)
      |> Enum.at(0)

    size_html = html_body
      |> Floki.find(".grey_bar1 p")
      |> Enum.at(1)
      |> Floki.text
      |> String.replace("Total Size: ", "")
      |> String.trim
      |> String.split(<<194, 160>>)
    size_value = Enum.at(size_html, 0)
    unit = Enum.at(size_html, 1)
    size = Magnetissimo.SizeConverter.size_to_bytes(size_value, unit) |> Kernel.to_string

    seeders = html_body
      |> Floki.find(".grey_bar1 p")
      |> Enum.at(3)
      |> Floki.text
      |> String.split(":")
      |> Enum.at(1)
      |> String.trim
    {seeders, _} = Integer.parse(seeders)

    leechers = html_body
      |> Floki.find(".grey_bar1 p")
      |> Enum.at(4)
      |> Floki.text
      |> String.split(":")
      |> Enum.at(1)
      |> String.trim
    {leechers, _} = Integer.parse(leechers)

    %{
      name: name,
      description: description,
      magnet: magnet,
      filesize: size,
      source: "TorrentDownloads",
      seeders: seeders,
      leechers: leechers
    }
  end
end
