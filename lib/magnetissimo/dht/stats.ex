defmodule Magnetissimo.DHT.Stats do
  @moduledoc """
  Counts what the crawler does and broadcasts its status every two seconds,
  for the DHT page, and logs a summary every minute.

  The counters are `:counters`, which any process bumps without a message.
  The status adds rates over the last minute, the torrents indexed in the
  last hour, and the router's view: how many distinct addresses we sent UDP
  to and opened TCP connections to in the last 30 and 120 seconds. Those are
  the entries a home router's connection-tracking table holds for us, and the
  number that decides whether the crawler slows anyone's browsing.
  """

  use GenServer

  require Logger

  alias Magnetissimo.DHT

  @counters [
    :sent,
    :received,
    :timeouts,
    :bytes_out,
    :bytes_in,
    :sampled,
    :new_hashes,
    :fetches,
    :fetched,
    :fetch_failed,
    :indexed,
    :banned,
    :refused,
    :scrapes,
    :tcp_connects
  ]
  @index @counters |> Enum.with_index(1) |> Map.new()
  @key {__MODULE__, :counters}
  @tick 2_000
  @window 60_000
  @log_every 30

  @doc "Adds `n` to a counter. A no-op while the crawler is not running."
  @spec count(atom(), integer()) :: :ok
  def count(name, n \\ 1) do
    case :persistent_term.get(@key, nil) do
      nil -> :ok
      ref -> :counters.add(ref, Map.fetch!(@index, name), n)
    end
  end

  @doc "Records a TCP connection to `address`, for the router's view."
  @spec tcp_contact(term()) :: :ok
  def tcp_contact(address) do
    count(:tcp_connects)
    if Process.whereis(__MODULE__), do: GenServer.cast(__MODULE__, {:tcp, address}), else: :ok
  end

  @doc "Counts why a fetch failed, for the status and the log."
  @spec failure(term()) :: :ok
  def failure(reason) do
    count(:fetch_failed)
    if Process.whereis(__MODULE__), do: GenServer.cast(__MODULE__, {:failure, reason}), else: :ok
  end

  @doc "Counts why one peer gave no metadata, for the log."
  @spec peer_failure(term()) :: :ok
  def peer_failure(reason) do
    if Process.whereis(__MODULE__),
      do: GenServer.cast(__MODULE__, {:peer_failure, reason}),
      else: :ok
  end

  @doc "Sets a gauge the status reports as is, such as the nodes known."
  @spec put(atom(), term()) :: :ok
  def put(name, value) do
    if Process.whereis(__MODULE__), do: GenServer.cast(__MODULE__, {:put, name, value}), else: :ok
  end

  @doc "The latest status."
  @spec status() :: map()
  def status, do: GenServer.call(__MODULE__, :status)

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(opts) do
    ref = :counters.new(length(@counters), [:write_concurrency])
    :persistent_term.put(@key, ref)
    Process.send_after(self(), :tick, @tick)

    state = %{
      ref: ref,
      config: Keyword.get(opts, :config, DHT.config()),
      node: Keyword.get(opts, :node, DHT.Node),
      started_at: now(),
      last: totals(ref),
      last_at: now(),
      window: :queue.from_list([{now(), totals(ref)}]),
      minutes: [],
      tcp: %{},
      gauges: %{},
      failures: %{},
      peer_failures: %{},
      ticks: 0,
      status: nil
    }

    {:ok, %{state | status: build(state, state.last, %{})}}
  end

  @impl true
  def handle_call(:status, _from, state), do: {:reply, state.status, state}

  @impl true
  def handle_cast({:tcp, address}, state) do
    {:noreply, %{state | tcp: Map.put(state.tcp, address, now())}}
  end

  def handle_cast({:failure, reason}, state) do
    key = failure_key(reason)
    {:noreply, %{state | failures: Map.update(state.failures, key, 1, &(&1 + 1))}}
  end

  def handle_cast({:peer_failure, reason}, state) do
    key = failure_key(reason)
    {:noreply, %{state | peer_failures: Map.update(state.peer_failures, key, 1, &(&1 + 1))}}
  end

  def handle_cast({:put, name, value}, state) do
    {:noreply, %{state | gauges: Map.put(state.gauges, name, value)}}
  end

  @impl true
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @tick)
    now = now()
    totals = totals(state.ref)
    # Rates over the last minute: one two-second tick is mostly zeroes.
    window = trim_window(:queue.in({now, totals}, state.window), now)
    {oldest_at, oldest} = :queue.get(window)
    rates = rates(oldest, totals, now - oldest_at)

    state = %{
      state
      | tcp: Map.reject(state.tcp, fn {_address, at} -> now - at > 120_000 end),
        minutes: minutes(state.minutes, now, totals.indexed - state.last.indexed),
        last: totals,
        last_at: now,
        window: window,
        ticks: state.ticks + 1
    }

    status = build(state, totals, rates)
    _ = DHT.broadcast({:dht_status, status})
    if rem(state.ticks, @log_every) == 0, do: log(status)

    {:noreply, %{state | status: status}}
  end

  @impl true
  def terminate(_reason, _state) do
    _ = :persistent_term.erase(@key)
    :ok
  end

  # Oldest first. The newest snapshot always stays, so the queue is never
  # empty.
  defp trim_window(window, now) do
    case :queue.out(window) do
      {{:value, {at, _totals}}, rest} when now - at > @window ->
        if :queue.is_empty(rest), do: window, else: trim_window(rest, now)

      _ ->
        window
    end
  end

  defp totals(ref), do: Map.new(@counters, &{&1, :counters.get(ref, Map.fetch!(@index, &1))})

  defp rates(_last, _totals, elapsed) when elapsed <= 0, do: %{}

  defp rates(last, totals, elapsed) do
    per_second = fn key -> (totals[key] - last[key]) * 1000 / elapsed end

    %{
      sent_per_second: per_second.(:sent),
      received_per_second: per_second.(:received),
      kbit_out: per_second.(:bytes_out) * 8 / 1000,
      kbit_in: per_second.(:bytes_in) * 8 / 1000,
      hashes_per_minute: per_second.(:new_hashes) * 60,
      torrents_per_minute: per_second.(:indexed) * 60
    }
  end

  # Torrents indexed per minute, the last 60 minutes.
  defp minutes(minutes, now, indexed) do
    minute = div(now, 60_000)

    case minutes do
      [{^minute, count} | rest] -> [{minute, count + indexed} | rest]
      _ -> [{minute, indexed} | minutes]
    end
    |> Enum.take_while(fn {at, _count} -> minute - at < 60 end)
  end

  defp build(state, totals, rates) do
    now = now()
    node = node_summary(state.node)
    tcp_ages = Enum.map(state.tcp, fn {_address, at} -> now - at end)

    %{
      running: true,
      config: state.config,
      uptime_seconds: div(now - state.started_at, 1000),
      totals: totals,
      rates: rates,
      indexed_last_hour: state.minutes |> Enum.map(&elem(&1, 1)) |> Enum.sum(),
      nodes_known: Map.get(state.gauges, :nodes_known, 0),
      fetching: Map.get(state.gauges, :fetching, 0),
      fetch_queue: Map.get(state.gauges, :fetch_queue, 0),
      failures: state.failures,
      peer_failures: state.peer_failures,
      udp: node,
      tcp: %{
        flows_30s: Enum.count(tcp_ages, &(&1 <= 30_000)),
        flows_120s: Enum.count(tcp_ages, &(&1 <= 120_000))
      }
    }
  end

  defp node_summary(node) do
    DHT.Node.summary(node)
  catch
    :exit, _reason -> %{in_flight: 0, waiting: 0, flows_30s: 0, flows_120s: 0}
  end

  defp log(status) do
    %{rates: rates, totals: totals, udp: udp, tcp: tcp} = status

    Logger.info(
      "[DHT] #{status.config.preset} #{format(rates[:sent_per_second])} pkt/s out, " <>
        "#{format(rates[:received_per_second])} in, " <>
        "#{format(rates[:kbit_out])}/#{format(rates[:kbit_in])} kbit/s out/in, " <>
        "udp flows #{udp.flows_30s}/30s #{udp.flows_120s}/120s, " <>
        "tcp flows #{tcp.flows_30s}/30s #{tcp.flows_120s}/120s, " <>
        "nodes #{status.nodes_known}, hashes #{format(rates[:hashes_per_minute])}/min, " <>
        "torrents #{format(rates[:torrents_per_minute])}/min, " <>
        "totals: #{totals.new_hashes} new hashes, #{totals.fetched}/#{totals.fetches} fetched, " <>
        "#{totals.indexed} indexed, #{totals.banned} banned, #{totals.refused} refused, " <>
        "failures #{inspect(status.failures)}, peers #{inspect(status.peer_failures)}"
    )
  end

  # Error codes come from strangers; only the four the BEP defines get a key
  # of their own, or the map would grow with every code anyone invents.
  defp failure_key({:krpc, code}) when code in 201..204, do: "krpc #{code}"
  defp failure_key({:krpc, _code}), do: "krpc other"
  defp failure_key(reason) when is_atom(reason), do: Atom.to_string(reason)
  defp failure_key(_reason), do: "other"

  defp format(nil), do: "0"
  defp format(number), do: :erlang.float_to_binary(number / 1, decimals: 1)

  defp now, do: System.monotonic_time(:millisecond)
end
