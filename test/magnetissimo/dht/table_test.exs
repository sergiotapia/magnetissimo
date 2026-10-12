defmodule Magnetissimo.DHT.TableTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Table

  @a {{1, 1, 1, 1}, 1}
  @b {{2, 2, 2, 2}, 2}
  @id String.duplicate("i", 20)

  test "a new node is due at once, oldest first, and leaves the due set when taken" do
    table = Table.new() |> Table.add(@id, @a, 0) |> Table.add(@id, @b, 5)

    assert {:ok, @a, table} = Table.pop_due(table, 10)
    assert {:ok, @b, table} = Table.pop_due(table, 10)
    assert Table.pop_due(table, 10) == :none
    assert Table.size(table) == 2
  end

  test "an answered node waits its interval, and never less than five minutes" do
    table = Table.new() |> Table.add(@id, @a, 0)
    {:ok, @a, table} = Table.pop_due(table, 0)

    table = Table.answered(table, @a, 60, 0)
    assert Table.pop_due(table, 299_999) == :none
    assert {:ok, @a, table} = Table.pop_due(table, 300_000)

    table = Table.answered(table, @a, 3_600, 300_000)
    assert Table.pop_due(table, 300_000 + 3_599_999) == :none
    assert {:ok, @a, _table} = Table.pop_due(table, 300_000 + 3_600_000)
  end

  test "a node that doesn't sample waits six hours" do
    table = Table.new() |> Table.add(@id, @a, 0)
    {:ok, @a, table} = Table.pop_due(table, 0)
    table = Table.answered(table, @a, nil, 0)

    assert Table.pop_due(table, 6 * 3_600_000 - 1) == :none
  end

  test "the second failure in a row drops a node" do
    table = Table.new() |> Table.add(@id, @a, 0)
    {:ok, @a, table} = Table.pop_due(table, 0)
    table = Table.failed(table, @a, 0)
    assert Table.size(table) == 1

    {:ok, @a, table} = Table.pop_due(table, 300_000)
    assert Table.size(Table.failed(table, @a, 300_000)) == 0
  end

  test "a node dropped without being taken is no longer handed out" do
    table = Table.new() |> Table.add(@id, @a, 0)
    table = table |> Table.failed(@a, 0) |> Table.failed(@a, 0)

    assert Table.size(table) == 0
    assert Table.pop_due(table, 10_000_000) == :none
    assert Table.due_count(table, 10_000_000, 10) == 0
  end

  test "a known node is not added twice, and the table refuses nodes past its size" do
    table =
      Table.new(1) |> Table.add(@id, @a, 0) |> Table.add(@id, @a, 0) |> Table.add(@id, @b, 0)

    assert Table.size(table) == 1
    assert Table.due_count(table, 0, 10) == 1
  end

  test "lists answered nodes, most recent first, for saving" do
    table =
      Table.new() |> Table.add(@id, @a, 0) |> Table.add("j" <> String.duplicate("j", 19), @b, 0)

    {:ok, @a, table} = Table.pop_due(table, 0)
    {:ok, @b, table} = Table.pop_due(table, 0)
    table = table |> Table.answered(@a, 0, 10) |> Table.answered(@b, 0, 20)

    assert [{_, @b}, {_, @a}] = Table.answered_nodes(table, 10)
  end
end
