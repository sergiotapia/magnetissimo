defmodule Magnetissimo.DHT.UDP do
  @moduledoc """
  The UDP socket `Magnetissimo.DHT.Node` sends and receives through.

  It is a module of its own so tests can swap it, with
  `config :magnetissimo, Magnetissimo.DHT.Node, transport: …`, for one that
  hands packets to the test instead of the network. A transport delivers
  what arrives to the process that opened it as
  `{:udp, socket, ip, port, packet}`, and `{:udp_passive, socket}` once it
  needs `rearm/1`, which is how the socket's own `active: N` flow control
  surfaces.
  """

  @callback open(:inet.port_number()) :: {:ok, term()} | {:error, term()}
  @callback send(term(), :inet.ip4_address(), :inet.port_number(), iodata()) ::
              :ok | {:error, term()}
  @callback rearm(term()) :: :ok
  @callback close(term()) :: :ok

  # Datagrams taken from the socket before it pauses, so a flood cannot fill
  # the mailbox faster than packets are handled.
  @active 200

  @behaviour __MODULE__

  @impl true
  def open(port) do
    :gen_udp.open(port, [
      :binary,
      :inet,
      active: @active,
      recbuf: 1024 * 1024,
      sndbuf: 1024 * 1024
    ])
  end

  @impl true
  def send(socket, ip, port, packet), do: :gen_udp.send(socket, ip, port, packet)

  @impl true
  def rearm(socket), do: :inet.setopts(socket, active: @active)

  @impl true
  def close(socket), do: :gen_udp.close(socket)
end
