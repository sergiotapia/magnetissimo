defmodule Magnetissimo.DHT.Table do
  @moduledoc """
  The nodes the crawler knows and when each may be asked again.

  Not a Kademlia routing table: a read-only crawler never answers anyone,
  so it needs no buckets, only a frontier. Every node is keyed by address,
  and waits in a set ordered by the time it is next due. `pop_due/2` hands
  out the node that has waited longest. A new node is due at once; one that
  answered is due again after the interval it asked for (BEP 51), and never
  sooner than five minutes; one that failed twice is dropped.

  The table holds at most `max` nodes and refuses new ones past that, so a
  long run cannot grow it without bound.
  """

  @min_interval 300_000
  @unsupported_interval 6 * 3_600_000
  @max_failures 2

  defstruct nodes: %{}, due: :gb_sets.empty(), max: 50_000

  @type t :: %__MODULE__{}

  @spec new(pos_integer()) :: t()
  def new(max \\ 50_000), do: %__MODULE__{max: max}

  @spec size(t()) :: non_neg_integer()
  def size(%__MODULE__{nodes: nodes}), do: map_size(nodes)

  @doc "Adds a node, due now. A known one, or one past `max`, is left out."
  @spec add(t(), binary(), term(), integer()) :: t()
  def add(%__MODULE__{nodes: nodes} = table, id, address, now) do
    if Map.has_key?(nodes, address) or map_size(nodes) >= table.max do
      table
    else
      %{
        table
        | nodes: Map.put(nodes, address, %{id: id, due: now, failures: 0, answered: nil}),
          due: :gb_sets.add({now, address}, table.due)
      }
    end
  end

  @doc """
  Takes the node that has been due the longest, if any is due at `now`. It
  leaves the due set until `answered/4` or `failed/3` puts it back.
  """
  @spec pop_due(t(), integer()) :: {:ok, term(), t()} | :none
  def pop_due(%__MODULE__{due: due} = table, now) do
    if :gb_sets.is_empty(due) do
      :none
    else
      case :gb_sets.take_smallest(due) do
        {{at, address}, rest} when at <= now -> {:ok, address, %{table | due: rest}}
        _not_yet -> :none
      end
    end
  end

  @doc "How many nodes are due at `now`, counted up to `limit`."
  @spec due_count(t(), integer(), pos_integer()) :: non_neg_integer()
  def due_count(%__MODULE__{due: due}, now, limit) do
    due
    |> :gb_sets.iterator()
    |> count_due(now, limit, 0)
  end

  defp count_due(_iterator, _now, limit, count) when count >= limit, do: count

  defp count_due(iterator, now, limit, count) do
    case :gb_sets.next(iterator) do
      {{at, _address}, next} when at <= now -> count_due(next, now, limit, count + 1)
      _ -> count
    end
  end

  @doc """
  A node answered. It is due again after `interval` seconds, or five minutes
  if that is sooner; `nil` means it doesn't sample (no BEP 51), and it waits
  six hours, since its only use is the nodes it names.
  """
  @spec answered(t(), term(), integer() | nil, integer()) :: t()
  def answered(table, address, interval, now) do
    wait = if interval, do: max(interval * 1000, @min_interval), else: @unsupported_interval
    reschedule(table, address, now + wait, fn node -> %{node | failures: 0, answered: now} end)
  end

  @doc "Puts a node back, due at `at`, as it was not its fault it wasn't asked."
  @spec later(t(), term(), integer()) :: t()
  def later(table, address, at), do: reschedule(table, address, at, & &1)

  @doc "A node failed to answer; the second failure in a row drops it."
  @spec failed(t(), term(), integer()) :: t()
  def failed(%__MODULE__{nodes: nodes} = table, address, now) do
    case nodes do
      %{^address => %{failures: failures, due: due}} when failures + 1 >= @max_failures ->
        %{
          table
          | nodes: Map.delete(nodes, address),
            due: :gb_sets.delete_any({due, address}, table.due)
        }

      %{^address => _node} ->
        reschedule(table, address, now + @min_interval, &%{&1 | failures: &1.failures + 1})

      _ ->
        table
    end
  end

  @doc "Up to `limit` nodes that have answered, most recent first, for saving."
  @spec answered_nodes(t(), pos_integer()) :: [{binary(), term()}]
  def answered_nodes(%__MODULE__{nodes: nodes}, limit) do
    nodes
    |> Enum.filter(fn {_address, node} -> node.answered end)
    |> Enum.sort_by(fn {_address, node} -> node.answered end, :desc)
    |> Enum.take(limit)
    |> Enum.map(fn {address, node} -> {node.id, address} end)
  end

  @doc "Up to `limit` known addresses, chosen at random."
  @spec random(t(), pos_integer()) :: [term()]
  def random(%__MODULE__{nodes: nodes}, limit) do
    nodes |> Map.keys() |> Enum.take_random(limit)
  end

  defp reschedule(%__MODULE__{nodes: nodes} = table, address, at, update) do
    case nodes do
      %{^address => node} ->
        due = :gb_sets.delete_any({node.due, address}, table.due)

        %{
          table
          | nodes: Map.put(nodes, address, update.(%{node | due: at})),
            due: :gb_sets.add({at, address}, due)
        }

      _ ->
        table
    end
  end
end
