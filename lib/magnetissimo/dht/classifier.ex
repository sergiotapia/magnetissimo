defmodule Magnetissimo.DHT.Classifier do
  @moduledoc """
  Files a torrent the DHT found under a Torznab category, from its name and
  its file list, or refuses it.

  Nothing on the DHT says what a torrent is, so this reads what is in it. The
  files are grouped by extension and weighed in bytes; the heaviest group
  decides the family (video, audio, books, comics, software), and the name
  decides the rest: an episode marker such as `S01E02` or `1x02` makes video
  TV rather than a movie, a resolution picks UHD, HD or SD, `audiobook` or an
  `.m4b` makes audio an audiobook. Anything it cannot place is `Other`, which
  a site that later indexes the same hash is allowed to correct.

  A video torrent is TV when its name says so, or when two or more of its
  videos are named like episodes (a season pack named for the show alone).

  Adult content is told apart by keywords, from bitmagnet's classifier, plus
  common Chinese and Japanese terms and the bare product codes Japanese
  adult releases are named for ("SABA-938"). An explicit `xxx` (or `FC2-PPV`,
  the Japanese amateur site's code) decides; otherwise an episode marker wins over the looser
  words, so "Sex Education S01E01" stays TV.

  A torrent whose name or files match the banned keywords is refused before
  anything is written. The list is bitmagnet's, and is about child sexual
  abuse material; the DHT carries it, and an indexer must not.
  """

  alias Magnetissimo.Taxonomy

  @extensions %{
    video: ~w(mkv mp4 avi mov wmv flv m4v mpg mpeg ts m2ts vob webm divx xvid),
    lossless: ~w(flac ape alac wav aiff dsf dff wv),
    audio: ~w(mp3 aac ogg opus m4a wma mka),
    audiobook: ~w(m4b aax aa),
    ebook: ~w(epub mobi azw azw3 azw4 azw8 djvu fb2 lit chm pdf),
    comic: ~w(cbz cbr cb7 cbt cba),
    software: ~w(exe msi dmg pkg deb rpm apk app jar appimage),
    disc: ~w(iso img bin nrg mdf),
    image: ~w(jpg jpeg png gif bmp webp tif tiff heic)
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
    "\\w*wank\\w*"
  ]

  # Chinese and Japanese adult terms. Those scripts have no spaces, so these
  # match anywhere in the text, not as whole words.
  @xxx_cjk ~w(黄片 色情 情色 成人 无码 無碼 有码 有碼 中出 素人 巨乳 熟女 人妻 av女优 痴汉 痴漢
               淫 アナル エロ 痴女 寝取 福利 自拍 偷拍 约炮 啪啪 做爱 裸)

  @audiobook ["audiobooks?", "(?:un)?abridged", "narrated"]

  @games ~w(repack fitgirl dodi gog codex plaza skidrow elamigos tenoke rune empress razor1911)

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
    text = normalize([name | Enum.map(files, & &1.path)])

    if words?(@banned, text),
      do: :banned,
      else: {:ok, Taxonomy.id!(category(name, files, text, weigh(files)))}
  end

  defp normalize(texts) do
    texts
    |> Enum.join(" ")
    |> String.downcase()
    |> String.replace(~r/[^\p{L}\p{N}]+/u, " ")
    |> String.trim()
  end

  # Bytes per extension group, heaviest first.
  defp weigh(files) do
    files
    |> Enum.group_by(&group/1, & &1.size)
    |> Enum.map(fn {group, sizes} -> {group, Enum.sum(sizes)} end)
    |> Enum.reject(fn {group, _bytes} -> group == :other end)
    |> Enum.sort_by(fn {_group, bytes} -> bytes end, :desc)
  end

  defp group(%{path: path}) do
    extension = path |> Path.extname() |> String.trim_leading(".") |> String.downcase()
    Map.get(@group_by_extension, extension, :other)
  end

  # `raw` is the name as written, which the anime test needs for its
  # brackets; everything else reads it normalised.
  defp category(raw, files, text, weights) do
    family = family(weights)
    name = normalize([raw])

    cond do
      family in [:video, :image, :disc] and words?(["xxx", "fc2 ?ppv"], text) -> xxx(family)
      family == :video -> video_category(raw, name, files, text)
      family == :image and words?(@xxx, text) -> xxx(family)
      true -> by_family(family, name, weights)
    end
  end

  defp video_category(raw, name, files, text) do
    cond do
      jav_code?(raw) or String.contains?(text, @xxx_cjk) -> "XXX"
      anime?(raw) -> "TV/Anime"
      tv?(name) or episodes?(files) -> video("TV", name)
      words?(@xxx, text) -> "XXX"
      true -> video("Movies", name)
    end
  end

  # A Japanese adult release is named for its product code, alone or before
  # a Japanese title: "SABA-938", "109IENFH-29501-C", "NLE-038-C 狙われた…".
  # Before a Latin title it is left alone: "THX-1138 (1971)" is a film.
  defp jav_code?(raw) do
    case Regex.run(
           ~r/^\d{0,3}[A-Z]{2,6}-\d{3,5}(?:-?[A-Z])?(?:\.\w{2,4})?(.*)$/su,
           String.trim(raw)
         ) do
      [_, ""] -> true
      [_, rest] -> Regex.match?(~r/^\s+.*[\p{Han}\p{Hiragana}\p{Katakana}]/u, rest)
      nil -> false
    end
  end

  defp family([]), do: nil
  defp family([{group, _bytes} | _]), do: group

  defp by_family(:audiobook, _name, _weights), do: "Audio/Audiobook"
  defp by_family(:lossless, name, weights), do: audio(name, weights, "Audio/Lossless")
  defp by_family(:audio, name, weights), do: audio(name, weights, "Audio/MP3")
  defp by_family(:ebook, _name, _weights), do: "Books/EBook"
  defp by_family(:comic, _name, _weights), do: "Books/Comics"
  defp by_family(:software, name, _weights), do: software(name)
  defp by_family(:disc, name, _weights), do: if(game?(name), do: "PC/Games", else: "PC/ISO")
  defp by_family(_other, _name, _weights), do: "Other"

  defp audio(name, weights, fallback) do
    if Keyword.has_key?(weights, :audiobook) or words?(@audiobook, name),
      do: "Audio/Audiobook",
      else: fallback
  end

  defp software(name) do
    cond do
      Regex.match?(~r/(?:^| )(?:android|apk)(?: |$)/, name) -> "PC/Mobile-Android"
      Regex.match?(~r/(?:^| )(?:macos|mac os|osx|mac)(?: |$)/, name) -> "PC/Mac"
      game?(name) -> "PC/Games"
      true -> "PC"
    end
  end

  defp game?(name), do: words?(@games, name)

  defp tv?(name) do
    Regex.match?(
      ~r/(?:^| )(?:s\d{1,2} ?e\d{1,3}|s\d{1,2}|\d{1,2}x\d{2,3}|season \d{1,2}|complete series)(?: |$)/,
      name
    )
  end

  # A season pack named only for its show, "Lucky Star (Subbed & Dubbed)",
  # still numbers its files: two or more videos named like episodes.
  defp episodes?(files) do
    files
    |> Enum.filter(&(group(&1) == :video))
    |> Enum.count(fn %{path: path} ->
      base = Path.basename(path)

      Regex.match?(~r/ - \d{1,4}(?:v\d)?(?:\s|\.|\[|\()/u, base) or
        Regex.match?(
          ~r/(?:^| )(?:s\d{1,2} ?e\d{1,3}|e\d{2,4}|ep ?\d{1,4}|episode \d{1,4})(?: |$)/,
          normalize([base])
        )
    end)
    |> Kernel.>=(2)
  end

  # Fansub releases: "[SubsPlease] Sousou no Frieren - 28 (1080p)". The
  # bracketed group first and the " - 28" episode number are the tell.
  defp anime?(raw), do: Regex.match?(~r/^\[[^\]]+\].* - \d{1,4}(?:v\d)?(?:\s|$|\[|\()/u, raw)

  defp video(family, name) do
    quality =
      cond do
        Regex.match?(~r/(?:^| )(?:2160p|4k|uhd)(?: |$)/, name) -> "UHD"
        Regex.match?(~r/(?:^| )(?:1080p|1080i|720p)(?: |$)/, name) -> "HD"
        Regex.match?(~r/(?:^| )(?:x265|h265|hevc)(?: |$)/, name) -> "x265"
        Regex.match?(~r/(?:^| )(?:480p|576p|dvdrip|sdtv|xvid)(?: |$)/, name) -> "SD"
        true -> nil
      end

    if quality, do: "#{family}/#{quality}", else: family
  end

  defp xxx(:image), do: "XXX/ImageSet"

  defp xxx(_family), do: "XXX"
end
