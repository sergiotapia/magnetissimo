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

  The operators a `Magnetissimo.Torrents.Query` holds are matched in two
  steps. The words the query needs outright, including the longer words of
  quoted text and of a pattern, are searched as above: that finds a superset of the
  answer and ranks it. Each operator then narrows it with a condition of its
  own, chosen so that what it means survives how names are written:

    * Quoted text is those exact characters, punctuation and spaces
      included: `"[ToonsHub]"` needs the brackets, and `"part two"` does not
      find "Part.Two". The trigram index answers it as a substring, ignoring
      case and accents.
    * An unquoted exclusion is a whole word, or for `-web-dl` the words it
      spells side by side across any separator, in `torrents_words`. It is
      never a substring.
    * A pattern that ends a word with a star is a prefix query on
      `torrents_words`. Any other is a GLOB on the lowercased text, which,
      unlike the indexes, does not fold accents or non-ASCII case.
    * A source hit stands in for the plain words only. Every operator still
      applies to it, and a search of names only ignores hits.

  Ranking is bm25 with a name match worth ten description matches, scaled up
  by how well seeded the torrent is: among near-identical names the one people
  can actually download comes first. The scale is logarithmic and capped at
  10,000 seeders, about 1.9x, so seeders break ties without burying a better
  text match, and one source reporting a nonsense count cannot game it.
  """

  alias Magnetissimo.Torrents.Query

  @type token :: {:trigram | :word | :substring, String.t()}

  @typedoc "Where text must match: names and descriptions, or names only."
  @type scope :: :all | :name

  @typedoc "A column to order by instead of the best match, and which way."
  @type sort :: {:name | :size_in_bytes | :seeders | :published_at, :asc | :desc}

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
  Returns the SQL for common table expressions ending in `matches(id, score)`,
  and their parameters, or `nil` when there is nothing to search for.

  Takes a `t:Magnetissimo.Torrents.Query.t/0`, or plain text, which is read
  with `Magnetissimo.Torrents.Query.plain/1`.

  A lower score is a better match. Callers join `matches` onto `torrents`.

  ## Options

    * `:scope` - `:all` (the default) to match names and descriptions, or
      `:name` for names only
    * `:rank` - `false` when nothing will order by the score, as in a count
      or a sort by a column: every score is then 0.0, and bm25, which is
      most of what a search of a common word costs, is never computed.
      `true` by default
  """
  @spec matches(Query.t() | String.t(), keyword()) :: {String.t(), list()} | nil
  def matches(query, opts \\ [])

  def matches(term, opts) when is_binary(term), do: matches(Query.plain(term), opts)

  def matches(%Query{} = query, opts) do
    scope = Keyword.get(opts, :scope, :all)
    rank? = Keyword.get(opts, :rank, true)

    if Query.empty?(query) do
      nil
    else
      tokens = driver_tokens(query)
      strict = strict(query, scope)

      case driver(tokens, query, scope, rank?) do
        :every_torrent -> every_torrent(strict)
        driver -> narrowed(driver, hits(query, tokens, scope), strict)
      end
    end
  end

  # Every torrent is a candidate, so the operators are tested as the table is
  # read, rather than on a copy of all its ids joined back to it.
  defp every_torrent({where_sql, where_params}) do
    {"matches(id, score) AS (\n  SELECT t.id, 0.0 AS score FROM torrents t WHERE #{where_sql}\n)\n",
     where_params}
  end

  defp narrowed({driver_sql, driver_params}, {hits_sql, hits_params}, strict) do
    # The operators read the name and description only for a short
    # substring or a pattern. Every other one tests the id against an index,
    # so the candidates, which hold it, stand in for `torrents t`.
    {from_sql, u, where_sql, where_params} =
      case strict do
        {"TRUE", []} ->
          {"candidates AS u", "u", "", []}

        {sql, params} ->
          if String.contains?(sql, ["t.name", "t.description"]),
            do: {"candidates AS u JOIN torrents t ON t.id = u.id", "u", "WHERE #{sql}", params},
            else: {"candidates AS t", "t", "WHERE #{sql}", params}
      end

    # A torrent can be both a source hit and a text match. Without hits,
    # every candidate is a different torrent, and there is nothing to group.
    {score_sql, group_sql} =
      if hits_sql == "",
        do: {"#{u}.score", ""},
        else: {"min(#{u}.score)", "GROUP BY #{u}.id"}

    # The candidates are materialized before the operators join them to
    # `torrents`: flattened into that join, bm25 loses the FTS5 query it
    # scores and refuses to run. Unranked, it would run, but SQLite could
    # then look each torrent up in FTS5 one id at a time (see
    # `text_matches/4`).
    sql = """
    candidates(id, score) AS MATERIALIZED (
      #{hits_sql}
      #{driver_sql}
    ),
    matches(id, score) AS (
      SELECT #{u}.id, #{score_sql} FROM #{from_sql}
      #{where_sql}
      #{group_sql}
    )
    """

    {sql, hits_params ++ driver_params ++ where_params}
  end

  @doc """
  The `ORDER BY` terms for a query joining `matches m` onto `torrents t`:
  best match first, or by the column a `t:sort/0` names. Names compare
  without regard to case, so "alien" does not sort after "Zodiac".
  """
  @spec order_by(sort() | nil) :: String.t()
  def order_by(nil) do
    "m.score * (1.0 + ln(1.0 + min(t.seeders, 10000)) / 10.0), t.seeders DESC, t.id DESC"
  end

  def order_by({:name, dir}), do: "t.name COLLATE NOCASE #{direction(dir)}, t.id DESC"

  def order_by({field, dir}) when field in [:size_in_bytes, :seeders, :published_at] do
    "t.#{field} #{direction(dir)}, t.id DESC"
  end

  defp direction(:asc), do: "ASC"
  defp direction(:desc), do: "DESC"

  # The driver finds and scores the candidates; `strict/2` then holds them to
  # every operator. It searches every word the query must match outright
  # (plain words, and the longer words of quoted text and patterns) as plain
  # tokens, which finds a superset of what the operators allow and lets bm25
  # rank it. A query of nothing but alternatives and exclusions has no such
  # words: see `alternatives/2`.
  defp driver_tokens(%Query{clauses: clauses}) do
    for [atom] <- clauses, token <- driver_tokens(atom), do: token
  end

  defp driver_tokens({:words, text}), do: tokens(text)
  # A trigram is a substring, which takes in any quoted text or pattern it is
  # part of; a whole word would not.
  defp driver_tokens({kind, text}) when kind in [:phrase, :wildcard] do
    Enum.filter(tokens(text), &match?({:trigram, _}, &1))
  end

  defp driver([], query, scope, _rank?), do: alternatives(query, scope)
  defp driver(tokens, query, scope, rank?), do: text_matches(tokens, query.typing?, scope, rank?)

  # With no word it needs outright, a query starts from what any alternative
  # of one clause finds, when each has a word an index can find: everything
  # the clause allows is in there, and the operators then hold it to the
  # rest. Scanning every torrent instead took "s05e13|s05e14" 80 ms on
  # 250,000 torrents. A clause with an alternative only a scan can answer,
  # such as "x*" or a short unspaced word, and a query of nothing but
  # exclusions, still start from every torrent. Nothing scores these, as
  # before: the seeders rank them.
  defp alternatives(%Query{clauses: clauses}, scope) do
    Enum.find_value(clauses, :every_torrent, fn clause ->
      atom_tokens = Enum.map(clause, &driver_tokens/1)

      if Enum.all?(atom_tokens, &indexed?/1) do
        parts = Enum.map(atom_tokens, &text_matches(&1, false, scope, false))

        {"SELECT id, score FROM (\n" <> Enum.map_join(parts, "\nUNION\n", &elem(&1, 0)) <> "\n)",
         Enum.flat_map(parts, &elem(&1, 1))}
      end
    end)
  end

  defp indexed?(tokens), do: Enum.any?(tokens, &match?({kind, _} when kind != :substring, &1))

  # Torrents a source returned for one of the searches it was asked. They
  # stand in for the driver's words, and are held to the operators like any
  # other match. A source's answer says nothing about which words are in the
  # name, so a search of names only leaves them out.
  defp hits(query, tokens, :all) when tokens != [] do
    case Enum.map(Query.remote_terms(query), &normalize/1) do
      [] ->
        {"", []}

      terms ->
        marks = Enum.map_join(terms, ", ", fn _ -> "?" end)

        {"SELECT torrent_id AS id, 0.0 AS score FROM search_hits WHERE term IN (#{marks})\nUNION ALL",
         terms}
    end
  end

  defp hits(_query, _tokens, _scope), do: {"", []}

  # One index drives the query and scores it; every other kind of token
  # narrows it. The trigram index drives when it can, because its bm25 sees
  # the longest and most specific tokens.
  defp text_matches(tokens, typing?, scope, score?) do
    trigrams = for {:trigram, t} <- tokens, do: t
    words = for {:word, t} <- tokens, do: t
    # Lowercased to match `lower(name)`, as the FTS indexes ignore case too.
    # SQLite's lower() folds only ASCII, which is all that a short token in
    # an unspaced script can mix in ("a版").
    substrings = for {:substring, t} <- tokens, do: String.downcase(t)
    # The token still being typed is a prefix, which only a word query needs:
    # a trigram phrase is already a substring match.
    prefix? = typing? and match?([{:word, _} | _], Enum.reverse(tokens))

    {base, base_params, words, substrings} =
      base(trigrams, words, substrings, prefix?, scope, score?)

    # `+rowid`, not `rowid`: given a plain `rowid IN (…)`, SQLite hands each
    # id in the list to FTS5, which then runs its whole MATCH once per id.
    # "toy story 4" took 1.7 seconds that way on 250,000 torrents, as every
    # name with a "4" in it re-ran "toy story". The unary plus keeps the list
    # out of FTS5, so its MATCH runs once and each row is looked up in the
    # list.
    {word_sql, word_params} =
      case words do
        [] ->
          {"", []}

        words ->
          {"AND +rowid IN (SELECT rowid FROM torrents_words WHERE torrents_words MATCH ?)",
           [in_scope(scope, phrases(words, prefix?))]}
      end

    substring_sql =
      Enum.map_join(substrings, "\n", fn substring ->
        "AND +rowid IN (SELECT id FROM torrents WHERE instr(#{folded("name", substring)}, ?) > 0)"
      end)

    {Enum.join([base, word_sql, substring_sql], "\n"), base_params ++ word_params ++ substrings}
  end

  # The query that drives, its parameters, and the words and substrings left
  # over to narrow it.
  defp base([_ | _] = trigrams, words, substrings, _prefix?, scope, score?) do
    {fts("torrents_search", score?), [in_scope(scope, phrases(trigrams, false))], words,
     substrings}
  end

  defp base([], [_ | _] = words, substrings, prefix?, scope, score?) do
    {fts("torrents_words", score?), [in_scope(scope, phrases(words, prefix?))], [], substrings}
  end

  defp base([], [], [first | rest], _prefix?, _scope, _score?) do
    {"SELECT id, 0.0 AS score FROM torrents WHERE instr(#{folded("name", first)}, ?) > 0",
     [first], [], rest}
  end

  # bm25's weights must be literals: 10x for name, 1x for description. The
  # table is named in full because MATCH does not accept an alias.
  defp fts(table, true) do
    "SELECT rowid AS id, bm25(#{table}, 10.0, 1.0) AS score FROM #{table} WHERE #{table} MATCH ?"
  end

  defp fts(table, false) do
    "SELECT rowid AS id, 0.0 AS score FROM #{table} WHERE #{table} MATCH ?"
  end

  # Every token is quoted. FTS5 parses MATCH as a query language, so bare
  # input such as `NOT`, `foo(bar)` or `x265-` is a syntax error or an
  # operator; quoted, it is just text. Splitting on punctuation already removes
  # most of that, and the quoting covers what is left.
  defp phrases(tokens, prefix?) do
    quoted = Enum.map(tokens, &quote_fts/1)
    quoted = if prefix?, do: List.update_at(quoted, -1, &(&1 <> "*")), else: quoted

    Enum.join(quoted, " ")
  end

  defp quote_fts(text), do: ~s("#{String.replace(text, "\"", "\"\"")}")

  # An FTS5 column filter. Both indexes have the columns `name, description`.
  defp in_scope(:all, expression), do: expression
  defp in_scope(:name, expression), do: "name : (#{expression})"

  ## The operators

  # Everything the driver cannot say: quoted text, patterns, alternatives and
  # exclusions. Plain words need nothing here, since the driver or a source
  # hit already answered for them. One condition on `torrents t`, or `TRUE`
  # when there is nothing to hold the candidates to.
  defp strict(%Query{clauses: clauses, excludes: excludes}, scope) do
    required =
      for clause <- clauses, not match?([{:words, _}], clause) do
        any(Enum.map(clause, &atom_condition(&1, scope)))
      end

    excluded = for atom <- excludes, do: negate(excluded_condition(atom, scope))

    case required ++ excluded do
      [] -> {"TRUE", []}
      conditions -> all(conditions)
    end
  end

  # Plain words as an alternative mean what they mean in the driver.
  defp atom_condition({:words, text}, scope) do
    text |> tokens() |> Enum.map(&token_condition(&1, scope)) |> all()
  end

  defp atom_condition({:phrase, text}, scope), do: literal_condition(text, scope)
  defp atom_condition({:wildcard, text}, scope), do: wildcard_condition(text, scope)

  # An excluded word is a whole word, not a substring, or "-cam" would take
  # out "El Camino" and every "HDCAM". One with punctuation in it, such as
  # "-web-dl", is the phrase it spells.
  defp excluded_condition({:words, text}, scope), do: phrase_condition(text, scope)
  defp excluded_condition(atom, scope), do: atom_condition(atom, scope)

  defp token_condition({:trigram, token}, scope), do: in_index("torrents_search", token, scope)
  defp token_condition({:word, token}, scope), do: in_index("torrents_words", token, scope)
  defp token_condition({:substring, token}, scope), do: contains(token, scope)

  # Quoted text is exactly those characters, punctuation and spaces and all.
  # The trigram index holds every character, so it answers that as a
  # substring, ignoring case and accents as it always does. Text too short
  # for a trigram is compared lowercased, which folds only ASCII.
  defp literal_condition(text, scope) do
    if String.length(text) >= 3,
      do: in_fts("torrents_search", quote_fts(text), scope),
      else: contains(text, scope)
  end

  # The word index splits a name the way `tokens/1` splits the text, so a
  # phrase there is its words in order, across any separator. A script
  # written without spaces is one long word to that index, and its words are
  # matched as substrings instead, which loses their order.
  defp phrase_condition(text, scope) do
    words = for {_kind, word} <- tokens(text), do: word

    if Enum.any?(words, &unspaced?/1) do
      words |> Enum.map(&word_condition(&1, scope)) |> all()
    else
      in_fts("torrents_words", quote_fts(Enum.join(words, " ")), scope)
    end
  end

  defp word_condition(word, scope) do
    if unspaced?(word),
      do: substring_condition(word, scope),
      else: in_index("torrents_words", word, scope)
  end

  # A pattern of one word that a star ends is the start of a word, which the
  # word index answers. Any other is a GLOB on the lowercased text, with
  # punctuation and stars alike matching any run of characters. Its pieces are
  # only letters, digits and marks, so nothing in it is GLOB syntax.
  defp wildcard_condition(text, scope) do
    anchored? = text |> String.split("*") |> hd() |> tokens() |> Kernel.!=([])
    words = for {_kind, word} <- tokens(text), do: word
    starts_word? = anchored? and not unspaced?(hd(words))

    case words do
      [word] when starts_word? ->
        in_fts("torrents_words", quote_fts(word) <> "*", scope)

      [word] ->
        substring_condition(word, scope)

      [first | _] ->
        pattern = "*" <> Enum.map_join(words, "*", &String.downcase/1) <> "*"
        glob = text_condition(&"#{&1} GLOB ?", pattern, scope)

        if starts_word?,
          do: all([in_fts("torrents_words", quote_fts(first) <> "*", scope), glob]),
          else: glob
    end
  end

  defp substring_condition(word, scope) do
    if String.length(word) >= 3,
      do: in_index("torrents_search", word, scope),
      else: contains(word, scope)
  end

  defp unspaced?(word), do: Regex.match?(@unspaced, word)

  defp in_index(table, token, scope), do: in_fts(table, quote_fts(token), scope)

  defp in_fts(table, expression, scope) do
    {"t.id IN (SELECT rowid FROM #{table} WHERE #{table} MATCH ?)", [in_scope(scope, expression)]}
  end

  defp contains(token, scope) do
    text_condition(&"instr(#{&1}, ?) > 0", String.downcase(token), scope)
  end

  # SQLite's lower() folds only ASCII letters, so for text without one it
  # changes nothing the text could match. Skipped, it no longer copies every
  # name a scan reads: a short CJK search reads every torrent.
  defp folded(column, text), do: if(ascii_letter?(text), do: "lower(#{column})", else: column)

  defp ascii_letter?(text), do: String.match?(text, ~r/[a-zA-Z]/)

  # `condition` turns a lowercased column into SQL with one parameter, which
  # is `param`. With descriptions in scope, either column may match.
  defp text_condition(condition, param, scope) do
    columns =
      case scope do
        :all -> ["t.name", "coalesce(t.description, '')"]
        :name -> ["t.name"]
      end

    columns
    |> Enum.map(&{condition.(folded(&1, param)), [param]})
    |> any()
  end

  defp negate({sql, params}), do: {"NOT #{sql}", params}

  defp all(conditions), do: join(conditions, " AND ")
  defp any(conditions), do: join(conditions, " OR ")

  defp join([condition], _operator), do: condition

  defp join(conditions, operator) do
    {"(" <> Enum.map_join(conditions, operator, &elem(&1, 0)) <> ")",
     Enum.flat_map(conditions, &elem(&1, 1))}
  end
end
