defmodule Magnetissimo.DHT.Supervisor do
  @moduledoc """
  Always running: a slot for the crawler (`Magnetissimo.DHT.CrawlerSlot`, a
  `DynamicSupervisor`) and `Magnetissimo.DHT.Runner`, which fills or empties
  it to match the settings. With the DHT switched off, the slot is empty and
  nothing touches the network.
  """

  use Supervisor

  alias Magnetissimo.DHT

  def start_link(opts), do: Supervisor.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    children = [
      {DynamicSupervisor, name: DHT.CrawlerSlot, strategy: :one_for_one},
      DHT.Runner
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
