defmodule Magnetissimo.DHT.PeerWireTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Bencode
  alias Magnetissimo.DHT.PeerWire

  @peer_id String.duplicate("p", 20)

  # Big enough for three pieces, the last a short one.
  defp metadata do
    files = for i <- 1..800, do: %{"length" => i * 1000, "path" => ["dir", "file #{i}.bin"]}

    %{"name" => "Fixture", "piece length" => 262_144, "pieces" => "", "files" => files}
    |> Bencode.encode()
    |> IO.iodata_to_binary()
  end

  defp wire(metadata), do: PeerWire.new(:crypto.hash(:sha, metadata), @peer_id)

  defp peer_handshake(size, id \\ 3) do
    <<20, 0>> <>
      IO.iodata_to_binary(
        Bencode.encode(%{"m" => %{"ut_metadata" => id}, "metadata_size" => size})
      )
  end

  defp data(piece, metadata) do
    chunk =
      binary_part(metadata, piece * 16_384, min(16_384, byte_size(metadata) - piece * 16_384))

    dict =
      Bencode.encode(%{"msg_type" => 1, "piece" => piece, "total_size" => byte_size(metadata)})

    <<20, 1>> <> IO.iodata_to_binary(dict) <> chunk
  end

  defp requested(requests) do
    for <<20, 3, dict::binary>> <- Enum.map(requests, &IO.iodata_to_binary/1) do
      {:ok, %{"msg_type" => 0, "piece" => piece}} = Bencode.decode(dict)
      piece
    end
  end

  test "our handshake says we speak extensions" do
    wire = PeerWire.new(String.duplicate("h", 20), @peer_id)
    handshake = PeerWire.handshake(wire)

    assert <<19, "BitTorrent protocol", _::40, 0x10, _::16, hash::binary-size(20),
             @peer_id::binary>> =
             handshake

    assert hash == String.duplicate("h", 20)
    assert PeerWire.check_handshake(wire, handshake) == :ok
  end

  test "a peer for another torrent, or without extensions, is refused" do
    wire = PeerWire.new(String.duplicate("h", 20), @peer_id)
    other = PeerWire.handshake(PeerWire.new(String.duplicate("x", 20), @peer_id))
    plain = <<19, "BitTorrent protocol", 0::64>> <> String.duplicate("h", 20) <> @peer_id

    assert PeerWire.check_handshake(wire, other) == {:error, :bad_handshake}
    assert PeerWire.check_handshake(wire, plain) == {:error, :no_extensions}
  end

  test "fetches every piece and returns metadata that matches the hash" do
    metadata = metadata()
    assert byte_size(metadata) > 2 * 16_384 and byte_size(metadata) < 3 * 16_384

    {:continue, wire, requests} =
      PeerWire.receive_message(wire(metadata), peer_handshake(byte_size(metadata)))

    assert requested(requests) == [0, 1, 2]

    # Keep-alives and other messages change nothing.
    {:continue, wire, []} = PeerWire.receive_message(wire, <<>>)
    {:continue, wire, []} = PeerWire.receive_message(wire, <<5, 0xFF>>)

    {:continue, wire, []} = PeerWire.receive_message(wire, data(2, metadata))
    {:continue, wire, []} = PeerWire.receive_message(wire, data(0, metadata))
    assert PeerWire.receive_message(wire, data(1, metadata)) == {:done, metadata}
  end

  test "metadata that doesn't hash to the infohash is refused" do
    metadata = metadata()
    wire = PeerWire.new(String.duplicate("h", 20), @peer_id)
    {:continue, wire, _} = PeerWire.receive_message(wire, peer_handshake(byte_size(metadata)))
    {:continue, wire, _} = PeerWire.receive_message(wire, data(0, metadata))
    {:continue, wire, _} = PeerWire.receive_message(wire, data(1, metadata))

    assert PeerWire.receive_message(wire, data(2, metadata)) == {:error, :hash_mismatch}
  end

  test "a peer's numbers are checked before they are used" do
    metadata = metadata()

    {:continue, wire, _} =
      PeerWire.receive_message(wire(metadata), peer_handshake(byte_size(metadata)))

    out_of_range =
      <<20, 1>> <> IO.iodata_to_binary(Bencode.encode(%{"msg_type" => 1, "piece" => 7})) <> "x"

    negative = <<20, 1>> <> IO.iodata_to_binary(Bencode.encode(%{"msg_type" => 1, "piece" => -1}))
    short = binary_part(data(0, metadata), 0, 100)

    assert PeerWire.receive_message(wire, out_of_range) == {:error, :bad_piece_index}
    assert PeerWire.receive_message(wire, negative) == {:error, :bad_piece_index}
    assert PeerWire.receive_message(wire, short) == {:error, :bad_piece_length}
  end

  test "refuses oversized or missing metadata, rejects, and data before the handshake" do
    wire = wire(metadata())

    assert PeerWire.receive_message(wire, peer_handshake(PeerWire.max_metadata_size() + 1)) ==
             {:error, :metadata_too_big}

    no_metadata = <<20, 0>> <> IO.iodata_to_binary(Bencode.encode(%{"m" => %{}}))
    assert PeerWire.receive_message(wire, no_metadata) == {:error, :no_metadata}
    assert PeerWire.receive_message(wire, data(0, metadata())) == {:error, :data_before_handshake}

    {:continue, wire, _} = PeerWire.receive_message(wire, peer_handshake(byte_size(metadata())))
    reject = <<20, 1>> <> IO.iodata_to_binary(Bencode.encode(%{"msg_type" => 2, "piece" => 0}))
    assert PeerWire.receive_message(wire, reject) == {:error, :rejected}
  end

  test "keeps sixteen requests in flight on large metadata" do
    size = 40 * 16_384
    wire = PeerWire.new(String.duplicate("h", 20), @peer_id)
    {:continue, _wire, requests} = PeerWire.receive_message(wire, peer_handshake(size))

    assert requested(requests) == Enum.to_list(0..15)
  end
end
