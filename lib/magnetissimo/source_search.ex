defmodule Magnetissimo.SourceSearch do
  @moduledoc """
  Asks every source's own search for a term, all at once, and broadcasts each
  answer the moment it is indexed.

  The local index only holds what the crawlers have seen, which is the newest
  page of each site. A search reaches the rest of each catalogue by asking the
  sites themselves, and this is the one place that happens:

    * Every source runs in its own task, so the slowest site only delays its
      own answer. Each task indexes its hits in one short transaction, which
      keeps SQLite's single writer free between them.
    * One term is searched once at a time, however many readers ask for it.
      A second reader typing the same thing joins the search in flight. The
      same words in another order are the same thing: Readarr asks for
      "Title Author" and "Author Title" back to back, and every site's search
      and the local index match words in any order.
    * A term every source answered in the last `:ttl` is not searched again;
      its hits are already in the index. This is what keeps search-as-you-type
      from hammering the sites when a reader backspaces and retypes. A term a
      source failed on is not remembered, so the next reader asks again.
    * A source that has not answered after `:timeout` is given up on.

  Readers `subscribe/1` to a term and then `request/1` it. They receive, on
  the term's topic:

    * `{:source_search, key, source_name, status}` as each source finishes
    * `{:source_search_done, key, statuses}` once every source has

  where `key` is `key/1` of the term and `status` is one of `:searching`,
  `{:done, %{inserted: n, found: n}}` or `{:failed, reason}`.

  Configured under `config :magnetissimo, Magnetissimo.SourceSearch`:
  `:crawlers` (default `Magnetissimo.Crawlers.all/0`), `:ttl` and `:timeout`
  in milliseconds.
  """

  use GenServer

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Torrents.Search

  @pubsub Magnetissimo.PubSub
  @tasks Magnetissimo.SourceSearch.TaskSupervisor
  @ttl :timer.minutes(15)
  @timeout :timer.seconds(20)

  # Shorter than this, a term is a reader still typing, and no site's search
  # does anything useful with one character.
  @min_length 2

  @type status ::
          :searching
          | {:done, %{inserted: non_neg_integer(), found: non_neg_integer()}}
          | {:failed, term()}

  @type statuses :: %{String.t() => status()}

  ## Client

  @doc false
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc """
  The key a term is searched, broadcast and cached under: two terms that
  differ only by case, spacing or the order of their words are one search.
  """
  @spec key(String.t()) :: String.t()
  def key(term), do: term |> Search.normalize() |> String.split() |> Enum.sort() |> Enum.join(" ")

  @doc "Subscribes the caller to the answers for `term`."
  @spec subscribe(String.t()) :: :ok | {:error, term()}
  def subscribe(term), do: Phoenix.PubSub.subscribe(@pubsub, topic(term))

  @doc "Stops the answers for `term` reaching the caller."
  @spec unsubscribe(String.t()) :: :ok
  def unsubscribe(term), do: Phoenix.PubSub.unsubscribe(@pubsub, topic(term))

  @doc """
  Asks every source for `term` unless that is already happening or happened
  within the `:ttl`, and returns where each source stands.

  Subscribe first: an answer that lands between this returning and a later
  subscribe would be missed. A term too short to search returns `%{}`.
  """
  @spec request(String.t()) :: statuses()
  def request(term), do: GenServer.call(__MODULE__, {:request, key(term), Search.normalize(term)})

  @doc """
  Requests `term` and waits up to `timeout` for every source to answer.

  For callers that cannot be sent results later, like the JSON API. Returns
  the statuses as they stood when every source had answered or the wait ran
  out.
  """
  @spec await(String.t(), timeout()) :: statuses()
  def await(term, timeout) do
    key = key(term)
    :ok = subscribe(key)
    deadline = System.monotonic_time(:millisecond) + timeout

    statuses = request(term)
    statuses = if searching?(statuses), do: wait(key, statuses, deadline), else: statuses

    :ok = unsubscribe(key)
    flush(key)
    statuses
  end

  @doc "Whether any source in `statuses` has yet to answer."
  @spec searching?(statuses()) :: boolean()
  def searching?(statuses), do: Enum.any?(statuses, fn {_, status} -> status == :searching end)

  defp wait(key, statuses, deadline) do
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    receive do
      {:source_search_done, ^key, statuses} ->
        statuses

      {:source_search, ^key, source, status} ->
        wait(key, %{statuses | source => status}, deadline)
    after
      remaining -> statuses
    end
  end

  # Answers broadcast between the last receive and the unsubscribe would sit in
  # the caller's mailbox for good.
  defp flush(key) do
    receive do
      {:source_search_done, ^key, _} -> flush(key)
      {:source_search, ^key, _, _} -> flush(key)
    after
      0 -> :ok
    end
  end

  defp topic(term), do: "source_search:" <> key(term)

  ## Server

  @impl true
  def init(_opts) do
    {:ok,
     %{
       # key => %{id: ref, statuses: statuses}, for terms with a source still
       # searching. The id tells this search's timeout from an earlier one's.
       searches: %{},
       # task ref => {key, source_name, pid}
       tasks: %{},
       # key => {finished_at, statuses}, for terms answered within the ttl
       recent: %{}
     }}
  end

  @impl true
  # The sites are asked for `term` as the first reader typed it, since a
  # site's search may rank by word order even though it matches in any.
  def handle_call({:request, key, term}, _from, state) do
    state = prune(state)

    cond do
      String.length(key) < @min_length -> {:reply, %{}, state}
      Map.has_key?(state.searches, key) -> {:reply, state.searches[key].statuses, state}
      Map.has_key?(state.recent, key) -> {:reply, elem(state.recent[key], 1), state}
      true -> start(key, term, state)
    end
  end

  defp start(key, term, state) do
    tasks =
      for crawler <- config(:crawlers, Crawlers.all()), into: %{} do
        task = Task.Supervisor.async_nolink(@tasks, Crawlers, :search, [crawler, term])
        {task.ref, {key, crawler.source_name(), task.pid}}
      end

    statuses = Map.new(tasks, fn {_ref, {_key, source, _pid}} -> {source, :searching} end)
    id = make_ref()
    _timer = Process.send_after(self(), {:timeout, key, id}, config(:timeout, @timeout))

    state = %{
      state
      | searches: Map.put(state.searches, key, %{id: id, statuses: statuses}),
        tasks: Map.merge(state.tasks, tasks)
    }

    {:reply, statuses, state}
  end

  @impl true
  def handle_info({ref, result}, state) when is_map_key(state.tasks, ref) do
    Process.demonitor(ref, [:flush])

    status =
      case result do
        {:ok, counts} -> {:done, counts}
        {:error, reason} -> {:failed, reason}
      end

    {:noreply, answer(state, ref, status)}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state)
      when is_map_key(state.tasks, ref) do
    {:noreply, answer(state, ref, {:failed, {:crashed, reason}})}
  end

  def handle_info({:timeout, key, id}, state) do
    case state.searches do
      %{^key => %{id: ^id}} -> {:noreply, give_up(key, state)}
      _finished -> {:noreply, state}
    end
  end

  # A reply or DOWN for a task already given up on.
  def handle_info(_message, state), do: {:noreply, state}

  defp give_up(key, state) do
    late = for {ref, {^key, _source, _pid}} <- state.tasks, do: ref

    Enum.reduce(late, state, fn ref, state ->
      {_key, _source, pid} = state.tasks[ref]
      # A task killed mid-write rolls its transaction back, so the index is
      # never left with half a source's answer.
      Process.demonitor(ref, [:flush])
      # `{:error, :not_found}` is a task that finished as it was given up on.
      _ = Task.Supervisor.terminate_child(@tasks, pid)
      answer(state, ref, {:failed, :timeout})
    end)
  end

  defp answer(state, ref, status) do
    {{key, source, _pid}, tasks} = Map.pop(state.tasks, ref)
    search = state.searches[key]
    statuses = Map.put(search.statuses, source, status)
    :ok = broadcast(key, {:source_search, key, source, status})

    if searching?(statuses) do
      search = %{search | statuses: statuses}
      %{state | tasks: tasks, searches: Map.put(state.searches, key, search)}
    else
      :ok = broadcast(key, {:source_search_done, key, statuses})

      recent =
        if Enum.all?(statuses, &match?({_source, {:done, _}}, &1)),
          do: Map.put(state.recent, key, {now(), statuses}),
          else: state.recent

      %{state | tasks: tasks, searches: Map.delete(state.searches, key), recent: recent}
    end
  end

  defp broadcast(key, message), do: Phoenix.PubSub.broadcast(@pubsub, topic(key), message)

  defp prune(state) do
    cutoff = now() - config(:ttl, @ttl)
    %{state | recent: Map.reject(state.recent, fn {_key, {at, _}} -> at <= cutoff end)}
  end

  defp now, do: System.monotonic_time(:millisecond)

  # Read on every use rather than once at start, so a test can change it.
  defp config(key, default) do
    :magnetissimo |> Application.get_env(__MODULE__, []) |> Keyword.get(key, default)
  end
end
