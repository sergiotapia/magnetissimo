defmodule Magnetissimo.Crawlers.Rss do
  @moduledoc """
  The mechanics every RSS-driven crawl shares.

  Nyaa and TorrentDownloads both publish a feed of `<item>` entries and both
  file one torrent per entry, so pulling the items out, reading a plain field
  and parsing an integer are the same on both. What differs per site — field
  names, size and date formats, magnet construction — stays in that site's own
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
