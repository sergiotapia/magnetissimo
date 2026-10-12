defmodule Magnetissimo.DHT.Bencode do
  @moduledoc """
  Bencoding, the serialisation every DHT message and every torrent's info
  dictionary is written in (BEP 3).

  Four types: integers `i42e`, byte strings `4:spam`, lists `l…e` and
  dictionaries `d…e` with byte-string keys in sorted order. Strings are raw
  bytes and decode to binaries, never assumed to be UTF-8.

  Everything here comes off the network from strangers, so decoding never
  raises and never trusts a length: a string longer than what is left of the
  input is an error before anything is copied, and nesting stops at
  64 levels. `decode_prefix/1` decodes one value and returns the bytes
  after it, which a BEP 9 data message needs: a dictionary followed by a piece
  of raw metadata.
  """

  @max_depth 64

  @type value :: integer() | binary() | [value()] | %{optional(binary()) => value()}

  @doc """
  Encodes integers, binaries, lists and maps with binary keys. Map keys are
  written in sorted order, as the format requires.
  """
  @spec encode(value()) :: iolist()
  def encode(value) when is_integer(value), do: ["i", Integer.to_string(value), "e"]
  def encode(value) when is_binary(value), do: [Integer.to_string(byte_size(value)), ":", value]
  def encode(value) when is_list(value), do: ["l", Enum.map(value, &encode/1), "e"]

  def encode(value) when is_map(value) do
    entries =
      value
      |> Enum.sort_by(fn {key, _value} -> key end)
      |> Enum.map(fn {key, value} when is_binary(key) -> [encode(key), encode(value)] end)

    ["d", entries, "e"]
  end

  @doc "Decodes exactly one value that must fill the whole input."
  @spec decode(binary()) :: {:ok, value()} | {:error, atom()}
  def decode(data) when is_binary(data) do
    case decode_prefix(data) do
      {:ok, value, ""} -> {:ok, value}
      {:ok, _value, _rest} -> {:error, :trailing_data}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Decodes one value from the start of the input and returns what follows it."
  @spec decode_prefix(binary()) :: {:ok, value(), binary()} | {:error, atom()}
  def decode_prefix(data) when is_binary(data), do: value(data, 0)

  defp value(_data, depth) when depth > @max_depth, do: {:error, :too_deep}
  defp value(<<"i", rest::binary>>, _depth), do: integer(rest)
  defp value(<<"l", rest::binary>>, depth), do: list(rest, depth + 1, [])
  defp value(<<"d", rest::binary>>, depth), do: dict(rest, depth + 1, [])
  defp value(<<digit, _::binary>> = data, _depth) when digit in ?0..?9, do: string(data)
  defp value(_data, _depth), do: {:error, :invalid}

  defp integer(data) do
    case :binary.split(data, "e") do
      [digits, rest] when byte_size(digits) in 1..20 ->
        case Integer.parse(digits) do
          {integer, ""} -> {:ok, integer, rest}
          _ -> {:error, :invalid_integer}
        end

      _ ->
        {:error, :invalid_integer}
    end
  end

  defp string(data) do
    with [length, rest] when byte_size(length) in 1..10 <- :binary.split(data, ":"),
         {length, ""} <- Integer.parse(length),
         <<string::binary-size(^length), rest::binary>> <- rest do
      {:ok, string, rest}
    else
      _ -> {:error, :invalid_string}
    end
  end

  defp list(<<"e", rest::binary>>, _depth, acc), do: {:ok, Enum.reverse(acc), rest}

  defp list(data, depth, acc) do
    case value(data, depth) do
      {:ok, value, rest} -> list(rest, depth, [value | acc])
      error -> error
    end
  end

  defp dict(<<"e", rest::binary>>, _depth, acc), do: {:ok, Map.new(acc), rest}

  defp dict(data, depth, acc) do
    with {:ok, key, rest} <- string(data),
         {:ok, value, rest} <- value(rest, depth) do
      dict(rest, depth, [{key, value} | acc])
    else
      {:error, _reason} = error -> error
    end
  end
end
