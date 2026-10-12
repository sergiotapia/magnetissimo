defmodule Magnetissimo.DHT.FakeTransport do
  @moduledoc """
  A `Magnetissimo.DHT.UDP` stand-in that hands every packet the node sends
  to the test, as `{:dht_sent, node_pid, {ip, port}, packet}`, and never
  touches the network. The test answers by sending the node
  `{:udp, socket, ip, port, packet}`, as a real socket would.

  `listen/0` makes the calling test the receiver.
  """

  @behaviour Magnetissimo.DHT.UDP

  @key {__MODULE__, :test}

  def listen, do: :persistent_term.put(@key, self())

  @impl true
  def open(_port), do: {:ok, :persistent_term.get(@key)}

  @impl true
  def send(test, ip, port, packet) do
    Kernel.send(test, {:dht_sent, self(), {ip, port}, IO.iodata_to_binary(packet)})
    :ok
  end

  @impl true
  def rearm(_socket), do: :ok

  @impl true
  def close(_socket), do: :ok
end
