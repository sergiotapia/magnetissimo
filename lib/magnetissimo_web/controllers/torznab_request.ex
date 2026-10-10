defmodule MagnetissimoWeb.TorznabRequest do
  @moduledoc """
  Reads a Torznab query string into what to look up.

  Torznab clients ask in structured parameters: Sonarr sends a show's title
  with `season` and `ep`, Lidarr an `artist` and `album`, Readarr and its
  forks an `author` and `title`. Every site Magnetissimo asks searches free
  text, and so does the local index, so each function's parameters are
  rebuilt into one term, the way Jackett does it:

    * `tvsearch`: `q` with `S01E02`, `S01` for a whole season, or
      `2026.10.05` for a daily show (`season=2026&ep=10/05`)
    * `movie`: `q`, with `year` when it is not already in it
    * `music`: `q`, `artist`, `album` and `year`
    * `book`: `q`, `author` and `title`

  The caps (`MagnetissimoWeb.TorznabXML.caps/0`) advertise only these
  parameters. A request with no text at all is a client's RSS poll or its
  Test button, and `term` is `nil`: the caller answers it from the index and
  never asks a site. One that carries only ids we cannot resolve, such as
  `imdbid` or `tvdbid`, matches nothing, as the spec says an unsupported
  parameter should.

  Parameter names are case-insensitive, as Newznab's are. A bad `limit`,
  `offset` or `cat` falls back to the default rather than failing: a client
  that sends one would otherwise get nothing.
  """

  alias Magnetissimo.Taxonomy

  @max_limit 100

  # The functions a Newznab server can offer that a torrent index cannot.
  @unavailable ~w(details getnfo get cartadd cartdel comments commentadd register user)

  @ids ~w(imdbid tvdbid tmdbid rid tvmazeid traktid doubanid)

  @enforce_keys [:function]
  defstruct [
    :function,
    :term,
    unsupported?: false,
    category_ids: [],
    limit: @max_limit,
    offset: 0
  ]

  @type t :: %__MODULE__{
          function: :caps | :search,
          term: String.t() | nil,
          unsupported?: boolean(),
          category_ids: [pos_integer()],
          limit: pos_integer(),
          offset: non_neg_integer()
        }

  @doc "The most results one request returns, and the default."
  @spec max_limit() :: pos_integer()
  def max_limit, do: @max_limit

  @doc """
  Parses the query parameters, or returns the Newznab error code and
  description to answer with.
  """
  @spec parse(map()) :: {:ok, t()} | {:error, pos_integer(), String.t()}
  def parse(params) do
    params =
      for {key, value} <- params, is_binary(value), into: %{}, do: {String.downcase(key), value}

    case Map.get(params, "t") do
      nil -> {:error, 200, "Missing parameter (t)"}
      "caps" -> {:ok, %__MODULE__{function: :caps}}
      t when t in ~w(search tvsearch movie music book) -> {:ok, search(t, params)}
      t when t in @unavailable -> {:error, 203, "Function not available"}
      _t -> {:error, 202, "No such function"}
    end
  end

  defp search(t, params) do
    term = term(t, params)

    %__MODULE__{
      function: :search,
      term: term,
      unsupported?: is_nil(term) and Enum.any?(@ids, &present?(params[&1])),
      category_ids: params |> Map.get("cat", "") |> category_ids(),
      limit: params |> integer("limit", @max_limit) |> max(1) |> min(@max_limit),
      offset: params |> integer("offset", 0) |> max(0)
    }
  end

  defp term("tvsearch", params) do
    with q when is_binary(q) <- text([params["q"]]) do
      text([q, episode(params["season"], params["ep"])])
    end
  end

  defp term("movie", params) do
    with q when is_binary(q) <- text([params["q"]]) do
      year = params["year"]
      if present?(year) and year in String.split(q), do: q, else: text([q, year])
    end
  end

  defp term("music", params),
    do: text([params["q"], params["artist"], params["album"], params["year"]])

  defp term("book", params), do: text([params["q"], params["author"], params["title"]])
  defp term("search", params), do: text([params["q"]])

  # Sonarr sends a season zero-padded ("01", "00" for specials), and some
  # clients send "S01"; a daily show's episode is its air date, "MM/DD".
  defp episode(season, ep) do
    case {number(season, "s"), ep} do
      {nil, _ep} -> nil
      {year, <<month::binary-size(2), "/", day::binary-size(2)>>} -> "#{year}.#{month}.#{day}"
      {season, ep} -> season_episode(season, number(ep, "e"))
    end
  end

  defp season_episode(season, nil), do: "S#{pad(season)}"
  defp season_episode(season, ep), do: "S#{pad(season)}E#{pad(ep)}"

  defp number(nil, _prefix), do: nil

  defp number(value, prefix) do
    value = value |> String.trim() |> String.downcase() |> String.trim_leading(prefix)

    case Integer.parse(value) do
      {n, ""} when n >= 0 -> n
      _ -> nil
    end
  end

  defp pad(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")

  # The non-blank parts joined by a space, or nil when there are none.
  defp text(parts) do
    case parts |> Enum.filter(&present?/1) |> Enum.map_join(" ", &String.trim/1) do
      "" -> nil
      text -> text
    end
  end

  defp present?(value), do: is_binary(value) and String.trim(value) != ""

  defp category_ids(cat) do
    cat
    |> String.split(",", trim: true)
    |> Enum.flat_map(fn id ->
      case Integer.parse(String.trim(id)) do
        {id, ""} -> [id]
        _ -> []
      end
    end)
    |> Taxonomy.torznab_ids()
  end

  defp integer(params, key, default) do
    case Integer.parse(Map.get(params, key, "")) do
      {n, ""} -> n
      _ -> default
    end
  end
end
