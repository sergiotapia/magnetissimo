defmodule Magnetissimo.DHT.PeerWire do
  @moduledoc """
  Fetches a torrent's info dictionary from one peer: the BitTorrent handshake
  (BEP 3), the extension protocol (BEP 10) and `ut_metadata` (BEP 9). Pure:
  it takes the bytes a peer sent and returns the bytes to send back, so it is
  tested without a socket, and `Magnetissimo.DHT.Fetcher` owns the TCP
  connection.

  1. Both sides send a 68-byte handshake: `19`, `"BitTorrent protocol"`,
     8 reserved bytes (bit 20 says "I speak extensions"), the infohash and a
     peer id. A peer for another torrent or without extensions is dropped.
  2. After it, every message is a 4-byte length and a body, which
     `gen_tcp`'s `packet: 4` frames, so `receive/2` sees bodies only. Body
     id 20 is an extension message; its second byte 0 is the extension
     handshake, where each side says which id it gave `ut_metadata` and the
     peer says how big the metadata is.
  3. The metadata comes in 16 KiB pieces. Each data message is a bencoded
     dictionary followed by the raw piece. A reject fails the peer.
  4. The pieces joined must hash (SHA-1) to the infohash, or nothing is
     returned: the hash is the only proof the peer told the truth.

  A peer is a stranger. Every number it sends is checked before it is used:
  the metadata size against a 10 MiB cap, each piece index against the piece
  count, and each piece's length against what that piece must be. Three of
  the crawlers this was modelled on copy a piece without the index check,
  and one malicious peer can crash them.
  """

  alias Magnetissimo.DHT.Bencode

  @piece_size 16_384
  @max_metadata_size 10 * 1024 * 1024
  # The id we give ut_metadata in our extension handshake; the peer sends its
  # data messages with it.
  @ut_metadata 1
  # Piece requests in flight at once. Peers commonly queue up to 250.
  @pipeline 16

  @enforce_keys [:info_hash, :peer_id]
  defstruct [
    :info_hash,
    :peer_id,
    :peer_ut_metadata,
    :size,
    :count,
    next: 0,
    pieces: %{}
  ]

  @type t :: %__MODULE__{}

  @doc "The largest metadata a peer may offer."
  def max_metadata_size, do: @max_metadata_size

  @spec new(binary(), binary()) :: t()
  def new(<<_::binary-size(20)>> = info_hash, <<_::binary-size(20)>> = peer_id) do
    %__MODULE__{info_hash: info_hash, peer_id: peer_id}
  end

  @doc "Our handshake: the extension protocol bit and the DHT bit are set."
  @spec handshake(t()) :: binary()
  def handshake(%__MODULE__{info_hash: info_hash, peer_id: peer_id}) do
    <<19, "BitTorrent protocol", 0, 0, 0, 0, 0, 0x10, 0, 0x01, info_hash::binary,
      peer_id::binary>>
  end

  @doc "Checks the peer's 68-byte handshake."
  @spec check_handshake(t(), binary()) :: :ok | {:error, atom()}
  def check_handshake(%__MODULE__{info_hash: info_hash}, handshake) do
    case handshake do
      <<19, "BitTorrent protocol", _::binary-size(5), reserved, _::binary-size(2),
        ^info_hash::binary-size(20), _peer_id::binary-size(20)>>
      when Bitwise.band(reserved, 0x10) != 0 ->
        :ok

      <<19, "BitTorrent protocol", _::binary-size(8), ^info_hash::binary-size(20), _::binary>> ->
        {:error, :no_extensions}

      _ ->
        {:error, :bad_handshake}
    end
  end

  @doc "Our extension handshake, as a message body."
  @spec extension_handshake() :: iolist()
  def extension_handshake do
    [20, 0, Bencode.encode(%{"m" => %{"ut_metadata" => @ut_metadata}})]
  end

  @doc """
  Takes one message body from the peer. Returns the bodies to send in reply,
  the verified metadata once every piece is in, or why the peer failed.
  """
  @spec receive_message(t(), binary()) ::
          {:continue, t(), [iodata()]} | {:done, binary()} | {:error, atom()}
  def receive_message(state, <<20, 0, payload::binary>>), do: peer_handshake(state, payload)

  def receive_message(%__MODULE__{peer_ut_metadata: nil}, <<20, @ut_metadata, _::binary>>) do
    {:error, :data_before_handshake}
  end

  def receive_message(state, <<20, @ut_metadata, payload::binary>>), do: metadata(state, payload)

  # Keep-alives, bitfields, haves, chokes, other extensions: nothing to do.
  def receive_message(state, _body), do: {:continue, state, []}

  defp peer_handshake(%__MODULE__{peer_ut_metadata: nil} = state, payload) do
    case Bencode.decode_prefix(payload) do
      {:ok, %{"m" => %{"ut_metadata" => id}, "metadata_size" => size}, _rest}
      when is_integer(id) and id in 1..255 and is_integer(size) and size in 1..@max_metadata_size ->
        state = %{
          state
          | peer_ut_metadata: id,
            size: size,
            count: div(size + @piece_size - 1, @piece_size)
        }

        request_more(state, [])

      {:ok, %{"metadata_size" => size}, _rest}
      when is_integer(size) and size > @max_metadata_size ->
        {:error, :metadata_too_big}

      {:ok, _dict, _rest} ->
        {:error, :no_metadata}

      {:error, _reason} ->
        {:error, :bad_extension_handshake}
    end
  end

  # A second extension handshake may update other extensions; ours is set.
  defp peer_handshake(state, _payload), do: {:continue, state, []}

  defp metadata(state, payload) do
    case Bencode.decode_prefix(payload) do
      {:ok, %{"msg_type" => 1, "piece" => piece} = dict, data} when is_integer(piece) ->
        piece(state, piece, dict, data)

      {:ok, %{"msg_type" => 2}, _rest} ->
        {:error, :rejected}

      {:ok, _request_or_unknown, _rest} ->
        {:continue, state, []}

      {:error, _reason} ->
        {:error, :bad_metadata_message}
    end
  end

  defp piece(%__MODULE__{count: count}, piece, _dict, _data) when piece < 0 or piece >= count do
    {:error, :bad_piece_index}
  end

  defp piece(%__MODULE__{size: size}, _piece, %{"total_size" => total}, _data)
       when total != size do
    {:error, :size_changed}
  end

  defp piece(state, piece, _dict, data) do
    cond do
      Map.has_key?(state.pieces, piece) ->
        {:continue, state, []}

      byte_size(data) != piece_length(state, piece) ->
        {:error, :bad_piece_length}

      true ->
        state = %{state | pieces: Map.put(state.pieces, piece, data)}

        if map_size(state.pieces) == state.count,
          do: verify(state),
          else: request_more(state, [])
    end
  end

  defp piece_length(%__MODULE__{count: count, size: size}, piece) when piece == count - 1 do
    size - piece * @piece_size
  end

  defp piece_length(_state, _piece), do: @piece_size

  # Keeps `@pipeline` requests in flight until every piece has been asked for.
  defp request_more(%__MODULE__{next: next, count: count} = state, requests)
       when next < count and next - map_size(state.pieces) < @pipeline do
    request = [20, state.peer_ut_metadata, Bencode.encode(%{"msg_type" => 0, "piece" => next})]
    request_more(%{state | next: next + 1}, [request | requests])
  end

  defp request_more(state, requests), do: {:continue, state, Enum.reverse(requests)}

  defp verify(state) do
    metadata = Enum.map_join(0..(state.count - 1), &Map.fetch!(state.pieces, &1))

    if :crypto.hash(:sha, metadata) == state.info_hash,
      do: {:done, metadata},
      else: {:error, :hash_mismatch}
  end
end
