defmodule Magnetissimo.Genservers.Nyaa do
  use GenServer
  require Logger
  alias Magnetissimo.Crawlers.Nyaa

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    schedule_crawl_latest()
    {:ok, state}
  end

  def handle_info(:crawl_latest, state) do
    Nyaa.crawl_latest()
    schedule_crawl_latest()
    {:noreply, state}
  end

  defp schedule_crawl_latest do
    # Crawl latest every 5 minutes.
    Process.send_after(self(), :crawl_latest, 300_000)
  end
end
