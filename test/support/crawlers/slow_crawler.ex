defmodule Magnetissimo.SlowCrawler do
  @moduledoc """
  A crawler for `Magnetissimo.SourceSearch` tests that answers only when told
  to, filed under Nyaa.si.

  It sends `{:crawled, "Nyaa.si", term, task_pid}` to the pid in
  `Application.get_env(:magnetissimo, :crawler_test_pid)` and then waits for
  `:go` before it finds one torrent named after the term. A test that never
  sends `:go` has a source that never answers.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  alias Magnetissimo.FastCrawler

  @impl true
  def source_name, do: "Nyaa.si"

  @impl true
  def categories, do: FastCrawler.categories()

  @impl true
  def latest, do: {:ok, []}

  @impl true
  def search(term) do
    case Application.get_env(:magnetissimo, :crawler_test_pid) do
      nil -> :ok
      pid -> send(pid, {:crawled, source_name(), term, self()})
    end

    receive do
      :go -> {:ok, [FastCrawler.attrs("#{term} slow", source_name())]}
    end
  end
end
