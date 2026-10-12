defmodule Magnetissimo.DHT.SettingsTest do
  # Not async: the settings row and the runner are shared.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.DHT
  alias Magnetissimo.DHT.Runner

  setup do
    on_exit(fn -> Runner.apply_config(%{DHT.config(%DHT.Settings{}) | enabled: false}) end)
  end

  defp crawler do
    case DynamicSupervisor.which_children(DHT.CrawlerSlot) do
      [{_id, pid, _type, _modules}] -> Agent.get(pid, & &1)
      [] -> nil
    end
  end

  test "with nothing saved the crawler is off, at the gentle rate" do
    assert %{enabled: false, rate: "gentle"} = DHT.settings()
    assert %{enabled: false, preset: :gentle, rate: 20, fetches: 8} = DHT.config()
  end

  test "switching it on starts the crawler at the saved rate, and off stops it" do
    :ok = DHT.subscribe()

    assert {:ok, %{enabled: true, rate: "normal"}} =
             DHT.update_settings(%{enabled: true, rate: "normal"})

    assert_receive {:dht_settings, %{enabled: true}}
    assert %{enabled: true, preset: :normal, rate: 75} = crawler()
    assert %{enabled: true, rate: "normal"} = DHT.settings()

    {:ok, _} = DHT.update_settings(%{enabled: false})
    assert crawler() == nil
    assert_receive {:dht_status, %{running: false}}
  end

  test "a new rate restarts the crawler at it" do
    {:ok, _} = DHT.update_settings(%{enabled: true, rate: "gentle"})
    [{_, first, _, _}] = DynamicSupervisor.which_children(DHT.CrawlerSlot)
    ref = Process.monitor(first)

    {:ok, _} = DHT.update_settings(%{rate: "max"})

    assert_receive {:DOWN, ^ref, :process, ^first, _reason}
    assert %{preset: :max, rate: 250, fetches: 64} = crawler()
  end

  test "saving the same settings leaves the running crawler alone" do
    {:ok, _} = DHT.update_settings(%{enabled: true, rate: "gentle"})
    [{_, pid, _, _}] = DynamicSupervisor.which_children(DHT.CrawlerSlot)

    {:ok, _} = DHT.update_settings(%{enabled: true, rate: "gentle"})
    assert [{_, ^pid, _, _}] = DynamicSupervisor.which_children(DHT.CrawlerSlot)
  end

  test "an unknown rate is refused, and nothing changes" do
    assert {:error, changeset} = DHT.update_settings(%{enabled: true, rate: "ludicrous"})
    assert %{rate: [_]} = errors_on(changeset)
    assert crawler() == nil
  end
end
