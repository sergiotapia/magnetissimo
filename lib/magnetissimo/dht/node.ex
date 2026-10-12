defmodule Magnetissimo.DHT.Node do
  @moduledoc """
  Owns the crawler's UDP socket: sends KRPC queries, matches the answers to
  them, and holds every packet to the rate budget.

  `query/4` blocks its caller until the answer, an error, or 4 seconds
  without one. Nothing is retried. An answer counts only from the address
  that was asked and with the transaction id it was asked with.

  The budget is a token bucket of `rate` packets a second, with a burst of a
  tenth of a second's worth, so the packets leave evenly spread. Queries
  that find it empty wait in one of two queues: `:high` for the torrents
  already being fetched (peers and scrapes), `:low` for discovery, so
  discovery can never starve a fetch. A query that waits more than two
  seconds, or finds its queue full, is answered `{:error, :busy}` at once.

  It also counts the distinct addresses it sent to in the last 30 and 120
  seconds. That is what a home router's connection-tracking table holds for
  us: each address is an entry, which lives about 30 seconds if the node
  never answers and up to a few minutes once it has.

  We are a read-only node (BEP 43), so incoming queries are ignored.
  """

  use GenServer

  alias Magnetissimo.DHT.KRPC
  alias Magnetissimo.DHT.Stats

  @timeout 4_000
  @queue_wait 2_000
  @window_short 30_000
  @window_long 120_000

  ## API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc """
  Sends `method` with `args` to `address` and waits for the answer: `{:ok,
  results}` (see `Magnetissimo.DHT.KRPC.results/1`), `{:error, {:krpc, code}}`
  when the node answered with an error, or `{:error, :timeout | :busy}`.
  `priority: :high` jumps the discovery queue.
  """
  @spec query(KRPC.address(), binary(), map(), keyword()) :: {:ok, map()} | {:error, term()}
  def query(address, method, args, opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    priority = Keyword.get(opts, :priority, :low)

    GenServer.call(
      server,
      {:query, address, method, args, priority},
      @timeout + @queue_wait + 1_000
    )
  catch
    :exit, _reason -> {:error, :timeout}
  end

  @doc "Our node id."
  @spec node_id(GenServer.server()) :: binary()
  def node_id(server \\ __MODULE__), do: GenServer.call(server, :node_id)

  @doc """
  Queries in flight and waiting, and the distinct addresses sent to in the
  last 30 and 120 seconds.
  """
  @spec summary(GenServer.server()) :: map()
  def summary(server \\ __MODULE__), do: GenServer.call(server, :summary)

  ## Server

  @impl true
  def init(opts) do
    rate = Keyword.fetch!(opts, :rate)
    transport = Keyword.get(opts, :transport, config(:transport, Magnetissimo.DHT.UDP))

    case transport.open(Keyword.get(opts, :port, 0)) do
      {:ok, socket} ->
        Process.send_after(self(), :prune, 5_000)

        {:ok,
         %{
           transport: transport,
           socket: socket,
           id: Keyword.get_lazy(opts, :node_id, fn -> :crypto.strong_rand_bytes(20) end),
           rate: rate,
           burst: max(1.0, rate / 10),
           tokens: max(1.0, rate / 10),
           refilled_at: now(),
           seq: :rand.uniform(0xFFFF),
           pending: %{},
           high: :queue.new(),
           low: :queue.new(),
           drain?: false,
           contacts: %{}
         }}

      {:error, reason} ->
        {:stop, {:udp_open, reason}}
    end
  end

  @impl true
  def handle_call({:query, address, method, args, priority}, from, state) do
    state = refill(state)
    item = {from, address, method, args, now()}
    queue = Map.fetch!(state, priority)

    cond do
      state.tokens >= 1 and :queue.is_empty(state.high) and :queue.is_empty(state.low) ->
        {:noreply, send_query(state, item)}

      :queue.len(queue) >= max_queue(state) ->
        {:reply, {:error, :busy}, state}

      true ->
        state = Map.put(state, priority, :queue.in(item, queue))
        {:noreply, schedule_drain(state)}
    end
  end

  def handle_call(:node_id, _from, state), do: {:reply, state.id, state}

  def handle_call(:summary, _from, state) do
    now = now()
    ages = Enum.map(state.contacts, fn {_address, at} -> now - at end)

    {:reply,
     %{
       in_flight: map_size(state.pending),
       waiting: :queue.len(state.high) + :queue.len(state.low),
       flows_30s: Enum.count(ages, &(&1 <= @window_short)),
       flows_120s: Enum.count(ages, &(&1 <= @window_long))
     }, state}
  end

  @impl true
  def handle_info(:drain, state) do
    state = drain(refill(%{state | drain?: false}))

    if :queue.is_empty(state.high) and :queue.is_empty(state.low),
      do: {:noreply, state},
      else: {:noreply, schedule_drain(state)}
  end

  def handle_info({:udp, _socket, ip, port, packet}, state) do
    Stats.count(:received)
    Stats.count(:bytes_in, byte_size(packet) + 28)
    {:noreply, answer(state, {ip, port}, KRPC.decode(packet))}
  end

  def handle_info({:udp_passive, socket}, state) do
    :ok = state.transport.rearm(socket)
    {:noreply, state}
  end

  def handle_info({:timeout, tid}, state) do
    case Map.pop(state.pending, tid) do
      {{from, _address, _timer}, pending} ->
        Stats.count(:timeouts)
        GenServer.reply(from, {:error, :timeout})
        {:noreply, %{state | pending: pending}}

      {nil, _pending} ->
        {:noreply, state}
    end
  end

  def handle_info(:prune, state) do
    cutoff = now() - @window_long
    Process.send_after(self(), :prune, 5_000)

    {:noreply,
     %{state | contacts: Map.reject(state.contacts, fn {_address, at} -> at < cutoff end)}}
  end

  @impl true
  def terminate(_reason, state), do: state.transport.close(state.socket)

  defp answer(state, address, {:ok, {:response, tid, results}}) do
    reply(state, tid, address, {:ok, results})
  end

  defp answer(state, address, {:ok, {:error, tid, code, _message}}) do
    reply(state, tid, address, {:error, {:krpc, code}})
  end

  # Queries from others, and anything malformed.
  defp answer(state, _address, _decoded), do: state

  defp reply(state, tid, address, result) do
    case state.pending do
      %{^tid => {from, ^address, timer}} ->
        _ = Process.cancel_timer(timer)
        GenServer.reply(from, result)
        %{state | pending: Map.delete(state.pending, tid)}

      _ ->
        state
    end
  end

  defp drain(%{tokens: tokens} = state) when tokens < 1, do: state

  defp drain(state) do
    case peek(state) do
      nil -> state
      item -> state |> pop() |> send_or_expire(item) |> drain()
    end
  end

  defp peek(state) do
    case {:queue.peek(state.high), :queue.peek(state.low)} do
      {{:value, item}, _low} -> item
      {:empty, {:value, item}} -> item
      {:empty, :empty} -> nil
    end
  end

  defp pop(state) do
    case :queue.out(state.high) do
      {{:value, _item}, high} -> %{state | high: high}
      {:empty, _high} -> %{state | low: :queue.drop(state.low)}
    end
  end

  defp send_or_expire(state, {from, _address, _method, _args, queued_at} = item) do
    if now() - queued_at > @queue_wait do
      GenServer.reply(from, {:error, :busy})
      state
    else
      send_query(state, item)
    end
  end

  defp send_query(state, {from, {ip, port} = address, method, args, _queued_at}) do
    tid = <<state.seq::32>>
    packet = KRPC.query(tid, method, Map.put(args, "id", state.id))
    state = %{state | seq: rem(state.seq + 1, 0xFFFFFFFF), tokens: state.tokens - 1}

    case state.transport.send(state.socket, ip, port, packet) do
      :ok ->
        Stats.count(:sent)
        Stats.count(:bytes_out, IO.iodata_length(packet) + 28)
        timer = Process.send_after(self(), {:timeout, tid}, @timeout)

        %{
          state
          | pending: Map.put(state.pending, tid, {from, address, timer}),
            contacts: Map.put(state.contacts, address, now())
        }

      {:error, reason} ->
        GenServer.reply(from, {:error, reason})
        state
    end
  end

  defp refill(state) do
    now = now()
    tokens = min(state.burst, state.tokens + (now - state.refilled_at) * state.rate / 1000)
    %{state | tokens: tokens, refilled_at: now}
  end

  defp schedule_drain(%{drain?: true} = state), do: state

  defp schedule_drain(state) do
    Process.send_after(self(), :drain, max(1, ceil(1000 / state.rate)))
    %{state | drain?: true}
  end

  # Two seconds of packets per queue: more could not leave before expiring.
  defp max_queue(state), do: max(10, state.rate * 2)

  defp now, do: System.monotonic_time(:millisecond)

  defp config(key, default) do
    :magnetissimo |> Application.get_env(__MODULE__, []) |> Keyword.get(key, default)
  end
end
