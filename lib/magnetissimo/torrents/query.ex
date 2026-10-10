defmodule Magnetissimo.Torrents.Query do
  @moduledoc """
  What a reader typed into the search box, read as a query: words, phrases,
  exclusions, alternatives and patterns.

    * `dune part two` finds all three words, each anywhere, as a plain search
      always has.
    * `"part two"` is a phrase: whole words, in that order, next to each other,
      across whatever separates them in a name ("Dune.Part.Two"). A phrase of
      one word is that whole word, so `"dune"` does not find "Dunes".
    * `-cam` excludes the whole word, so it leaves "El Camino" and "HDCAM"
      alone. `-"web dl"` excludes a phrase and `-*cam` a pattern.
    * `2160p|4k` is either. A bar binds tighter than the space between words,
      so `dune 2160p|4k remux` is dune, either resolution, and remux.
    * `s05e1*` is a pattern, where a star is any run of characters. One the
      word ends with makes it the start of a word; one it starts with lets it
      begin anywhere.

  Every operator has to be typed unambiguously, because names are full of
  the same characters. A dash is an exclusion only at the start of a word
  ("spider-man" and "x265-" are words), and only the ASCII hyphen: a phone
  turns `--` into an em dash. Curly quotes are quotes, for the same phone. A
  bar next to an exclusion is ignored, since "this or not that" means nothing
  useful. Anything with no letters or digits in it is dropped.

  The sites only understand plain words, so they are never sent the query:
  `remote_terms/1` turns it into the plain searches that between them find
  everything it can match, and the local index applies the rest. See
  `Magnetissimo.Torrents.Search` for how each part is matched.

  Torznab clients send titles, not queries, and a title can begin with a
  dash or hold a quote. They go through `plain/1`, where nothing is an
  operator.
  """

  alias Magnetissimo.Torrents.Search

  @typedoc """
  One thing to match: plain words as typed, a phrase's inner text, or a
  pattern with its stars.
  """
  @type atom_ :: {:words, String.t()} | {:phrase, String.t()} | {:wildcard, String.t()}

  @typedoc """
  `clauses` must all match, and each is a list of alternatives of which one
  must. No atom in `excludes` may match. `typing?` is whether the last thing
  in the input is a plain word, which may still be being typed.
  """
  @type t :: %__MODULE__{clauses: [[atom_]], excludes: [atom_], typing?: boolean()}

  defstruct clauses: [], excludes: [], typing?: false

  # Past this, a query is not something a person typed, and every atom past a
  # plain word costs the database a subquery.
  @max_atoms 32

  # Each costs a request to every site, through the pacer.
  @max_remote_terms 3

  @quotes ~s("“”„)

  # A phrase, which may follow dashes and may never be closed; a bar; or a
  # run of anything else up to whitespace, a quote or a bar.
  @lexer ~r/(-*)[#{@quotes}]([^#{@quotes}]*)[#{@quotes}]?|(\|)|([^\s#{@quotes}|]+)/u

  @doc "How many atoms a query keeps. The rest of the input is ignored."
  @spec max_atoms() :: pos_integer()
  def max_atoms, do: @max_atoms

  @doc "How many plain searches `remote_terms/1` asks the sites for, at most."
  @spec max_remote_terms() :: pos_integer()
  def max_remote_terms, do: @max_remote_terms

  @doc "Reads the operators in `text`."
  @spec parse(String.t()) :: t()
  def parse(text) when is_binary(text) do
    @lexer
    |> Regex.scan(text, capture: :all_but_first)
    |> Enum.flat_map(&lexeme/1)
    |> take_atoms(@max_atoms)
    |> build()
  end

  @doc """
  `text` as plain words, every operator in it read as text, the way a search
  read everything before there were operators.
  """
  @spec plain(String.t()) :: t()
  def plain(text) when is_binary(text) do
    text = String.trim(text)

    if searchable?(text),
      do: %__MODULE__{clauses: [[{:words, text}]], typing?: true},
      else: %__MODULE__{}
  end

  @doc "Whether there is nothing to search for."
  @spec empty?(t()) :: boolean()
  def empty?(%__MODULE__{clauses: [], excludes: []}), do: true
  def empty?(%__MODULE__{}), do: false

  @doc """
  The plain searches that ask the sites for everything `query` can match,
  each as typed.

  A site is asked words only. Exclusions are left out, as the index applies
  them after. A pattern cannot be put in words, so a clause holding one is
  left out, which asks for more and not less. Each alternative is its own
  search, up to `max_remote_terms/0`; past that, only the clauses with no
  alternatives are asked for.
  """
  @spec remote_terms(t()) :: [String.t()]
  def remote_terms(%__MODULE__{clauses: clauses}) do
    sendable =
      for clause <- clauses,
          texts = Enum.map(clause, &remote_text/1),
          nil not in texts,
          do: texts

    combinations =
      if combinations(sendable) <= @max_remote_terms,
        do: product(sendable),
        else: product(Enum.filter(sendable, &match?([_], &1)))

    combinations
    |> Enum.map(&(&1 |> Enum.join(" ") |> String.split() |> Enum.join(" ")))
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq_by(&Search.normalize/1)
  end

  defp remote_text({:words, text}), do: text
  defp remote_text({:phrase, text}), do: text
  defp remote_text({:wildcard, _text}), do: nil

  # Counted without expanding, which for sixteen pairs of alternatives would
  # be 65,536 lists. Stops counting once past the limit.
  defp combinations(clauses) do
    Enum.reduce_while(clauses, 1, fn clause, count ->
      count = count * length(clause)
      if count > @max_remote_terms, do: {:halt, count}, else: {:cont, count}
    end)
  end

  defp product([]), do: [[]]

  defp product([clause | rest]) do
    for text <- clause, tail <- product(rest), do: [text | tail]
  end

  # Each lexeme is `{:positive | :negative, atom}` or `:or`. A dash, quote or
  # star with nothing searchable around it is no lexeme at all.
  defp lexeme([dashes, phrase]), do: phrase_lexeme(dashes, phrase)
  defp lexeme([_dashes, _phrase, "|"]), do: [:or]
  defp lexeme([_dashes, _phrase, _bar, chunk]), do: chunk_lexeme(chunk)

  defp phrase_lexeme(dashes, phrase) do
    phrase = String.trim(phrase)
    if searchable?(phrase), do: [{polarity(dashes), {:phrase, phrase}}], else: []
  end

  defp chunk_lexeme(chunk) do
    body = String.trim_leading(chunk, "-")
    dashes = binary_part(chunk, 0, byte_size(chunk) - byte_size(body))
    kind = if String.contains?(body, "*"), do: :wildcard, else: :words

    if searchable?(body), do: [{polarity(dashes), {kind, body}}], else: []
  end

  defp polarity(""), do: :positive
  defp polarity(_dashes), do: :negative

  defp searchable?(text), do: Search.tokens(text) != []

  defp take_atoms(lexemes, max) do
    lexemes
    |> Enum.reduce_while({[], 0}, fn
      :or, {acc, count} -> {:cont, {[:or | acc], count}}
      _atom, {acc, count} when count >= max -> {:halt, {acc, count}}
      atom, {acc, count} -> {:cont, {[atom | acc], count + 1}}
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  # `after` is what came last: `:atom` (a positive one, which a bar can join
  # to the next), `:or` (a bar right after one) or `:none`.
  defp build(lexemes) do
    initial = %{clauses: [], excludes: [], after: :none, last: nil}

    state =
      Enum.reduce(lexemes, initial, fn
        :or, %{after: :atom} = state ->
          %{state | after: :or}

        :or, state ->
          state

        {:negative, atom}, state ->
          %{state | excludes: [atom | state.excludes], after: :none, last: :negative}

        {:positive, atom}, %{after: :or, clauses: [clause | rest]} = state ->
          %{state | clauses: [[atom | clause] | rest], after: :atom, last: atom}

        {:positive, atom}, state ->
          %{state | clauses: [[atom] | state.clauses], after: :atom, last: atom}
      end)

    # Built last first, so the head is the clause the input ends with.
    clauses_last_first = Enum.map(state.clauses, &(&1 |> Enum.reverse() |> uniq()))

    %__MODULE__{
      clauses: Enum.reverse(clauses_last_first),
      excludes: state.excludes |> Enum.reverse() |> uniq(),
      typing?: typing?(state.last, List.first(clauses_last_first))
    }
  end

  defp typing?({:words, _} = atom, [atom]), do: true
  defp typing?(_last, _clause), do: false

  defp uniq(atoms), do: Enum.uniq_by(atoms, fn {kind, text} -> {kind, Search.normalize(text)} end)
end
