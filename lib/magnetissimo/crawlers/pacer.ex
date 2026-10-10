defmodule Magnetissimo.Crawlers.Pacer do
  @moduledoc """
  Holds every site to a few searches at a time, whoever is asking.

  Searches come from people typing and from Sonarr, Radarr and the book
  managers through the Torznab API, which search on their own: a "search all
  missing" asks for hundreds of episodes in a row, and several of them can be
  pointed at one Magnetissimo. Nyaa and AudioBookBay blocked the project in
  October 2026 for asking too often, so the rate a site sees cannot depend on
  how many clients there are.

  Each site has its own line. At most `:concurrency` of its searches run at
  once, and each starts at least `:interval` after the one before; the rest
  wait, first come first served. One site's line never holds up another's.

  The pacer monitors everyone in a line and everyone running. A caller that
  dies while waiting, like a `Magnetissimo.SourceSearch` task given up on
  after its timeout, leaves the line without using a turn, and one that
  crashes mid-search frees its slot. A backlog therefore never outlives the
  searches that made it, and nothing has to clean up after a failure.

  Configured under `config :magnetissimo, Magnetissimo.Crawlers.Pacer`:
  `:concurrency` (default 2) and `:interval` in milliseconds (default 1000).
  Options given to `start_link/1` win over the config, and `name: nil` starts
  an unnamed pacer, for tests.
  """

  use GenServer

  @concurrency 2
  @interval :timer.seconds(1)

  @doc false
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Runs `fun` once `source` has a free slot and returns its result.

  Waits as long as the line takes. A caller with a deadline, like a
  `SourceSearch` task, is killed by its owner when it passes, which takes it
  out of the line.
  """
  @spec run(GenServer.server(), String.t(), (-> result)) :: result when result: term()
  def run(server \\ __MODULE__, source, fun) do
    :ok = GenServer.call(server, {:acquire, source}, :infinity)

    try do
      fun.()
    after
      GenServer.cast(server, {:release, source, self()})
    end
  end

  ## Server

  @impl true
  def init(opts) do
    # lines: source => %{running: %{pid => ref}, queue: :queue of {ref, from},
    #   next_at: when the next search may start, timer?: an :admit is pending}
    # monitors: ref => {source, pid}, for everyone running or waiting
    {:ok, %{opts: opts, lines: %{}, monitors: %{}}}
  end

  @impl true
  def handle_call({:acquire, source}, {pid, _tag} = from, state) do
    ref = Process.monitor(pid)
    state = put_in(state.monitors[ref], {source, pid})
    line = line(state, source)
    line = %{line | queue: :queue.in({ref, from}, line.queue)}

    {:noreply, admit(state, source, line)}
  end

  @impl true
  def handle_cast({:release, source, pid}, state) do
    line = line(state, source)

    case Map.pop(line.running, pid) do
      {nil, _running} ->
        {:noreply, state}

      {ref, running} ->
        Process.demonitor(ref, [:flush])
        state = %{state | monitors: Map.delete(state.monitors, ref)}
        {:noreply, admit(state, source, %{line | running: running})}
    end
  end

  @impl true
  def handle_info({:admit, source}, state) do
    {:noreply, admit(state, source, %{line(state, source) | timer?: false})}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    case Map.pop(state.monitors, ref) do
      {nil, _monitors} ->
        {:noreply, state}

      {{source, ^pid}, monitors} ->
        line = line(state, source)

        line = %{
          line
          | running: Map.delete(line.running, pid),
            queue: :queue.filter(fn {waiting, _from} -> waiting != ref end, line.queue)
        }

        {:noreply, admit(%{state | monitors: monitors}, source, line)}
    end
  end

  # Starts the head of the line if there is a free slot and the interval has
  # passed, then looks at the next one. A head that has to wait for the
  # interval gets a timer; one that has to wait for a slot is started by the
  # release or :DOWN that frees it.
  defp admit(state, source, line) do
    now = System.monotonic_time(:millisecond)
    free? = map_size(line.running) < setting(state, :concurrency, @concurrency)
    # Monotonic time can be negative, so a line nobody has used has no
    # `next_at` rather than a zero.
    due? = is_nil(line.next_at) or now >= line.next_at

    case :queue.out(line.queue) do
      {{:value, {ref, {pid, _tag} = from}}, queue} when free? and due? ->
        GenServer.reply(from, :ok)

        admit(state, source, %{
          line
          | queue: queue,
            running: Map.put(line.running, pid, ref),
            next_at: now + setting(state, :interval, @interval)
        })

      {{:value, _waiting}, _queue} when free? and not line.timer? ->
        _timer = Process.send_after(self(), {:admit, source}, line.next_at - now)
        put_in(state.lines[source], %{line | timer?: true})

      _empty_or_waiting ->
        put_in(state.lines[source], line)
    end
  end

  defp line(state, source) do
    Map.get(state.lines, source, %{running: %{}, queue: :queue.new(), next_at: nil, timer?: false})
  end

  defp setting(state, key, default) do
    Keyword.get_lazy(state.opts, key, fn ->
      :magnetissimo |> Application.get_env(__MODULE__, []) |> Keyword.get(key, default)
    end)
  end
end
