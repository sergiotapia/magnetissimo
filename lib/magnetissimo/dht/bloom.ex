defmodule Magnetissimo.DHT.Bloom do
  @moduledoc """
  The seeder and leecher estimate of a DHT scrape (BEP 33).

  A `get_peers` with `scrape: 1` makes a node answer with two 256-byte bloom
  filters, `BFsd` over the IPs of the seeds it knows for the torrent and
  `BFpe` over the downloaders. Each IP sets two of the 2048 bits, chosen by
  its SHA-1. The filters of several nodes are ORed together, which counts an
  IP two nodes both know once, and the number of members is estimated from
  how many bits are still zero:

      n = ln(zeros / m) / (k * ln(1 - 1/m))     m = 2048, k = 2

  It is an estimate: near 8,000 members every bit is set and it saturates,
  and an empty filter is 0.
  """

  import Bitwise

  @m 2048
  @k 2
  @bytes div(@m, 8)

  @doc "An empty filter."
  @spec empty() :: binary()
  def empty, do: <<0::size(@m)>>

  @doc "ORs filters together."
  @spec union([binary()]) :: binary()
  def union(filters) do
    Enum.reduce(filters, empty(), fn <<filter::size(@m)>>, <<acc::size(@m)>> ->
      <<bor(acc, filter)::size(@m)>>
    end)
  end

  @doc "Adds an IP to a filter, the way a node builds one."
  @spec insert(binary(), :inet.ip_address()) :: binary()
  def insert(<<_::binary-size(@bytes)>> = filter, ip) do
    <<a, b, c, d, _::binary>> = :crypto.hash(:sha, ip_bytes(ip))

    filter
    |> set_bit(bor(a, b <<< 8) |> rem(@m))
    |> set_bit(bor(c, d <<< 8) |> rem(@m))
  end

  @doc "The estimated number of members, rounded."
  @spec estimate(binary()) :: non_neg_integer()
  def estimate(<<_::binary-size(@bytes)>> = filter) do
    zeros = @m - count_ones(filter)
    zeros = max(zeros, 1)

    round(:math.log(zeros / @m) / (@k * :math.log(1 - 1 / @m)))
  end

  defp count_ones(filter), do: for(<<bit::1 <- filter>>, reduce: 0, do: (acc -> acc + bit))

  defp set_bit(filter, index) do
    byte = div(index, 8)
    <<before::binary-size(^byte), value, rest::binary>> = filter
    <<before::binary, bor(value, 1 <<< rem(index, 8)), rest::binary>>
  end

  defp ip_bytes({a, b, c, d}), do: <<a, b, c, d>>

  defp ip_bytes(ip) when tuple_size(ip) == 8,
    do: for(part <- Tuple.to_list(ip), into: <<>>, do: <<part::16>>)
end
