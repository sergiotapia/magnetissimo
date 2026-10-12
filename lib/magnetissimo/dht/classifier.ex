defmodule Magnetissimo.DHT.Classifier do
  @moduledoc """
  Files a torrent the DHT found under a Torznab category, from its name and
  its file list, or refuses it.

  Nothing on the DHT says what a torrent is, so this reads what is in it. The
  files are grouped by extension and weighed in bytes; the heaviest group
  decides the family (video, audio, books, comics, software), and the name
  decides the rest: an episode marker such as `S01E02` or `1x02` makes video
  TV rather than a movie (so does a season in another language, "9 сезон",
  or a date, "Show.2026.06.08"), a league's name makes it TV/Sport, a
  resolution picks UHD, HD or SD (a remux is BluRay, a DVD5 a DVD, a rip with
  no resolution SD). Audio is an audiobook when it says so (in
  English, German, Spanish, Dutch or Russian), has an `.m4b`, names its
  narrator the way Russian releases do ("Title [Имя Фамилия]"), or has
  tracks too long to be songs. Anything it cannot place is `Other`. A site
  that later indexes the same hash replaces the guess with its own category.

  Pictures and archives are read by their names. Doujinshi ("(C97) [Circle
  (Artist)] Title", "(成年コミック)", "[AI Generated]") are adult image sets,
  as Sukebei files them, and so are pictures with adult or nude words. A
  volume makes a comic. An archive says nothing of what it holds, so its name
  decides: a version number or a crack makes it software, a resolution a
  video, a volume a comic. Switch, DS, 3DS and Wii images are console games.

  A game is told from other software by its engine's data files (`.pak`,
  `.ucas`, `.forge`, …), its group or repacker (FitGirl, xatab, R.G.), or a
  word only games use (`DLC`, `Simulator`). A program beside a video or a
  soundtrack, with most of the bytes in files no group names, is software:
  the video is its trailer.

  A video torrent is TV when its name says so, or when its videos are named
  like episodes (a season pack named for the show alone): two or more marked
  as episodes, or, when no adult keyword says otherwise, three or more just
  numbered ("Higurashi 01.mkv").

  Adult content is told apart by keywords, from bitmagnet's classifier, plus
  studio and site names, common Chinese and Japanese terms, the product codes
  Japanese adult releases are named for ("SABA-938", "kss55.cc@CLUB-936C"),
  and the "Studio.YY.MM.DD.Performer" names of Western scene releases. An
  explicit `xxx` (or `FC2-PPV`, the Japanese amateur site's code) decides;
  otherwise an episode marker wins over the looser words, so "Sex Education
  S01E01" stays TV.

  A torrent whose name or files match the banned keywords is refused before
  anything is written. The list is bitmagnet's, and is about child sexual
  abuse material; the DHT carries it, and an indexer must not.
  """

  alias Magnetissimo.Taxonomy

  @extensions %{
    video:
      ~w(mkv mp4 avi mov wmv flv m4v mpg mpeg ts m2ts mts vob webm divx xvid rmvb rm asf 3gp f4v
              ogv),
    lossless: ~w(flac ape alac wav aiff dsf dff wv),
    audio: ~w(mp3 aac ogg opus m4a wma mka),
    audiobook: ~w(m4b aax aa),
    ebook: ~w(epub mobi azw azw3 azw4 azw8 djvu fb2 lit chm pdf),
    comic: ~w(cbz cbr cb7 cbt cba),
    software: ~w(exe msi dmg pkg deb rpm apk app jar appimage),
    disc: ~w(iso img bin nrg mdf),
    image: ~w(jpg jpeg png gif bmp webp tif tiff heic),
    archive: ~w(zip rar 7z tar gz tgz xz zst bz2),
    switch: ~w(nsp nsz xci),
    nds: ~w(nds),
    n3ds: ~w(3ds cia),
    wii: ~w(wbfs),
    # Game engines' data files: Unreal, Unity, Bethesda, Ubisoft, Rockstar,
    # SCS, CRI, XNA, and the dxn of a repack.
    game_data: ~w(pak ucas utoc upk ress bsa ba2 forge rpf scs cpk xnb dxn)
  }

  @group_by_extension for {group, extensions} <- @extensions,
                          extension <- extensions,
                          into: %{},
                          do: {extension, group}

  # Keyword patterns match whole words of the name and paths, lowercased with
  # every run of punctuation turned into one space.
  @banned [
    "pa?edo(?:fil\\w*|phil\\w*)?",
    "preteen",
    "pthc",
    "ptsc",
    "lsbar",
    "lsm",
    "underage",
    "hebefilia",
    "opva",
    "child ?porn\\w*",
    "child ?lover\\w*",
    "porno ?child\\w*",
    "kidd(?:y\\w*|ie\\w*) ?porn",
    "young ?video ?models",
    "childfugga",
    "kinderkutje",
    "yvm",
    "1[0-7] ?y ?o"
  ]

  @xxx [
    "anal",
    "ass",
    "blowjobs?",
    "boob\\w*",
    "cocks?",
    "cum\\w*",
    "dicks?",
    "erotic\\w*",
    "\\w*fuck\\w*",
    "\\w*gloryhole\\w*",
    "hardcore",
    "horny",
    "kink\\w*",
    "milf\\w*",
    "nubile\\w*",
    "onlyfans",
    "orgasm\\w*",
    "orgy",
    "\\w*porn\\w*",
    "pussy",
    "seduc\\w*",
    "sex\\w*",
    "slut\\w*",
    "tits?",
    "threesome",
    "\\w*wank\\w*",
    # Acts, and the studios, sites and Japanese labels that release under
    # their own names.
    "bukkake",
    "creampies?",
    "deepthroat\\w*",
    "footjobs?",
    "gangbangs?",
    "handjobs?",
    "hentai",
    "jav",
    "shemales?",
    "squirt(?:s|ing)?",
    "stepmoms?",
    "stepsis\\w*",
    "analvids",
    "badoinkvr",
    "bangbros",
    "blacked(?:raw)?",
    "brazzers",
    "chaturbate",
    "clips4sale",
    "digitalplayground",
    "evilangel",
    "fansly",
    "hegre",
    "manyvids",
    "metart",
    "mofos",
    "naughtyamerica",
    "realitykings",
    "sexart",
    "teamskeet",
    "tushy(?:raw)?",
    "vrbangers",
    "xhamster",
    "xvideos",
    "1pondo",
    "10musume",
    "caribbeancom",
    "heydouga",
    "heyzo",
    "mywife",
    "pacopacomama",
    "tokyo ?hot"
  ]

  # Chinese and Japanese adult terms. Those scripts have no spaces, so these
  # match anywhere in the text, not as whole words.
  @xxx_cjk ~w(黄片 色情 情色 成人 无码 無碼 有码 有碼 中出 素人 巨乳 熟女 人妻 av女优 痴汉 痴漢
               淫 アナル エロ 痴女 寝取 福利 自拍 偷拍 约炮 啪啪 做爱 裸
               肛交 口交 潮吹 自慰 性爱 性愛 三级 三級 偷窥 偷窺 大尺度 露点 露點 乳头 乳頭
               美乳 爆乳 无毛 無毛 调教 調教 绿帽 綠帽 ハメ撮り 生ハメ 盗撮 無修正 无修正
               抽插 射精 膣内 乱交 亂交 群交 内射 18禁)

  # Leagues and competitions, read from the name alone.
  @sports [
    "nfl",
    "nba",
    "nhl",
    "mlb",
    "mls",
    "ncaa",
    "ufc",
    "wwe",
    "aew",
    "nascar",
    "motogp",
    "formula ?1",
    "uefa",
    "fifa",
    "bundesliga",
    "laliga",
    "la liga",
    "premier league",
    "champions league",
    "s[eé]rie a",
    "ligue 1",
    "match ?day",
    "campeonato",
    "чемпионат\\w*",
    "футбол\\w*",
    "хоккей\\w*",
    "кхл"
  ]

  # Words that make pictures adult, though not a film: "Naked Gun" is not.
  @nude ["nude\\w*", "naked", "nsfw", "lewd"]
  @nude_cjk ~w(写真 寫真 套图 套圖 私房)

  @video_tags ~r/(?:^| )(?:2160p|1080p|720p|480p|bluray|blu ray|bdrip|bdremux|web ?dl|webrip|hdtv|dvdrip|x264|x265|h264|h265|hevc|xvid)(?: |$)/

  @audiobook [
    "audiobooks?",
    "(?:un)?abridged",
    "narrated",
    "books",
    "stories",
    "(?:32|48|56|64) ?kbps",
    "hörbuch\\w*",
    "hörspiel\\w*",
    "audiolibros?",
    "luisterboek\\w*",
    "аудиокниг\\w*",
    "аудиокурс\\w*",
    "аудиоспектакл\\w*",
    "радиоспектакл\\w*",
    "книг\\w*",
    "читает",
    "читают"
  ]

  # Long tracks are not a book when the name says they are music.
  @music ~w(mix\w* live dj concert set mixtape discography album ost soundtrack)

  # Game groups and repackers, and words only games use. A bare "repack"
  # is also an app repacked ("Office … RePack by KpoJIuK"), so it counts only
  # without a software maker's name.
  @games ~w(fitgirl dodi gog codex plaza skidrow elamigos tenoke rune empress razor1911 reloaded
            xatab insaneramzes dixen18 simplex igruha chovka flt cpy hoodlum tinyiso kaos
            goldberg anadius voksi steamrip dlc simulator) ++ ["r g", "by pioneer"]
  @software_makers ~w(microsoft windows office adobe autodesk autocad photoshop acrobat corel
                      kaspersky nero acdsee wondershare)

  defp words?(words, text) do
    Regex.match?(Regex.compile!("(?:^| )(?:#{Enum.join(words, "|")})(?: |$)", "u"), text)
  end

  @doc "A Torznab category id for the torrent, or `:banned`."
  @spec classify(%{
          :name => String.t(),
          :files => [%{path: String.t(), size: integer()}],
          optional(atom()) => term()
        }) :: {:ok, pos_integer()} | :banned
  def classify(%{name: name, files: files}) do
    if words?(@banned, text(name, files)) do
      :banned
    else
      # A soundtrack's track names ("Upset small tits.flac") say nothing about
      # the video they came with.
      text = text(name, Enum.reject(files, &(group(&1) in [:audio, :lossless, :audiobook])))
      {:ok, Taxonomy.id!(category(name, files, text, weigh(files)))}
    end
  end

  # Keywords read the paths without their extensions: an `.ass` subtitle is
  # not a word of the title.
  defp text(name, files), do: normalize([name | Enum.map(files, &Path.rootname(&1.path))])

  defp normalize(texts) do
    texts
    |> Enum.join(" ")
    |> String.downcase()
    |> String.replace(~r/[^\p{L}\p{N}]+/u, " ")
    |> String.trim()
  end

  # Bytes per extension group, heaviest first. `:other` is every extension
  # no group names.
  defp weigh(files) do
    files
    |> Enum.group_by(&group/1, & &1.size)
    |> Enum.map(fn {group, sizes} -> {group, Enum.sum(sizes)} end)
    |> Enum.sort_by(fn {_group, bytes} -> bytes end, :desc)
  end

  defp group(%{path: path}) do
    extension = path |> Path.extname() |> String.trim_leading(".") |> String.downcase()

    # A split RAR or ZIP goes on in .r00, .r01… and .z01, .z02…
    if Regex.match?(~r/^[rz]\d{2}$/, extension),
      do: :archive,
      else: Map.get(@group_by_extension, extension, :other)
  end

  # `raw` is the name as written, which the anime test needs for its
  # brackets; everything else reads it normalised.
  defp category(raw, files, text, weights) do
    family = family(weights)
    name = normalize([raw])

    cond do
      family in [:video, :image, :disc, :archive] and words?(["xxx", "fc2 ?ppv"], text) ->
        xxx(family)

      family == :video ->
        video_category(raw, name, files, text)

      family in [:image, :comic, :archive] ->
        pictures(family, raw, name, text, weights)

      family in [:audio, :lossless, :audiobook] ->
        audio(family, raw, name, weights, files)

      true ->
        by_family(family, name, weights)
    end
  end

  defp video_category(raw, name, files, text) do
    cond do
      adult_name?(raw, text) -> "XXX"
      anime?(raw) -> "TV/Anime"
      words?(@sports, name) -> "TV/Sport"
      series?(name, files) -> video("TV", name, files)
      words?(@xxx, text) -> "XXX"
      loosely_series?(name, files) -> video("TV", name, files)
      true -> video("Movies", name, files)
    end
  end

  defp adult_name?(raw, text),
    do: jav_code?(raw) or scene?(raw) or String.contains?(text, @xxx_cjk)

  defp series?(name, files), do: tv?(name) or episodes?(files)

  defp loosely_series?(name, files), do: dated?(name) or numbered?(files)

  # A Japanese adult release is named for its product code: "SABA-938",
  # "109IENFH-29501-C", "HEYZO-2700-FHD", "SSIS255C", "sone-607". Forums put
  # their address in front ("kss55.cc@CLUB-936C") and tags around it. Once the
  # code, the forum, bracketed tags and the extension are gone, what is left
  # must be a Japanese title, or nothing but tags and no year: "THX-1138
  # (1971)" is a film.
  @jav_code ~r/(?<![A-Za-z\d])\d{0,3}([A-Za-z]{2,6})([-_]?)(\d{3,5})(?:[-_]?(?:uc|ch|fhd|hd|4k|[cuabr]))*(?![A-Za-z\d])/i
  @year ~r/(?<!\d)(?:19|20)\d{2}(?!\d)/
  @jav_tags ~w(dvd hd fhd uhd sd ch chs cht sub subs uncensored leaked leak mosaic mp4 mkv avi wmv
               ts h264 h265 x264 x265 hevc)

  defp jav_code?(raw) do
    stem = raw |> String.split("@") |> List.last() |> String.trim()
    stem = if video_extension?(stem), do: Path.rootname(stem), else: stem

    with [code, letters, separator, number] <- Regex.run(@jav_code, stem),
         true <- letters in [String.upcase(letters), String.downcase(letters)],
         true <- separator != "" or letters == String.upcase(letters),
         false <- Regex.match?(@year, number) do
      rest =
        stem
        |> String.replace(code, " ", global: false)
        |> String.replace(~r/\[[^\]]*\]|\([^)]*\)|【[^】]*】/u, " ")
        |> String.replace(
          ~r/\S+\.(?:com|net|org|cc|xyz|pw|me|tv|top|vip|club|info|co|in)(?![A-Za-z])/i,
          " "
        )

      Regex.match?(~r/[\p{Han}\p{Hiragana}\p{Katakana}]/u, rest) or
        (not Regex.match?(@year, rest) and
           Enum.all?(Regex.scan(~r/[A-Za-z]{2,}/, rest), fn [word] ->
             String.downcase(word) in @jav_tags
           end))
    else
      _no_code -> false
    end
  end

  defp video_extension?(name) do
    extension = name |> Path.extname() |> String.trim_leading(".") |> String.downcase()
    Map.get(@group_by_extension, extension) == :video
  end

  # Western adult scenes are named "Studio.YY.MM.DD.Performer…"; dated TV
  # names a four-digit year.
  defp scene?(raw), do: Regex.match?(~r/^[A-Za-z0-9]+\.\d{2}\.\d{2}\.\d{2}\./, raw)

  # The heaviest group a name is known for. A game's trailer or soundtrack is
  # not what it is: beside a program, with most of the bytes in files no
  # group names, it is software.
  defp family(weights) do
    total = weights |> Enum.map(&elem(&1, 1)) |> Enum.sum()

    case Enum.reject(weights, &match?({:other, _bytes}, &1)) do
      [] ->
        nil

      [{group, bytes} | _] ->
        if group in [:video, :audio, :lossless, :image] and
             Keyword.has_key?(weights, :software) and bytes * 2 < total,
           do: :software,
           else: group
    end
  end

  defp by_family(:ebook, _name, _weights), do: "Books/EBook"
  defp by_family(:software, name, _weights), do: software(name)
  defp by_family(:game_data, _name, _weights), do: "PC/Games"
  defp by_family(:disc, name, _weights), do: if(game?(name), do: "PC/Games", else: "PC/ISO")
  defp by_family(:switch, _name, _weights), do: "Console/Other"
  defp by_family(:nds, _name, _weights), do: "Console/NDS"
  defp by_family(:n3ds, _name, _weights), do: "Console/3DS"
  defp by_family(:wii, _name, _weights), do: "Console/Wii"
  defp by_family(_other, _name, _weights), do: "Other"

  # An audiobook says so, has an .m4b, names its narrator ("Варнак. Книга
  # третья [Григорий Андрианов]"), or has long tracks: a song is a few
  # megabytes, a chapter tens.
  defp audio(family, raw, name, weights, files) do
    cond do
      book?(weights, raw, name) -> "Audio/Audiobook"
      family == :audio and long_tracks?(files) and not words?(@music, name) -> "Audio/Audiobook"
      family == :lossless -> "Audio/Lossless"
      true -> "Audio/MP3"
    end
  end

  defp book?(weights, raw, name) do
    Keyword.has_key?(weights, :audiobook) or words?(@audiobook, name) or
      Regex.match?(
        ~r/[\[(](?=\p{Cyrillic})\p{Lu}\p{Ll}+ (?=\p{Cyrillic})\p{Lu}\p{Ll}+[\])]\s*$/u,
        raw
      )
  end

  defp long_tracks?(files) do
    sizes = for file <- files, group(file) == :audio, do: file.size
    sizes != [] and Enum.sum(sizes) / length(sizes) >= 40_000_000
  end

  defp software(name) do
    cond do
      Regex.match?(~r/(?:^| )(?:android|apk)(?: |$)/, name) -> "PC/Mobile-Android"
      Regex.match?(~r/(?:^| )(?:macos|mac os|osx|mac)(?: |$)/, name) -> "PC/Mac"
      game?(name) -> "PC/Games"
      true -> "PC"
    end
  end

  defp game?(name) do
    words?(@games, name) or (words?(["repack"], name) and not words?(@software_makers, name))
  end

  @seasons ~w(seasons? сезон\w* temporadas? saisons? staffel\w* stagione sezon\w* seizoen)

  # "S01E02", "1x02", "Season 2", "Seasons 1-8", "9 сезон", "Temporada 1",
  # "Cap.101" (Spanish releases), "1-20 серии", "[1-26 of 26]".
  defp tv?(name) do
    seasons = Enum.join(@seasons, "|")

    Regex.match?(
      ~r/(?:^| )(?:s\d{1,2} ?e\d{1,3}|s\d{1,2}|\d{1,2}x\d{2,3}|(?:#{seasons}) \d{1,2}|\d{1,2} (?:#{seasons})|cap \d{3,4}|сери[яи]|\d{1,3} of \d{1,3}|complete series)(?: |$)/u,
      name
    )
  end

  # A daily show is dated: "The.Daily.Show.2026.06.08". Read after the adult
  # words, as some adult sites date their scenes the same way.
  # A date that opens the name is when it was released, not an episode.
  defp dated?(name), do: Regex.match?(~r/. (?:19|20)\d{2} \d{2} \d{2}(?: |$)/, name)

  # A season pack named only for its show, "Lucky Star (Subbed & Dubbed)",
  # still names its files as episodes: two or more of its videos.
  defp episodes?(files), do: Enum.count(videos(files), &episode?/1) >= 2

  # Weaker: three or more videos just numbered, "Higurashi 01.mkv" or
  # "Sakura Quest [13]" ("x 264.mkv" is a codec). Read after the adult words.
  defp numbered?(files) do
    files
    |> videos()
    |> Enum.count(
      &Regex.match?(~r/\[\d{2,3}(?:v\d)?\]|(?<![xXhH])[ _]\d{2,3}(?:v\d)?\.\w+$/u, &1)
    )
    |> Kernel.>=(3)
  end

  defp videos(files), do: for(file <- files, group(file) == :video, do: Path.basename(file.path))

  defp episode?(base) do
    Regex.match?(~r/ - \d{1,4}(?:v\d)?(?:\s|\.|\[|\()/u, base) or
      Regex.match?(
        ~r/(?:^| )(?:s\d{1,2} ?e\d{1,3}|e\d{2,4}|ep ?\d{1,4}|episode \d{1,4})(?: |$)/,
        normalize([base])
      )
  end

  # Fansub releases: "[SubsPlease] Sousou no Frieren - 28 (1080p)". The
  # bracketed group first and the " - 28" episode number are the tell.
  defp anime?(raw), do: Regex.match?(~r/^\[[^\]]+\].* - \d{1,4}(?:v\d)?(?:\s|$|\[|\()/u, raw)

  @hd ~r/(?:^| )(?:1080p|1080i|720p|bluray|blu ray|(?:1920|1440|1280)x\d{3,4})(?: |$)/
  @sd ~r/(?:^| )(?:480p|576p|dvdrip|sdtv|xvid|bdrip|hdrip|web ?dlrip|webdl rip|hdtvrip|satrip|tvrip|vhsrip|vhs|dvdscr|camrip|(?:640|704|720)x\d{3})(?: |$)/

  # The resolution, else what the source says of it: a remux or a Blu-ray
  # folder is the disc, a DVD5 or a VIDEO_TS folder a DVD, and a rip with no
  # resolution ("BDRip", "WEB-DLRip", "HDRip") standard definition.
  defp video(family, name, files) do
    quality =
      cond do
        Regex.match?(~r/(?:^| )(?:2160p|4k|uhd|3840x2160)(?: |$)/, name) -> "UHD"
        disc?(name, files, "bdremux|remux|bdmv", "BDMV/") -> "BluRay"
        Regex.match?(@hd, name) -> "HD"
        Regex.match?(~r/(?:^| )(?:x265|h265|hevc)(?: |$)/, name) -> "x265"
        disc?(name, files, "\\d?x?dvd ?[59]|video ts", "VIDEO_TS/") -> "DVD"
        Regex.match?(@sd, name) -> "SD"
        true -> nil
      end

    subcategory(family, quality)
  end

  defp disc?(name, files, words, folder) do
    Regex.match?(~r/(?:^| )(?:#{words})(?: |$)/, name) or
      Enum.any?(files, &String.contains?(String.upcase(&1.path), folder))
  end

  # TV has no BluRay or DVD of its own.
  defp subcategory(family, nil), do: family
  defp subcategory("TV", "BluRay"), do: "TV/HD"
  defp subcategory("TV", "DVD"), do: "TV/SD"
  defp subcategory(family, quality), do: "#{family}/#{quality}"

  # Images, comic archives and archives carry pictures, or anything else.
  # Doujinshi, adult or not, are filed as adult image sets, as Sukebei files
  # them. An archive says nothing of what it holds, so its name decides: a
  # version number makes it software, a resolution a video, a volume a comic.
  defp pictures(family, raw, name, text, weights) do
    cond do
      doujin?(raw) -> "XXX/ImageSet"
      adult_name?(raw, text) or words?(@xxx, text) -> xxx(family)
      nude?(text) -> xxx(family)
      family == :comic -> "Books/Comics"
      family == :image -> if(manga?(raw, name), do: "Books/Comics", else: "Other")
      true -> archive(raw, name, text, weights)
    end
  end

  defp archive(raw, name, text, weights) do
    cond do
      Keyword.has_key?(weights, :software) or software_name?(name) -> software(name)
      Regex.match?(@video_tags, name) -> video_category(raw, name, [], text)
      manga?(raw, name) -> "Books/Comics"
      true -> "Other"
    end
  end

  # "(C97) [Circle (Artist)] Title [English]": a Comiket number, a circle
  # and its artist, a doujin label, or a translation tag after an artist.
  defp doujin?(raw) do
    Regex.match?(
      ~r/^\s*\((?:C\d{2,3}|COMIC1☆\d+|コミティア\d+|COMITIA ?\d+|例大祭\d*|紅楼夢\d*|サンクリ\d+|同人誌|同人CG集|成年コミック|18禁[^)]*)\)|^\s*\[[^\]]+ \([^)]+\)\]|\[DL版\]|\[AI (?:Generated|生成)\]|\[AI生成\]/iu,
      raw
    ) or
      (Regex.match?(~r/^\s*\[[^\]]+\]/u, raw) and
         Regex.match?(~r/\[(?:English|Chinese|Korean|Decensored|Uncensored)\]|\{[^}]+\}/iu, raw))
  end

  defp nude?(text), do: words?(@nude, text) or String.contains?(text, @nude_cjk)

  # A manga or comic volume: "vol 01-03", "v05", "第3巻", "[韓漫]".
  defp manga?(raw, name) do
    Regex.match?(
      ~r/(?:^| )(?:(?:vol|volume|ch|chapter|tome|том) ?\d|v\d{2,3}(?: |$)|dlraw|dl raw|manga(?: |$)|comics?(?: |$))/u,
      name
    ) or
      Regex.match?(~r/巻|漫画|漫畫|韓漫|コミック/u, raw)
  end

  defp software_name?(name) do
    Regex.match?(
      ~r/(?:^| )(?:v(?:[1-9]\d*|0) \d+|build \d{4,}|keygen|crack|patch|portable|x64|x86|win(?:32|64)|setup|installer|linux|macos)(?: |$)/,
      name
    )
  end

  defp xxx(:image), do: "XXX/ImageSet"
  defp xxx(:comic), do: "XXX/ImageSet"

  defp xxx(_family), do: "XXX"
end
