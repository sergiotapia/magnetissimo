defmodule Magnetissimo.Crawlers.Scheduler do
  @moduledoc """
  Runs one crawler on a timer.

  Started once per source from `Magnetissimo.Application`. The first crawl
  happens one interval after boot rather than at boot, so neither a dev server
  nor a test run reaches out to the network the moment it starts.
  """

  use GenServer

  alias Magnetissimo.Crawlers

  @interval :timer.minutes(5)

  @doc """
  Starts a scheduler for `opts[:crawler]`, a `Magnetissimo.Crawlers.Crawler`.

  `opts[:interval]` overrides the five minute default, in milliseconds.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  @impl true
  def init(opts) do
    crawler = Keyword.fetch!(opts, :crawler)
    interval = Keyword.get(opts, :interval, @interval)
    schedule(interval)

    {:ok, %{crawler: crawler, interval: interval}}
  end

  @impl true
  def handle_info(:crawl, state) do
    :ok = Crawlers.crawl_latest(state.crawler)
    schedule(state.interval)

    {:noreply, state}
  end

  defp schedule(interval), do: Process.send_after(self(), :crawl, interval)
end
