defmodule MagnetissimoWeb.SearchFilters do
  @moduledoc """
  The refine fields under the search box, read from and written back to the
  URL: names only, size, seeders and age.

  Each field is kept as typed, so the form shows back what the reader wrote,
  and is applied only if it reads. A field that does not read is ignored and
  marked as such, never guessed at: "7m" could be minutes or months.

    * `in=title` searches names only.
    * `min_size` and `max_size` take a number and a unit, in binary units as
      every size on the page is: "2 GB" is 2 GiB, as The Pirate Bay and
      OxTorrent write it. A bare number is gigabytes.
    * `min_seeders` and `max_seeders` take a whole number.
    * `max_age` (newer than) and `min_age` (older than) take a number and
      h, d, w, mo or y. A bare number is days. A month is thirty days and a
      year 365.

  The operators typed into the search box itself are
  `Magnetissimo.Torrents.Query`'s.
  """

  alias MagnetissimoWeb.Format

  @params ~w(min_size max_size min_seeders max_seeders max_age min_age)a
  @fields Enum.map(@params, &Atom.to_string/1)

  # SQLite integers are 64-bit; anything near that is not a size or a count.
  @max_integer 2 ** 62
  # Older than any torrent, and well inside what DateTime can count back to.
  @max_age_seconds 100 * 365 * 86_400

  @size_units %{
    "" => 3,
    "b" => 0,
    "k" => 1,
    "kb" => 1,
    "kib" => 1,
    "m" => 2,
    "mb" => 2,
    "mib" => 2,
    "g" => 3,
    "gb" => 3,
    "gib" => 3,
    "t" => 4,
    "tb" => 4,
    "tib" => 4
  }

  @age_units %{
    "" => 86_400,
    "h" => 3600,
    "hour" => 3600,
    "hours" => 3600,
    "d" => 86_400,
    "day" => 86_400,
    "days" => 86_400,
    "w" => 7 * 86_400,
    "week" => 7 * 86_400,
    "weeks" => 7 * 86_400,
    "mo" => 30 * 86_400,
    "month" => 30 * 86_400,
    "months" => 30 * 86_400,
    "y" => 365 * 86_400,
    "year" => 365 * 86_400,
    "years" => 365 * 86_400
  }

  @number ~r/^(\d+(?:[.,]\d+)?)\s*([a-z]*)$/

  @typedoc """
  `typed` holds every non-blank field as typed; `values` the ones that read,
  as bytes, counts or seconds.
  """
  @type t :: %__MODULE__{
          scope: :all | :name,
          typed: %{String.t() => String.t()},
          values: %{String.t() => non_neg_integer()}
        }

  defstruct scope: :all, typed: %{}, values: %{}

  @doc "The names of the range fields, in the order the form and URL list them."
  @spec fields() :: [String.t()]
  def fields, do: @fields

  @doc "Reads the refine fields out of URL or form params, ignoring the rest."
  @spec from_params(map()) :: t()
  def from_params(params) when is_map(params) do
    typed =
      for field <- @fields,
          value = params[field],
          is_binary(value),
          value = String.trim(value),
          value != "",
          into: %{},
          do: {field, value}

    values =
      for {field, text} <- typed,
          {:ok, value} <- [read(field, text)],
          into: %{},
          do: {field, value}

    scope = if params["in"] == "title", do: :name, else: :all
    %__MODULE__{scope: scope, typed: typed, values: values}
  end

  @doc "The params that put these filters in a URL, as typed."
  @spec to_params(t()) :: keyword(String.t())
  def to_params(%__MODULE__{} = filters) do
    scope = if filters.scope == :name, do: [in: "title"], else: []

    scope ++
      for param <- @params,
          text = filters.typed[Atom.to_string(param)],
          do: {param, text}
  end

  @doc """
  The options `Magnetissimo.Torrents.search_torrents/2` and
  `Magnetissimo.Torrents.list_latest_torrents/1` take for these filters,
  with ages counted back from `now`.
  """
  @spec opts(t(), DateTime.t()) :: keyword()
  def opts(%__MODULE__{} = filters, now) do
    scope = if filters.scope == :name, do: [scope: :name], else: []

    scope ++
      for field <- @fields, value = filters.values[field] do
        option(field, value, now)
      end
  end

  defp option("min_size", bytes, _now), do: {:min_size, bytes}
  defp option("max_size", bytes, _now), do: {:max_size, bytes}
  defp option("min_seeders", count, _now), do: {:min_seeders, count}
  defp option("max_seeders", count, _now), do: {:max_seeders, count}
  defp option("max_age", seconds, now), do: {:published_after, DateTime.add(now, -seconds)}
  defp option("min_age", seconds, now), do: {:published_before, DateTime.add(now, -seconds)}

  @doc "Whether any filter is applied."
  @spec active?(t()) :: boolean()
  def active?(%__MODULE__{scope: scope, values: values}), do: scope != :all or values != %{}

  @doc "What `field` holds as typed, or `\"\"`."
  @spec value(t(), String.t()) :: String.t()
  def value(%__MODULE__{typed: typed}, field), do: Map.get(typed, field, "")

  @doc "Whether `field` holds something that does not read, and is ignored."
  @spec invalid?(t(), String.t()) :: boolean()
  def invalid?(%__MODULE__{typed: typed, values: values}, field) do
    Map.has_key?(typed, field) and not Map.has_key?(values, field)
  end

  @doc "What is applied, a phrase for each filter, for the status line."
  @spec summary(t()) :: [String.t()]
  def summary(%__MODULE__{} = filters) do
    scope = if filters.scope == :name, do: ["titles only"], else: []

    scope ++
      for field <- @fields, value = filters.values[field] do
        phrase(field, value, filters.typed[field])
      end
  end

  defp phrase("min_size", bytes, _typed), do: "at least #{Format.bytes(bytes)}"
  defp phrase("max_size", bytes, _typed), do: "at most #{Format.bytes(bytes)}"
  defp phrase("min_seeders", count, _typed), do: "#{Format.number(count)}+ seeders"
  defp phrase("max_seeders", count, _typed), do: "at most #{Format.number(count)} seeders"
  defp phrase("max_age", _seconds, typed), do: "newer than #{typed}"
  defp phrase("min_age", _seconds, typed), do: "older than #{typed}"

  defp read(field, text) when field in ["min_size", "max_size"] do
    with {:ok, number, unit} <- number(text),
         {:ok, exponent} <- Map.fetch(@size_units, unit) do
      bounded(round(number * 1024 ** exponent), @max_integer)
    end
  end

  defp read(field, text) when field in ["min_seeders", "max_seeders"] do
    digits = String.replace(text, [",", "_", " "], "")

    if digits =~ ~r/^\d+$/,
      do: digits |> String.to_integer() |> bounded(@max_integer),
      else: :error
  end

  defp read(field, text) when field in ["max_age", "min_age"] do
    with {:ok, number, unit} <- number(text),
         {:ok, seconds} <- Map.fetch(@age_units, unit) do
      bounded(round(number * seconds), @max_age_seconds)
    end
  end

  # A decimal comma is a decimal point.
  defp number(text) do
    case Regex.run(@number, String.downcase(text)) do
      [_, number, unit] ->
        {number, ""} = number |> String.replace(",", ".") |> Float.parse()
        {:ok, number, unit}

      nil ->
        :error
    end
  end

  defp bounded(value, max) when value <= max, do: {:ok, value}
  defp bounded(_value, _max), do: :error
end
