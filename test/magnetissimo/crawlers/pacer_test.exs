defmodule Magnetissimo.Crawlers.PacerTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.Crawlers.Pacer

  # Every test runs a pacer of its own, configured by its options, so none
  # waits on the app's or on another test's.
  defp start_pacer(opts), do: start_supervised!({Pacer, [name: nil] ++ opts})

  # Searches `source` through `pacer` in a process of its own, which reports
  # `{:started, pid}` once admitted and holds its slot until sent `:finish`.
  defp search(pacer, source) do
    test = self()

    spawn(fn ->
      Pacer.run(pacer, source, fn ->
        send(test, {:started, self()})

        receive do
          :finish -> :ok
        end
      end)
    end)
  end

  # Long enough for a spawned search to have reached the pacer's line.
  @queued 50

  test "returns what the search returns" do
    pacer = start_pacer(concurrency: 1, interval: 0)
    assert Pacer.run(pacer, "YTS", fn -> :answer end) == :answer
  end

  test "a site runs only so many searches at once, in the order asked" do
    pacer = start_pacer(concurrency: 1, interval: 0)

    first = search(pacer, "YTS")
    assert_receive {:started, ^first}

    second = search(pacer, "YTS")
    refute_receive {:started, ^second}, @queued
    third = search(pacer, "YTS")
    refute_receive {:started, ^third}, @queued

    send(first, :finish)
    assert_receive {:started, ^second}
    refute_receive {:started, ^third}, @queued

    send(second, :finish)
    assert_receive {:started, ^third}
  end

  test "one site's line does not hold up another's" do
    pacer = start_pacer(concurrency: 1, interval: 0)

    yts = search(pacer, "YTS")
    assert_receive {:started, ^yts}

    nyaa = search(pacer, "Nyaa.si")
    assert_receive {:started, ^nyaa}
  end

  test "searches start at least the interval apart, even with a slot free" do
    pacer = start_pacer(concurrency: 2, interval: :timer.minutes(1))

    first = search(pacer, "YTS")
    assert_receive {:started, ^first}

    second = search(pacer, "YTS")
    refute_receive {:started, ^second}, @queued
  end

  test "a search that is killed mid-way frees its slot" do
    pacer = start_pacer(concurrency: 1, interval: 0)

    first = search(pacer, "YTS")
    assert_receive {:started, ^first}
    waiting = search(pacer, "YTS")
    refute_receive {:started, ^waiting}, @queued

    Process.exit(first, :kill)
    assert_receive {:started, ^waiting}
  end

  test "a caller that dies in line leaves without using a turn" do
    pacer = start_pacer(concurrency: 1, interval: 0)

    first = search(pacer, "YTS")
    assert_receive {:started, ^first}
    gave_up = search(pacer, "YTS")
    refute_receive {:started, ^gave_up}, @queued
    next = search(pacer, "YTS")
    refute_receive {:started, ^next}, @queued

    ref = Process.monitor(gave_up)
    Process.exit(gave_up, :kill)
    assert_receive {:DOWN, ^ref, :process, ^gave_up, :killed}

    send(first, :finish)
    assert_receive {:started, ^next}
  end
end
