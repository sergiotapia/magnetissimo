defmodule Magnetissimo.Torrents.SearchTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Torrents
  alias Magnetissimo.Torrents.Search
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  defp fixture(name, attrs \\ %{}) do
    TorrentsFixtures.torrent_fixture(Map.merge(%{name: name, description: nil}, attrs))
  end

  defp names(term, opts \\ []), do: term |> Torrents.search_torrents(opts) |> Enum.map(& &1.name)

  describe "tokens/1" do
    test "splits on punctuation and sends each token to the index that answers it" do
      assert Search.tokens("Spider-Man: of 2 進撃 進撃の巨人") == [
               {:trigram, "Spider"},
               {:trigram, "Man"},
               {:word, "of"},
               {:word, "2"},
               {:substring, "進撃"},
               {:trigram, "進撃の巨人"}
             ]
    end

    test "has nothing to search for in punctuation alone" do
      assert Search.tokens(~s(" *** -- ")) == []
      assert Search.matches("   ") == nil
    end
  end

  test "normalize/1 lowercases and collapses whitespace" do
    assert Search.normalize("  Dune   PART\tTwo ") == "dune part two"
  end

  test "a short token narrows the match instead of being dropped" do
    fixture("Toy.Story.4.2019.1080p")
    fixture("Toy Story 3 (2010)")
    fixture("Toy Story (1995) x264")

    assert names("toy story 4") == ["Toy.Story.4.2019.1080p"]
  end

  test "a query of only short tokens matches whole words" do
    fixture("Up (2009) 4K HDR")
    fixture("Upgrade (2018)")
    fixture("Uncharted 480p")

    assert names("up 4k") == ["Up (2009) 4K HDR"]
    assert names("4k") == ["Up (2009) 4K HDR"]
  end

  test "the last short token is a prefix while it is being typed" do
    fixture("Dune Part Two 480p")
    fixture("Dune Part Two 1080p")

    assert names("dune part two 4") == ["Dune Part Two 480p"]
  end

  test "punctuation in the query matches any separator in the name" do
    fixture("Spider.Man.No.Way.Home.2021")

    assert names("spider-man") == ["Spider.Man.No.Way.Home.2021"]
    assert names("spider man no way") == ["Spider.Man.No.Way.Home.2021"]
  end

  test "a long token matches inside a word and inside unspaced scripts" do
    fixture("[SubsPlease] Sousou no Frieren - 28")
    fixture("進撃の巨人 The Final Season")

    assert names("frier") == ["[SubsPlease] Sousou no Frieren - 28"]
    assert names("巨人") == ["進撃の巨人 The Final Season"]
    assert names("撃の巨") == ["進撃の巨人 The Final Season"]
  end

  test "query syntax in the input is searched as text" do
    fixture("ubuntu-24.04-desktop-amd64.iso")
    fixture("Not Okay (2022)")

    assert names("ubuntu:24.04") == ["ubuntu-24.04-desktop-amd64.iso"]
    assert names("NOT") == ["Not Okay (2022)"]
    assert names("x265-") == []
    assert names("foo(bar") == []
  end

  test "a name match outranks a description match" do
    fixture("Some Other Movie", %{description: "A heist goes wrong."})
    fixture("Heist (2015)")

    assert names("heist") == ["Heist (2015)", "Some Other Movie"]
  end

  test "seeders decide between equally good names, but capped" do
    fixture("Matrix 720p", %{seeders: 5})
    fixture("Matrix 2160", %{seeders: 900})
    fixture("Matrix 1080", %{seeders: 16_777_215})

    assert names("matrix") == ["Matrix 1080", "Matrix 2160", "Matrix 720p"]
  end

  test "torrents a source returned for the term match even without the words" do
    hit = fixture("Spider-Man: Across the Spider-Verse (2023)")
    fixture("Unrelated (2020)")

    assert names("spiderverse") == []

    :ok = Torrents.record_search_hits("SpiderVerse ", [hit.id])

    assert names("spiderverse") == ["Spider-Man: Across the Spider-Verse (2023)"]
    assert Torrents.count_search_torrents("spiderverse") == 1
  end

  test "a source hit that also matches the text is counted once, ranked as text" do
    text = fixture("Heat (1995)", %{seeders: 1})
    hit_only = fixture("Michael Mann Collection", %{seeders: 10_000})

    :ok = Torrents.record_search_hits("heat", [text.id, hit_only.id])

    # A source hit with no text match ranks last, however well seeded.
    fixture("Heat Wave", %{seeders: 1})
    assert ["Heat" <> _, "Heat" <> _, "Michael Mann Collection"] = names("heat")
    assert Torrents.count_search_torrents("heat") == 3
  end

  test "the category filter and paging run in SQL, so every page is full" do
    for n <- 1..6, do: fixture("Gamma Show #{n}", %{category: "Anime - Raw", seeders: n})
    for n <- 1..6, do: fixture("Gamma Movie #{n}", %{seeders: 100 + n})

    category = Torrents.get_category_by_name_or_alias!("Anime - Raw")
    opts = [category_id: category.id]

    assert Torrents.count_search_torrents("gamma", opts) == 6
    assert names("gamma", [{:limit, 4} | opts]) == Enum.map(6..3//-1, &"Gamma Show #{&1}")
    assert names("gamma", opts ++ [limit: 4, offset: 4]) == ["Gamma Show 2", "Gamma Show 1"]
  end
end
