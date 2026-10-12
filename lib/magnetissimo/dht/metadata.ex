defmodule Magnetissimo.DHT.Metadata do
  @moduledoc """
  Downloads one torrent's info dictionary from one peer over TCP, driving
  `Magnetissimo.DHT.PeerWire`.

  The handshake is read raw, 68 bytes; after it the socket switches to
  `packet: 4`, which frames BitTorrent's length-prefixed messages, and
  `packet_size` refuses any frame over 1 MiB before it is buffered. The
  connect has 2 seconds and the whole exchange 8.

  Every connection is closed with `linger: {true, 0}`, which sends a reset
  instead of a polite FIN. The router then forgets the connection in seconds
  instead of keeping its table entry for the minutes a closing TCP
  connection otherwise lingers.

  `Magnetissimo.DHT.Fetcher` calls it through config, so tests can swap in
  one that never touches a socket.
  """

  alias Magnetissimo.DHT.PeerWire
  alias Magnetissimo.DHT.Stats

  @callback fetch(binary(), {:inet.ip4_address(), :inet.port_number()}) ::
              {:ok, binary()} | {:error, term()}

  @behaviour __MODULE__

  @connect_timeout 2_000
  @deadline 8_000
  @max_frame 1024 * 1024

  @impl true
  def fetch(info_hash, address) do
    case connect_and_fetch(info_hash, address) do
      {:ok, metadata} ->
        {:ok, metadata}

      {:error, reason} ->
        Stats.peer_failure(reason)
        {:error, reason}
    end
  end

  defp connect_and_fetch(info_hash, {ip, port} = address) do
    deadline = System.monotonic_time(:millisecond) + @deadline
    Stats.tcp_contact(address)

    options = [
      :binary,
      active: false,
      packet: :raw,
      linger: {true, 0},
      nodelay: true,
      send_timeout: 3_000
    ]

    case :gen_tcp.connect(ip, port, options, @connect_timeout) do
      {:ok, socket} ->
        try do
          exchange(socket, PeerWire.new(info_hash, peer_id()), deadline)
        after
          :gen_tcp.close(socket)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp exchange(socket, wire, deadline) do
    with :ok <- :gen_tcp.send(socket, PeerWire.handshake(wire)),
         {:ok, handshake} <- :gen_tcp.recv(socket, 68, remaining(deadline)),
         :ok <- PeerWire.check_handshake(wire, handshake),
         :ok <- :inet.setopts(socket, packet: 4, packet_size: @max_frame),
         :ok <- :gen_tcp.send(socket, PeerWire.extension_handshake()) do
      loop(socket, wire, deadline)
    end
  end

  defp loop(socket, wire, deadline) do
    with {:ok, body} <- :gen_tcp.recv(socket, 0, remaining(deadline)),
         {:continue, wire, replies} <- PeerWire.receive_message(wire, body),
         :ok <- send_all(socket, replies) do
      loop(socket, wire, deadline)
    else
      {:done, metadata} -> {:ok, metadata}
      {:error, reason} -> {:error, reason}
    end
  end

  defp send_all(socket, replies) do
    Enum.reduce_while(replies, :ok, fn reply, :ok ->
      case :gen_tcp.send(socket, reply) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp remaining(deadline), do: max(0, deadline - System.monotonic_time(:millisecond))

  defp peer_id, do: "-MG0300-" <> :crypto.strong_rand_bytes(12)
end
