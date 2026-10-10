defmodule Magnetissimo.Torrents.QueryTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.Torrents.Query

  defp parse(text), do: Query.parse(text)

  defp clauses(text), do: parse(text).clauses
  defp excludes(text), do: parse(text).excludes

  describe "parse/1 with plain words" do
    test "each word is its own clause, as typed" do
      assert clauses("Dune part two") == [
               [{:words, "Dune"}],
               [{:words, "part"}],
               [{:words, "two"}]
             ]

      assert parse("  dune \t  part ") == parse("dune part")
    end

    test "punctuation inside a word is part of the word, not an operator" do
      assert clauses("spider-man x265- ubuntu:24.04 S.H.I.E.L.D.") == [
               [{:words, "spider-man"}],
               [{:words, "x265-"}],
               [{:words, "ubuntu:24.04"}],
               [{:words, "S.H.I.E.L.D."}]
             ]
    end

    test "FTS5's own operators are just words" do
      assert clauses("NOT AND OR NEAR") ==
               [[{:words, "NOT"}], [{:words, "AND"}], [{:words, "OR"}], [{:words, "NEAR"}]]
    end

    test "a chunk with nothing searchable in it is dropped" do
      assert clauses("dune : ... ( ) !") == [[{:words, "dune"}]]
    end

    test "nothing to search for is empty" do
      for text <- [
            "",
            "   ",
            "\t\n",
            ":",
            "...",
            "-",
            "--",
            "- -",
            "|",
            "||",
            " | | ",
            "*",
            "**",
            "-*",
            ~s(""),
            ~s("   "),
            ~s(-""),
            ~s("--"),
            ~s("),
            "“”"
          ] do
        assert Query.empty?(parse(text)), "expected #{inspect(text)} to be empty"
        assert Query.remote_terms(parse(text)) == []
      end
    end

    test "is not empty with a word in it" do
      refute Query.empty?(parse("dune"))
      refute Query.empty?(parse("-cam"))
    end
  end

  describe "parse/1 with phrases" do
    test "quotes make a phrase, with its words as typed" do
      assert clauses(~s(dune "part two")) == [[{:words, "dune"}], [{:phrase, "part two"}]]
    end

    test "an unclosed quote runs to the end of the input" do
      assert clauses(~s(dune "part two)) == [[{:words, "dune"}], [{:phrase, "part two"}]]
    end

    test "curly quotes from a phone keyboard are quotes too" do
      assert clauses("“part two” dune") == [[{:phrase, "part two"}], [{:words, "dune"}]]
      assert clauses("„part two“") == [[{:phrase, "part two"}]]
    end

    test "a quote ends the word before it" do
      assert clauses(~s(dune"part two"2024)) ==
               [[{:words, "dune"}], [{:phrase, "part two"}], [{:words, "2024"}]]
    end

    test "operators inside a phrase are text" do
      assert clauses(~s("-cam | s01e* x")) == [[{:phrase, "-cam | s01e* x"}]]
    end

    test "an empty phrase is dropped" do
      assert clauses(~s(dune "" "  " "--")) == [[{:words, "dune"}]]
    end

    test "surrounding whitespace in a phrase is trimmed" do
      assert clauses(~s("  part two  ")) == [[{:phrase, "part two"}]]
    end
  end

  describe "parse/1 with exclusions" do
    test "a leading dash excludes a word" do
      assert parse("dune -cam").clauses == [[{:words, "dune"}]]
      assert excludes("dune -cam") == [{:words, "cam"}]
    end

    test "several dashes are one" do
      assert excludes("dune --cam") == [{:words, "cam"}]
    end

    test "a dash on its own is ignored, not an exclusion of the next word" do
      assert clauses("dune - cam") == [[{:words, "dune"}], [{:words, "cam"}]]
      assert excludes("dune - cam") == []
    end

    test "only an ASCII hyphen excludes; a dash a keyboard typed is punctuation" do
      assert excludes("dune –cam —cam") == []

      assert clauses("dune –cam —cam") == [
               [{:words, "dune"}],
               [{:words, "–cam"}],
               [{:words, "—cam"}]
             ]
    end

    test "a dash before a quote excludes the phrase" do
      assert excludes(~s(seinfeld -"web dl")) == [{:phrase, "web dl"}]
    end

    test "a dash before a wildcard excludes the pattern" do
      assert excludes("dune -s01e*") == [{:wildcard, "s01e*"}]
    end

    test "an exclusion keeps its inner punctuation" do
      assert excludes("seinfeld -web-dl") == [{:words, "web-dl"}]
    end

    test "only exclusions is still a query" do
      query = parse("-cam -ts")
      assert query.clauses == []
      assert query.excludes == [{:words, "cam"}, {:words, "ts"}]
    end

    test "the same exclusion twice is kept once" do
      assert excludes("-cam dune -CAM") == [{:words, "cam"}]
    end
  end

  describe "parse/1 with alternatives" do
    test "a bar joins words into one clause, with or without spaces" do
      expected = [[{:words, "dune"}], [{:words, "2160p"}, {:words, "4k"}]]

      for text <- [
            "dune 2160p|4k",
            "dune 2160p | 4k",
            "dune 2160p |4k",
            "dune 2160p| 4k",
            "dune 2160p || 4k",
            "dune 2160p | | 4k"
          ] do
        assert clauses(text) == expected, "for #{inspect(text)}"
      end
    end

    test "a bar binds tighter than the space between words" do
      assert clauses("dune 2160p|4k remux") ==
               [[{:words, "dune"}], [{:words, "2160p"}, {:words, "4k"}], [{:words, "remux"}]]
    end

    test "a chain of bars is one clause" do
      assert clauses("a1|b2|c3") == [[{:words, "a1"}, {:words, "b2"}, {:words, "c3"}]]
    end

    test "phrases and wildcards can be alternatives" do
      assert clauses(~s("part two"|"part 2"|s01e*)) ==
               [[{:phrase, "part two"}, {:phrase, "part 2"}, {:wildcard, "s01e*"}]]
    end

    test "a bar with nothing on one side is ignored" do
      assert clauses("| dune |") == [[{:words, "dune"}]]
      assert clauses("dune | * | 4k") == [[{:words, "dune"}, {:words, "4k"}]]
    end

    test "an exclusion never joins an alternative" do
      for text <- ["dune | -cam", "-cam | dune", "dune|-cam"] do
        assert clauses(text) == [[{:words, "dune"}]], "for #{inspect(text)}"
        assert excludes(text) == [{:words, "cam"}], "for #{inspect(text)}"
      end

      assert clauses("dune | -cam | 4k") == [[{:words, "dune"}], [{:words, "4k"}]]
    end

    test "the same alternative twice is kept once, and one left is a plain clause" do
      assert clauses("Dune|dune") == [[{:words, "Dune"}]]
      assert clauses("4k|2160p|4K") == [[{:words, "4k"}, {:words, "2160p"}]]
    end

    test "a bar in an unspaced script splits it" do
      assert clauses("進撃|拉拉熊") == [[{:words, "進撃"}, {:words, "拉拉熊"}]]
    end

    test "a full-width bar is punctuation, not an operator" do
      assert clauses("進撃｜拉拉熊") == [[{:words, "進撃｜拉拉熊"}]]
    end
  end

  describe "parse/1 with wildcards" do
    test "a star anywhere in a word makes it a pattern" do
      assert clauses("seinfeld s05e1* *265 s0*e14") == [
               [{:words, "seinfeld"}],
               [{:wildcard, "s05e1*"}],
               [{:wildcard, "*265"}],
               [{:wildcard, "s0*e14"}]
             ]
    end

    test "a star with nothing around it is dropped" do
      assert clauses("dune * ** ***") == [[{:words, "dune"}]]
    end
  end

  describe "typing?" do
    test "is true while the last thing typed is a plain word" do
      assert parse("dune 4").typing?
      assert parse("dune |").typing?
      assert Query.plain("dune -cam").typing?
    end

    test "is false once the last thing is an operator" do
      refute parse(~s(dune "4")).typing?
      refute parse("dune -4").typing?
      refute parse("dune 2160p|4").typing?
      refute parse("dune s01e*").typing?
      refute parse("").typing?
    end
  end

  test "a query too long to be typed is cut to its first atoms" do
    words = Enum.map_join(1..500, " | ", &"w#{&1}")
    query = parse(words <> " -cam")

    assert [alternatives] = query.clauses
    assert length(alternatives) == Query.max_atoms()
    assert query.excludes == []
  end

  describe "plain/1" do
    test "is the whole text as one clause of words, operators and all" do
      assert Query.plain(~s( dune -cam "part|two" )).clauses == [
               [{:words, ~s(dune -cam "part|two")}]
             ]

      assert Query.plain(~s( dune -cam )).excludes == []
    end

    test "with nothing to search for is empty" do
      assert Query.empty?(Query.plain(" -- | * "))
    end
  end

  describe "remote_terms/1" do
    test "plain words go to the sites as typed" do
      assert Query.remote_terms(parse("Dune  Part Two")) == ["Dune Part Two"]
      assert Query.remote_terms(parse("spider-man ubuntu:24.04")) == ["spider-man ubuntu:24.04"]
    end

    test "a phrase goes as its words, without the quotes" do
      assert Query.remote_terms(parse(~s(dune "part two"))) == ["dune part two"]
      assert Query.remote_terms(parse(~s(“part two”))) == ["part two"]
    end

    test "an exclusion never reaches a site" do
      assert Query.remote_terms(parse(~s(dune -cam -"web dl" -s01e*))) == ["dune"]
      assert Query.remote_terms(parse("-cam")) == []
    end

    test "a wildcard never reaches a site, nor does a clause it is an alternative in" do
      assert Query.remote_terms(parse("breaking bad s05e*")) == ["breaking bad"]
      assert Query.remote_terms(parse("dune s01e*|remux")) == ["dune"]
      assert Query.remote_terms(parse("s01e*")) == []
    end

    test "each alternative is its own search, in the order typed" do
      assert Query.remote_terms(parse("dune 2160p|4k")) == ["dune 2160p", "dune 4k"]

      assert Query.remote_terms(parse("dune 2160p|4k remux")) ==
               ["dune 2160p remux", "dune 4k remux"]

      assert Query.remote_terms(parse(~s(dune "part two"|"part 2"))) ==
               ["dune part two", "dune part 2"]
    end

    test "up to max_remote_terms searches, then only the words every one shares" do
      assert Query.max_remote_terms() == 3
      assert Query.remote_terms(parse("dune a1|b2|c3")) == ["dune a1", "dune b2", "dune c3"]
      assert Query.remote_terms(parse("dune a1|b2|c3|d4")) == ["dune"]
      assert Query.remote_terms(parse("dune a1|b2 c3|d4")) == ["dune"]
      assert Query.remote_terms(parse("a1|b2 c3|d4")) == []
    end

    test "a long chain of alternatives is not expanded to count it" do
      text = Enum.map_join(1..16, " ", &"a#{&1}|b#{&1}")
      assert Query.remote_terms(parse(text)) == []
    end

    test "the same search twice is asked once" do
      assert Query.remote_terms(parse(~s(dune "4k"|4k))) == ["dune 4k"]
    end

    test "plain/1 sends the text as typed" do
      assert Query.remote_terms(Query.plain(" dune -cam ")) == ["dune -cam"]
    end
  end
end
