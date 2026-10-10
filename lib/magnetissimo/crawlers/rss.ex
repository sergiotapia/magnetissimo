defmodule Magnetissimo.Crawlers.Rss do
  @moduledoc """
  The mechanics every RSS-driven crawl shares.

  Nyaa and TorrentDownloads both publish a feed of `<item>` entries and both
  file one torrent per entry, so pulling the items out, reading a plain field
  and parsing an integer are the same on both. What differs per site — field
  names, size formats, magnet construction — stays in that site's own
  module, which passes only its item-to-attrs function in here.

  The fields are read with fixed patterns rather than an XML parser, because
  item titles carry arbitrary UTF-8 and xmerl rejects that input.
  """

  alias Magnetissimo.Torrents

  @doc "Returns each raw `<item>` body from an RSS document."
  @spec items(String.t()) :: [String.t()]
  def items(body) do
    ~r/<item>(.*?)<\/item>/s
    |> Regex.scan(body, capture: :all_but_first)
    |> Enum.map(&hd/1)
  end

  @doc "Reads a plain `<name>value</name>` field out of one item, or `nil`."
  @spec field(String.t(), String.t()) :: String.t() | nil
  def field(item, name) do
    case Regex.run(~r/<#{name}>([^<]*)<\/#{name}>/, item) do
      [_, value] when is_binary(value) -> value
      _ -> nil
    end
  end

  @doc "Reads a plain field as an integer, `0` when it is missing or unparsable."
  @spec integer_field(String.t(), String.t()) :: integer()
  def integer_field(item, name), do: to_integer(field(item, name))

  @doc "Parses an integer, returning `0` for `nil` or a value with trailing text."
  @spec to_integer(String.t() | nil) :: integer()
  def to_integer(nil), do: 0

  def to_integer(value) do
    case Integer.parse(value) do
      {int, _rest} -> int
      :error -> 0
    end
  end

  @months ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

  @doc """
  Parses a feed's RFC 1123 date, `Sat, 10 Oct 2026 01:40:07 +0200`, into UTC.

  Not every feed stamps its items in UTC, so the offset is applied and the
  result stored as UTC, which is what the rest of the app compares against.
  Only this fixed shape needs to parse, so no date library is pulled in for
  it. Returns `nil` for anything else.
  """
  @spec published_at(String.t() | nil) :: DateTime.t() | nil
  def published_at(nil), do: nil

  def published_at(raw) do
    with [_, day, month, year, hour, minute, second, sign, offset_hour, offset_minute] <-
           Regex.run(
             ~r/(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) ([+-])(\d{2})(\d{2})/,
             raw
           ),
         {:ok, date} <- Date.new(to_integer(year), month_number(month), to_integer(day)),
         {:ok, time} <- Time.new(to_integer(hour), to_integer(minute), to_integer(second)) do
      date
      |> DateTime.new!(time, "Etc/UTC")
      |> DateTime.add(-offset_seconds(sign, offset_hour, offset_minute), :second)
    else
      _ -> nil
    end
  end

  defp offset_seconds(sign, hour, minute) do
    sign = if sign == "-", do: -1, else: 1
    sign * (to_integer(hour) * 3600 + to_integer(minute) * 60)
  end

  @doc "The number of an English month abbreviation (`\"Oct\"` is 10), `0` if unknown."
  @spec month_number(String.t()) :: non_neg_integer()
  def month_number(month) do
    case Enum.find_index(@months, &(&1 == month)) do
      nil -> 0
      index -> index + 1
    end
  end

  @entities %{"amp" => "&", "lt" => "<", "gt" => ">", "quot" => "\"", "apos" => "'"}

  @doc """
  Decodes the XML entities a feed escapes text with: the five named ones and
  numeric character references.

  One pass, so text that was escaped twice comes out escaped once: `&amp;lt;`
  is `&lt;`, not `<`. A reference to no valid character is left as it is.
  """
  @spec unescape(String.t()) :: String.t()
  def unescape(text) do
    Regex.replace(~r/&(amp|lt|gt|quot|apos|#\d+);/, text, fn whole, entity ->
      decode(whole, entity)
    end)
  end

  defp decode(whole, "#" <> code) do
    case Integer.parse(code) do
      {n, ""} when n in 1..0xD7FF or n in 0xE000..0x10FFFF -> <<n::utf8>>
      _ -> whole
    end
  end

  defp decode(_whole, name), do: Map.fetch!(@entities, name)

  @doc """
  Builds attrs for every item with `attrs_fun.(item, source_id)`.

  `attrs_fun` returns `nil` for an item that cannot be filed, which is left
  out.
  """
  @spec attrs(String.t(), String.t(), (String.t(), integer() -> map() | nil)) :: [map()]
  def attrs(body, source_name, attrs_fun) do
    source_id = Torrents.get_source_by_name!(source_name).id

    body
    |> items()
    |> Enum.flat_map(&List.wrap(attrs_fun.(&1, source_id)))
  end
end
