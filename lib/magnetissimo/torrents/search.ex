defmodule Magnetissimo.Torrents.Search do
  @moduledoc """
  Turns free text into the SQL that finds matching torrents, best first.

  Two FTS5 indexes cover `torrents.name` and `torrents.description`, and each
  token in a search goes to the one that can answer it:

    * `torrents_search` uses the trigram tokenizer, so a token of three
      characters or more is a substring match in any script. That is what makes
      a fragment of a Japanese title, which has no spaces to split on, findable.
    * `torrents_words` uses `unicode61` and holds whole words. A trigram index
      cannot answer a token shorter than three characters, so "4" in
      "toy story 4", "of" in "last of us" and all of "4k" go here.
    * A short token in a script written without spaces (CJK, Thai) is neither a
      word nor a trigram, so it is a plain substring test on the name.

  The query text is split on anything that is not a letter, digit or mark,
  the same way `unicode61` splits a name. "spider-man" therefore finds
  "Spider.Man.2002", which a substring search for the literal "spider-man"
  would miss.

  Torrents a source returned for this exact term (see `search_hits`) are
  matches too, even when their text has nothing in common with it. They rank
  after every text match.

  Ranking is bm25 with a name match worth ten description matches, scaled up
  by how well seeded the torrent is: among near-identical names the one people
  can actually download comes first. The scale is logarithmic and capped at
  10,000 seeders, about 1.9x, so seeders break ties without burying a better
  text match, and one source reporting a nonsense count cannot game it.
  """

  @type token :: {:trigram | :word | :substring, String.t()}

  # Scripts written without spaces between words.
  @unspaced ~r/[\p{Han}\p{Hiragana}\p{Katakana}\p{Hangul}\p{Thai}]/u

  @doc """
  Normalises a term for use as a key: lowercase, single spaces, trimmed.

  `search_hits` rows and the in-flight source searches are keyed by this, so
  "Dune  2" and "dune 2" are the same search.
  """
  @spec normalize(String.t()) :: String.t()
  def normalize(term) when is_binary(term) do
    term |> String.downcase() |> String.split() |> Enum.join(" ")
  end

  @doc """
  Splits a term into the tokens the search asks for, each tagged with the
  index that answers it. The last token is the one still being typed.
  """
  @spec tokens(String.t()) :: [token]
  def tokens(term) when is_binary(term) do
    ~r/[^\p{L}\p{N}\p{M}]+/u
    |> Regex.split(term, trim: true)
    |> Enum.map(&classify/1)
  end

  defp classify(token) do
    cond do
      String.length(token) >= 3 -> {:trigram, token}
      Regex.match?(@unspaced, token) -> {:substring, token}
      true -> {:word, token}
    end
  end

  @doc """
  Returns the SQL for a `matches(id, score)` common table expression and its
  parameters, or `nil` when the term has nothing to search for.

  A lower score is a better match. Callers join `matches` onto `torrents`.
  """
  @spec matches(String.t()) :: {String.t(), list()} | nil
  def matches(term) when is_binary(term) do
    case tokens(term) do
      [] ->
        nil

      tokens ->
        {text_sql, text_params} = text_matches(tokens)

        sql = """
        matches(id, score) AS (
          SELECT id, min(score) FROM (
            SELECT torrent_id AS id, 0.0 AS score FROM search_hits WHERE term = ?
            UNION ALL
            #{text_sql}
          )
          GROUP BY id
        )
        """

        {sql, [normalize(term) | text_params]}
    end
  end

  @doc "The `ORDER BY` terms for a query joining `matches m` onto `torrents t`."
  @spec order_by() :: String.t()
  def order_by do
    "m.score * (1.0 + ln(1.0 + min(t.seeders, 10000)) / 10.0), t.seeders DESC, t.id DESC"
  end

  # One index drives the query and scores it; every other kind of token
  # narrows it. The trigram index drives when it can, because its bm25 sees
  # the longest and most specific tokens.
  defp text_matches(tokens) do
    trigrams = for {:trigram, t} <- tokens, do: t
    words = for {:word, t} <- tokens, do: t
    # Lowercased to match `lower(name)`, as the FTS indexes ignore case too.
    # SQLite's lower() folds only ASCII, which is all that a short token in
    # an unspaced script can mix in ("a版").
    substrings = for {:substring, t} <- tokens, do: String.downcase(t)
    # The token still being typed is a prefix, which only a word query needs:
    # a trigram phrase is already a substring match.
    prefix? = match?([{:word, _} | _], Enum.reverse(tokens))

    {base, base_params, words, substrings} =
      cond do
        trigrams != [] ->
          {fts("torrents_search"), [phrases(trigrams, false)], words, substrings}

        words != [] ->
          {fts("torrents_words"), [phrases(words, prefix?)], [], substrings}

        true ->
          [first | rest] = substrings

          {"SELECT id, 0.0 AS score FROM torrents WHERE instr(lower(name), ?) > 0", [first], [],
           rest}
      end

    {word_sql, word_params} =
      case words do
        [] ->
          {"", []}

        words ->
          {"AND rowid IN (SELECT rowid FROM torrents_words WHERE torrents_words MATCH ?)",
           [phrases(words, prefix?)]}
      end

    substring_sql =
      Enum.map_join(substrings, "\n", fn _ ->
        "AND rowid IN (SELECT id FROM torrents WHERE instr(lower(name), ?) > 0)"
      end)

    {Enum.join([base, word_sql, substring_sql], "\n"), base_params ++ word_params ++ substrings}
  end

  # bm25's weights must be literals: 10x for name, 1x for description. The
  # table is named in full because MATCH does not accept an alias.
  defp fts(table) do
    "SELECT rowid AS id, bm25(#{table}, 10.0, 1.0) AS score FROM #{table} WHERE #{table} MATCH ?"
  end

  # Every token is quoted. FTS5 parses MATCH as a query language, so bare
  # input such as `NOT`, `foo(bar)` or `x265-` is a syntax error or an
  # operator; quoted, it is just text. Splitting on punctuation already removes
  # most of that, and the quoting covers what is left.
  defp phrases(tokens, prefix?) do
    quoted = Enum.map(tokens, &~s("#{String.replace(&1, "\"", "\"\"")}"))
    quoted = if prefix?, do: List.update_at(quoted, -1, &(&1 <> "*")), else: quoted

    Enum.join(quoted, " ")
  end
end
