defmodule Magnetissimo.DHT.KRPC do
  @moduledoc """
  The DHT's messages (BEP 5): one bencoded dictionary per UDP datagram.

  A query is `t` (our transaction id), `y: "q"`, `q` (the method) and `a`
  (its arguments). A response is `y: "r"` with results in `r`; an error is
  `y: "e"` with `[code, message]` in `e`. Every query we send also carries
  `ro: 1` (BEP 43): we are a read-only node, so nobody adds us to a routing
  table, nobody sends us queries, and the crawler needs no open port.

  Addresses travel "compact": a node is 26 bytes (20-byte id, 4-byte IPv4,
  2-byte big-endian port), a peer is the last 6 of those. A list whose length
  is not a multiple of the entry size is malformed and discarded whole, as
  is any entry for an address nobody can reach (port 0, private, loopback,
  multicast and the other reserved ranges). Only IPv4 is read.
  """

  alias Magnetissimo.DHT.Bencode

  @version "MG\x03\x00"

  @typedoc "An IPv4 address and port."
  @type address :: {:inet.ip4_address(), :inet.port_number()}

  @type message ::
          {:query, binary(), binary(), map()}
          | {:response, binary(), map()}
          | {:error, binary(), integer(), binary()}

  @doc "A query, ready to send."
  @spec query(binary(), binary(), map()) :: iolist()
  def query(tid, method, args) do
    Bencode.encode(%{
      "t" => tid,
      "y" => "q",
      "q" => method,
      "a" => args,
      "ro" => 1,
      "v" => @version
    })
  end

  @doc """
  Decodes a datagram. A response's results are normalised by `results/1`, and
  any message without a valid 20-byte node id is refused.
  """
  @spec decode(binary()) :: {:ok, message()} | {:error, atom()}
  def decode(packet) do
    case Bencode.decode(packet) do
      {:ok, %{"t" => tid, "y" => "r", "r" => %{} = r}} when is_binary(tid) ->
        with {:ok, results} <- results(r), do: {:ok, {:response, tid, results}}

      {:ok, %{"t" => tid, "y" => "e", "e" => [code, message | _]}}
      when is_binary(tid) and is_integer(code) and is_binary(message) ->
        {:ok, {:error, tid, code, message}}

      {:ok, %{"t" => tid, "y" => "q", "q" => method, "a" => %{} = args}}
      when is_binary(tid) and is_binary(method) ->
        {:ok, {:query, tid, method, args}}

      {:ok, _other} ->
        {:error, :not_krpc}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  The parts of a response the crawler reads, with defaults for those absent:
  `id`, `nodes`, `values` (peers), `token`, `samples` (BEP 51), `interval`,
  `num`, and the BEP 33 bloom filters `bfsd` and `bfpe`.
  """
  @spec results(map()) :: {:ok, map()} | {:error, :bad_id}
  def results(%{"id" => <<id::binary-size(20)>>} = r) do
    {:ok,
     %{
       id: id,
       nodes: nodes(r["nodes"]),
       values: peers(r["values"]),
       token: binary_or_nil(r["token"]),
       samples: samples(r["samples"]),
       interval: integer_or_nil(r["interval"]),
       num: integer_or_nil(r["num"]),
       bfsd: bloom(r["BFsd"]),
       bfpe: bloom(r["BFpe"])
     }}
  end

  def results(_r), do: {:error, :bad_id}

  @doc "Compact node infos, as `{id, {ip, port}}`, reachable ones only."
  @spec nodes(term()) :: [{binary(), address()}]
  def nodes(data) when is_binary(data) and rem(byte_size(data), 26) == 0 do
    for <<id::binary-size(20), a, b, c, d, port::16 <- data>>,
        dialable?({a, b, c, d}, port),
        do: {id, {{a, b, c, d}, port}}
  end

  def nodes(_data), do: []

  @doc "Encodes nodes back into compact node info."
  @spec encode_nodes([{binary(), address()}]) :: binary()
  def encode_nodes(nodes) do
    for {id, {{a, b, c, d}, port}} <- nodes, into: <<>>, do: <<id::binary, a, b, c, d, port::16>>
  end

  @doc """
  Compact peers from a `values` list. Some old clients send them as one
  string, which is read the same way when it is a multiple of 6 bytes.
  """
  @spec peers(term()) :: [address()]
  def peers(values) when is_list(values), do: Enum.flat_map(values, &peers/1)

  def peers(data) when is_binary(data) and rem(byte_size(data), 6) == 0 do
    for <<a, b, c, d, port::16 <- data>>, dialable?({a, b, c, d}, port), do: {{a, b, c, d}, port}
  end

  def peers(_data), do: []

  @doc "Encodes an address as a 6-byte compact peer."
  @spec encode_peer(address()) :: binary()
  def encode_peer({{a, b, c, d}, port}), do: <<a, b, c, d, port::16>>

  @doc """
  Whether anyone on the internet can reach this address: a real port and a
  public unicast IPv4 address.
  """
  @spec dialable?(:inet.ip4_address(), :inet.port_number()) :: boolean()
  def dialable?(_ip, 0), do: false
  def dialable?({0, _, _, _}, _port), do: false
  def dialable?({10, _, _, _}, _port), do: false
  def dialable?({100, b, _, _}, _port) when b in 64..127, do: false
  def dialable?({127, _, _, _}, _port), do: false
  def dialable?({169, 254, _, _}, _port), do: false
  def dialable?({172, b, _, _}, _port) when b in 16..31, do: false
  def dialable?({192, 0, 0, _}, _port), do: false
  def dialable?({192, 0, 2, _}, _port), do: false
  def dialable?({192, 168, _, _}, _port), do: false
  def dialable?({198, b, _, _}, _port) when b in 18..19, do: false
  def dialable?({198, 51, 100, _}, _port), do: false
  def dialable?({203, 0, 113, _}, _port), do: false
  def dialable?({a, _, _, _}, _port) when a >= 224, do: false
  def dialable?(_ip, _port), do: true

  defp samples(data) when is_binary(data) and rem(byte_size(data), 20) == 0 do
    for <<hash::binary-size(20) <- data>>, do: hash
  end

  defp samples(_data), do: nil

  defp bloom(<<_::binary-size(256)>> = filter), do: filter
  defp bloom(_filter), do: nil

  defp binary_or_nil(value) when is_binary(value), do: value
  defp binary_or_nil(_value), do: nil

  defp integer_or_nil(value) when is_integer(value), do: value
  defp integer_or_nil(_value), do: nil
end
