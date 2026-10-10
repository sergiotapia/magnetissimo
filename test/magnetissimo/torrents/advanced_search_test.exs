defmodule Magnetissimo.Torrents.AdvancedSearchTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Torrents
  alias Magnetissimo.Torrents.Query
  alias Magnetissimo.TorrentsFixtures

  @gib 1024 * 1024 * 1024
  @mib 1024 * 1024

  # Names as the sources really send them, taken from a development index:
  # dotted scene names, a run of spaces and a dash in front, CJK with no
  # spaces, an accent, quotes and a bar inside a name. `days` is the age.
  @corpus %{
    dune_uhd: {"Dune Part Two 2024 2160p UHD BluRay x265-MeGusta", 18 * @gib, 900, 30},
    dune_web: {"Dune.Part.Two.2024.1080p.WEB-DL.DDP5.1.H.264-FLUX", 6 * @gib, 2500, 60},
    dune_hdcam: {"Dune 2021 HDCAM x264-GAP", 900 * @mib, 3, 1100},
    dune_cam: {"Dune Part Two 2024 CAM 720p x264", 1_400_000_000, 12, 200},
    prophecy3:
      {"Dune Prophecy S01E03 Sisterhood Above All 1080p MAX WEB-DL DDP5 1 Atmos H 264-FLUX",
       1_288_490_189, 1, 300},
    prophecy4: {"Dune Prophecy S01E04 Twice Born 2160p WEB-DL", 4 * @gib, 40, 290},
    dunes: {"Dunes of Arrakis Soundtrack FLAC", 400 * @mib, 7, 1000},
    seinfeld_s05e11:
      {"-    Seinfeld S05E11 The Conversion 1080p HEVC x265-MeGusta", nil, nil, nil},
    seinfeld_s05e16:
      {"-    Seinfeld S05E16 The Stand-In 1080p PLAY WEB-DL AAC2 0 H 264-FLUX", nil, nil, nil},
    seinfeld_s03e14: {"Seinfeld s03e14 the pez dispenser dvdrip x264 digg mkv", nil, nil, nil},
    seinfeld_disc: {"Seinfeld season 5 disc 4 dvdr", nil, nil, nil},
    bb_s05e13: {"Breaking-Bad-S05E13-HDTVx264EVOLVE[ettv]", nil, nil, nil},
    bb_s05e14: {"Breaking Bad S05E14 Ozymandias 720p", nil, nil, nil},
    el_camino: {"El Camino - A Breaking Bad Movie 2019 (720p - WEB-DL) [DUBLADO]", nil, nil, nil},
    cabin_woods: {"The.Cabin.In.The.Woods.2011.DVDRip.XviD-Ac3.Feel-Free", nil, nil, nil},
    cabin: {"The Cabin (2018)", nil, nil, nil},
    shingeki: {"進撃の巨人 The Final Season 2160p", nil, nil, nil},
    rilakkuma: {"[ANi] 拉拉熊 - 27 [1080P][Baha][WEB-DL][AAC AVC][CHT] mp4", nil, nil, nil},
    pikachu: {"Pokémon Detective Pikachu 2019 1080p", nil, nil, nil},
    toy4: {"Toy.Story.4.2019.1080p", nil, nil, nil},
    toy3: {"Toy Story 3 (2010)", nil, nil, nil},
    wolf2: {"Wolfenstein II The New Colossus-CODEX", 45_486_511_641, 3, 2525},
    rtcw: {"Return to Castle Wolfenstein v2 0 0 2 REPACK-KaOs", 477_475_921, 27, 1916},
    f9: {"F9 2021 720p HDCAM x265-GAP", nil, nil, nil},
    camera: {"Camera Obscura 2017 1080p WEB", nil, nil, nil},
    weird_al: {~s|"Weird Al" Yankovic - Mandatory Fun (2014) FLAC|, nil, nil, nil},
    cyberpunk: {"Cyberpunk | Edgerunners S01 1080p", nil, nil, nil},
    not_okay: {"Not Okay (2022)", nil, nil, nil},
    up: {"Up (2009) 4K HDR", nil, nil, nil}
  }

  # The only descriptions: everything else has none, so a match is in the name.
  @descriptions %{cabin: "A couple escape to a cabin in the woods."}

  @dune [:dune_uhd, :dune_web, :dune_hdcam, :dune_cam, :prophecy3, :prophecy4, :dunes]
  @seinfeld [:seinfeld_s05e11, :seinfeld_s05e16, :seinfeld_s03e14, :seinfeld_disc]

  setup do
    TorrentsFixtures.seed!()
    now = DateTime.utc_now()

    labels =
      for {label, {name, size, seeders, days}} <- @corpus, into: %{} do
        torrent =
          TorrentsFixtures.torrent_fixture(%{
            name: name,
            description: @descriptions[label],
            size_in_bytes: size || 1_400_000_000,
            seeders: seeders || 100,
            published_at: DateTime.add(now, -(days || 10), :day)
          })

        {torrent.id, label}
      end

    %{labels: labels, now: now}
  end

  # The labels a query finds, sorted. Every search is also counted and read
  # two at a time, so the count, the paging and the full list always agree.
  defp found(%{labels: labels}, text, opts \\ []) do
    query = Query.parse(text)
    torrents = Torrents.search_torrents(query, [limit: 100] ++ opts)
    ids = Enum.map(torrents, & &1.id)

    assert Torrents.count_search_torrents(query, opts) == length(ids),
           "count disagrees with the list for #{inspect(text)}"

    paged =
      Stream.iterate(0, &(&1 + 2))
      |> Stream.map(&Torrents.search_torrents(query, [limit: 2, offset: &1] ++ opts))
      |> Enum.take_while(&(&1 != []))
      |> Enum.flat_map(fn page -> Enum.map(page, & &1.id) end)

    assert paged == ids, "paging disagrees with the list for #{inspect(text)}"

    ids |> Enum.map(&Map.fetch!(labels, &1)) |> Enum.sort()
  end

  # Each case is {what it shows, query, options, labels expected}. `{:all_but,
  # labels}` is every torrent in the corpus except those.
  @cases [
    # Phrases are whole words, in order and next to each other, across any
    # separator a name uses.
    {"a quoted word is a whole word", ~s("dune"), [], @dune -- [:dunes]},
    {"a phrase crosses dots", ~s("part two"), [], [:dune_uhd, :dune_web, :dune_cam]},
    {"a phrase keeps its order", ~s("two part"), [], []},
    {"a phrase keeps its words together", ~s("dune two"), [], []},
    {"a phrase matches a description", ~s("cabin in the woods"), [], [:cabin_woods, :cabin]},
    {"a phrase in titles only", ~s("cabin in the woods"), [scope: :name], [:cabin_woods]},
    {"quotes in a name are punctuation", ~s("weird al"), [], [:weird_al]},
    {"a hyphen in a phrase is any separator", ~s("web-dl"), [],
     [:dune_web, :prophecy3, :prophecy4, :seinfeld_s05e16, :el_camino, :rilakkuma]},
    {"a phrase ignores accents", ~s("pokemon"), [], [:pikachu]},
    {"a phrase in an unspaced script", ~s("進撃の巨人"), [], [:shingeki]},
    {"part of an unspaced phrase", ~s("巨人"), [], [:shingeki]},
    {"a short unspaced phrase", ~s("拉拉"), [], [:rilakkuma]},
    {"a quoted fragment is not a prefix", ~s("s05e1"), [], []},
    {"a short word in a phrase is whole", ~s("toy story 4"), [], [:toy4]},
    {"an unclosed phrase", ~s(dune "part two), [], [:dune_uhd, :dune_web, :dune_cam]},
    {"curly quotes", "“part two”", [], [:dune_uhd, :dune_web, :dune_cam]},
    {"a quoted short word is not typed yet", ~s(up "4"), [], []},
    {"an empty phrase finds nothing", ~s(""), [], []},

    # Exclusions remove whole words, so "-cam" keeps El Camino and HDCAM.
    {"an exclusion is a whole word", "dune -cam", [], @dune -- [:dune_cam]},
    {"two exclusions", "dune -cam -hdcam", [], @dune -- [:dune_cam, :dune_hdcam]},
    {"a wildcard excludes inside words", "dune -*cam", [], @dune -- [:dune_cam, :dune_hdcam]},
    {"only an exclusion is everything else", "-cam", [], {:all_but, [:dune_cam]}},
    {"an exclusion of a longer word", "breaking bad -camino", [], [:bb_s05e13, :bb_s05e14]},
    {"an exclusion does not cut into words", "breaking bad -cam", [],
     [:bb_s05e13, :bb_s05e14, :el_camino]},
    {"an exclusion after a dash in a name", "seinfeld -x265", [],
     @seinfeld -- [:seinfeld_s05e11]},
    {"an excluded word with a hyphen is a phrase", "seinfeld -web-dl", [],
     @seinfeld -- [:seinfeld_s05e16]},
    {"an excluded phrase", ~s(seinfeld -"web dl"), [], @seinfeld -- [:seinfeld_s05e16]},
    {"a lone dash is not an exclusion", "seinfeld - x265", [], [:seinfeld_s05e11]},
    {"two dashes are one", "seinfeld --x265", [], @seinfeld -- [:seinfeld_s05e11]},
    {"a substring can survive its whole word's exclusion", "dune -dune", [], [:dunes]},
    {"an exclusion ignores accents", "pikachu -pokemon", [], []},
    {"an exclusion in an unspaced script", "2160p -巨人", [], [:dune_uhd, :prophecy4]},
    {"an exclusion reads descriptions", "cabin -couple", [], [:cabin_woods]},
    {"an exclusion in titles only", "cabin -couple", [scope: :name], [:cabin_woods, :cabin]},
    {"exclusions only of nothing", "-xyzzy", [], {:all_but, []}},
    {"a lone dash finds nothing", "-", [], []},

    # A bar is OR, and binds tighter than the space between words.
    {"alternatives", "dune 2160p|1080p", [], [:dune_uhd, :dune_web, :prophecy3, :prophecy4]},
    {"alternatives spaced out", "dune 2160p | 1080p", [],
     [:dune_uhd, :dune_web, :prophecy3, :prophecy4]},
    {"a doubled bar", "dune 2160p||1080p", [], [:dune_uhd, :dune_web, :prophecy3, :prophecy4]},
    {"short alternatives are whole words", "toy story 3|4", [], [:toy3, :toy4]},
    {"a short alternative", "up 4k|8k", [], [:up]},
    {"no alternative matches", "up 8k|16k", [], []},
    {"alternatives as the whole query", "dune|seinfeld", [], @dune ++ @seinfeld},
    {"a bar binds tighter than a space", "dune|seinfeld 1080p", [],
     [:dune_web, :prophecy3, :seinfeld_s05e11, :seinfeld_s05e16]},
    {"a phrase as an alternative", ~s("part two"|prophecy), [],
     [:dune_uhd, :dune_web, :dune_cam, :prophecy3, :prophecy4]},
    {"a bar next to an exclusion is ignored", "dune 2160p|-cam", [], [:dune_uhd, :prophecy4]},
    {"stray bars", "| dune |", [], @dune},
    {"episodes as alternatives", "s05e13|s05e14", [], [:bb_s05e13, :bb_s05e14]},
    {"alternatives of different shapes", "breaking bad s05e13|camino", [],
     [:bb_s05e13, :el_camino]},
    {"unspaced alternatives", "進撃|拉拉熊", [], [:shingeki, :rilakkuma]},
    {"short unspaced alternatives", "進撃|拉拉", [], [:shingeki, :rilakkuma]},
    {"an alternative matching nothing", "dune xyzzy|2160p", [], [:dune_uhd, :prophecy4]},
    {"the same alternative twice", "dune|dune", [], @dune},
    {"a bar inside a name", "cyberpunk|edgerunners", [], [:cyberpunk]},
    {"alternatives in titles only", "cabin woods|couple", [scope: :name], [:cabin_woods]},

    # A star is any run of characters. A word it ends is a prefix of a word;
    # one it starts can begin anywhere.
    {"a trailing star is a word prefix", "s05e1*", [],
     [:seinfeld_s05e11, :seinfeld_s05e16, :bb_s05e13, :bb_s05e14]},
    {"a prefix with other words", "seinfeld s05e1*", [], [:seinfeld_s05e11, :seinfeld_s05e16]},
    {"a prefix starts a word", "cam*", [], [:dune_cam, :el_camino, :camera]},
    {"a leading star starts anywhere", "*cam", [],
     [:dune_hdcam, :dune_cam, :el_camino, :camera, :f9]},
    {"a star in the middle", "s0*e14", [], [:seinfeld_s03e14, :bb_s05e14]},
    {"a star across words", "breaking*bad", [], [:bb_s05e13, :bb_s05e14, :el_camino]},
    {"a short prefix", "toy story 4*", [], [:toy4]},
    {"a prefix of three characters", "x26*", [],
     [:dune_uhd, :dune_hdcam, :dune_cam, :seinfeld_s05e11, :seinfeld_s03e14, :f9]},
    {"prefixes as alternatives", "s05e1*|s03e*", [],
     [:seinfeld_s05e11, :seinfeld_s05e16, :seinfeld_s03e14, :bb_s05e13, :bb_s05e14]},
    {"an excluded prefix", "dune -s01e*", [], @dune -- [:prophecy3, :prophecy4]},
    {"a prefix in an unspaced script", "進撃*", [], [:shingeki]},
    {"stars around an unspaced word", "*巨人*", [], [:shingeki]},
    {"a prefix ignores accents", "poke*", [], [:pikachu]},
    {"a prefix reads descriptions", "cabin wood*", [], [:cabin_woods, :cabin]},
    {"a prefix in titles only", "cabin wood*", [scope: :name], [:cabin_woods]},
    {"a lone star finds nothing", "*", [], []},
    {"a lone star next to a word", "dune *", [], @dune},

    # No operator, no change: these find what the plain search finds.
    {"plain words are substrings", "dune", [], @dune},
    {"FTS5 operators are words", "NOT", [], [:not_okay]},
    {"a trailing hyphen is punctuation", "x265-", [], [:dune_uhd, :seinfeld_s05e11, :f9]},
    {"a short last word is a prefix while typed", "up 4", [], [:up]},
    {"a bar inside a name is not needed to find it", "cyberpunk edgerunners", [], [:cyberpunk]},
    {"a name with a dash in front", "seinfeld conversion", [], [:seinfeld_s05e11]},
    {"titles only", "couple", [scope: :name], []},
    {"titles and descriptions", "couple", [], [:cabin]},

    # Everything at once.
    {"phrase, alternative, exclusion and prefix", ~s("part two" 2160p|1080p -cam -x26*), [],
     [:dune_web]},
    {"alternatives of exclusions do not exist", ~s(dune -cam|-hdcam), [],
     @dune -- [:dune_cam, :dune_hdcam]}
  ]

  for {label, text, opts, expected} <- @cases do
    test "#{label}: #{inspect(text)}#{if opts != [], do: " #{inspect(opts)}"}", context do
      expected =
        case unquote(Macro.escape(expected)) do
          {:all_but, except} -> Map.keys(@corpus) -- except
          labels -> labels
        end

      assert found(context, unquote(text), unquote(opts)) == Enum.sort(expected)
    end
  end

  describe "ranges" do
    test "size is at least or at most a number of bytes, both inclusive", context do
      assert found(context, "wolfenstein", min_size: @gib) == [:wolf2]
      assert found(context, "wolfenstein", max_size: @gib) == [:rtcw]
      assert found(context, "wolfenstein", min_size: 477_475_921) == [:rtcw, :wolf2]
      assert found(context, "wolfenstein", min_size: 477_475_922) == [:wolf2]
      assert found(context, "wolfenstein", max_size: 477_475_921) == [:rtcw]
      assert found(context, "wolfenstein", max_size: 477_475_920) == []
    end

    test "seeders are at least or at most a count, both inclusive", context do
      assert found(context, "dune", min_seeders: 900) == [:dune_uhd, :dune_web]
      assert found(context, "dune", max_seeders: 3) == [:dune_hdcam, :prophecy3]

      assert found(context, "dune", min_seeders: 4, max_seeders: 899) ==
               [:dune_cam, :dunes, :prophecy4]

      assert found(context, "dune", min_seeders: 0) == Enum.sort(@dune)
    end

    test "age is a publication date at or after, at or before", %{now: now} = context do
      days_ago = &DateTime.add(now, -&1, :day)

      assert found(context, "dune", published_after: days_ago.(90)) == [:dune_uhd, :dune_web]
      assert found(context, "dune", published_before: days_ago.(1000)) == [:dune_hdcam, :dunes]

      assert found(context, "dune",
               published_after: days_ago.(300),
               published_before: days_ago.(200)
             ) ==
               [:dune_cam, :prophecy3, :prophecy4]
    end

    test "a date with less precision than the column still compares", %{now: now} = context do
      # Stored as ISO 8601 text, a cutoff without microseconds sorts after a
      # timestamp in the same second that has them, unless it is padded.
      cutoff = now |> DateTime.add(-60, :day) |> DateTime.truncate(:second)
      assert found(context, "dune", published_after: cutoff) == [:dune_uhd, :dune_web]

      assert found(context, "dune", published_before: cutoff) ==
               Enum.sort(@dune -- [:dune_uhd, :dune_web])
    end

    test "an empty range finds nothing, and does not raise", context do
      assert found(context, "dune", min_size: 2 * @gib, max_size: @gib) == []
      assert found(context, "dune", min_seeders: 10, max_seeders: 9) == []
    end

    test "a missing bound is no bound", context do
      assert found(context, "dune", min_size: nil, max_seeders: nil, published_after: nil) ==
               Enum.sort(@dune)
    end

    test "ranges combine with operators, the category and the sources", context do
      assert found(context, "dune -cam", min_size: 2 * @gib) == [:dune_uhd, :dune_web, :prophecy4]

      yts = Torrents.get_source_by_name!("YTS").id

      assert found(context, "dune -cam", min_size: 2 * @gib, source_ids: [yts]) ==
               [:dune_uhd, :dune_web, :prophecy4]

      assert found(context, "dune -cam", min_size: 2 * @gib, category_id: 5000) == []
    end

    test "ranges filter the latest list and its count with no search at all", %{labels: labels} do
      latest = &(Torrents.list_latest_torrents(&1) |> Enum.map(fn t -> labels[t.id] end))

      assert latest.(min_size: 40 * @gib) == [:wolf2]
      assert Torrents.count_torrents(min_size: 40 * @gib) == 1
      assert latest.(min_seeders: 1000) == [:dune_web]
      assert Torrents.count_torrents(min_seeders: 1000, max_seeders: 1000) == 0
      assert Torrents.count_torrents(min_seeders: nil) == map_size(@corpus)
    end
  end

  describe "source hits" do
    # A source can return a torrent whose text shares nothing with the search,
    # such as a translated title. It stands in for the plain words only: every
    # operator still applies to it.
    setup %{labels: labels} = context do
      duna =
        TorrentsFixtures.torrent_fixture(%{name: "Duna 2021 Dublado 2160p", description: nil})

      remux = TorrentsFixtures.torrent_fixture(%{name: "Duna Remux", description: nil})

      :ok = Torrents.record_search_hits("dune", duna.source_id, [duna.id])
      :ok = Torrents.record_search_hits("dune 2160p", duna.source_id, [duna.id])
      :ok = Torrents.record_search_hits("dune 1080p", remux.source_id, [remux.id])

      %{context | labels: Map.merge(labels, %{duna.id => :duna, remux.id => :remux})}
    end

    test "stand in for the plain words, after exclusions", context do
      assert :duna in found(context, "dune -cam")
      assert :duna not in found(context, "dune -duna")
      assert :duna not in found(context, "dune -dublado")
    end

    test "do not stand in for a phrase or a pattern", context do
      assert :duna not in found(context, ~s("dune"))
      assert :duna not in found(context, "dune*")
    end

    test "count for each alternative's own search, which must still match", context do
      found = found(context, "dune 2160p|1080p")
      assert :duna in found
      assert :remux not in found
    end

    test "do not count in titles only", context do
      assert :duna not in found(context, "dune", scope: :name)
    end

    test "rank after every text match" do
      ranked = Torrents.search_torrents(Query.parse("dune -cam"), limit: 100)
      assert [%{name: "Duna 2021 Dublado 2160p"} | _] = Enum.reverse(ranked)
    end
  end

  test "a plain query ranks the same through the parser and as plain text" do
    for text <- ["dune", "toy story 4", "dune part two 2", "seinfeld 1080p", "進撃", "up 4"] do
      parsed = Torrents.search_torrents(Query.parse(text), limit: 100)
      plain = Torrents.search_torrents(text, limit: 100)

      assert Enum.map(parsed, & &1.id) == Enum.map(plain, & &1.id), "for #{inspect(text)}"
    end
  end

  test "plain text keeps every operator as text, for Torznab" do
    names =
      &(Torrents.search_torrents(&1, limit: 100) |> Enum.map(fn t -> t.name end) |> Enum.sort())

    # "-cam" is the word "cam", a substring of HDCAM: nothing is excluded.
    assert names.("dune -cam") ==
             Enum.sort(["Dune 2021 HDCAM x264-GAP", "Dune Part Two 2024 CAM 720p x264"])

    assert names.("dune 2160p|1080p") == []
  end

  test "input that could break the SQL or FTS5 is searched safely" do
    hostile = [
      ~s("),
      ~s("""),
      ~s(-"),
      ~s(|"|),
      ~s(*"*),
      ~s(\\),
      "'",
      ~s(' OR 1=1 --),
      "NEAR(a b)",
      "{name}: dune",
      "name:dune",
      "description : dune",
      "dune^",
      "(",
      ")",
      ~s("a" OR "b"),
      "-(",
      "*-*",
      "||||",
      "-|-",
      ~s("-"),
      ~s("*"),
      ~s("|"),
      "dune\u0000cam",
      "🔥 dune 🔥",
      "é",
      "دون",
      "a" |> String.duplicate(10_000),
      "-" |> String.duplicate(1000),
      Enum.map_join(1..500, "|", &"w#{&1}"),
      Enum.map_join(1..500, " ", &"-w#{&1}"),
      Enum.map_join(1..200, " ", &"\"w#{&1} x\""),
      Enum.map_join(1..200, " ", &"w#{&1}*z"),
      "%",
      "_",
      "[a-z]*",
      "?",
      "dune [",
      "dune ]*",
      "s0?e1*",
      "**a**b**"
    ]

    for text <- hostile do
      query = Query.parse(text)
      torrents = Torrents.search_torrents(query, limit: 100)
      assert Torrents.count_search_torrents(query) == length(torrents), "for #{inspect(text)}"
      assert is_list(Torrents.search_torrents(text)), "for #{inspect(text)} as plain text"
    end
  end

  test "glob characters in a pattern are punctuation, never glob syntax" do
    TorrentsFixtures.torrent_fixture(%{name: "Question? Mark [Remastered]", description: nil})

    assert Torrents.count_search_torrents(Query.parse("q*ion")) == 1
    assert Torrents.count_search_torrents(Query.parse("ques*[remastered]")) == 1
    # As a GLOB class, "[a-z]" would match the "q" of "Question".
    assert Torrents.count_search_torrents(Query.parse("[a-z]uestion*")) == 0
  end
end
