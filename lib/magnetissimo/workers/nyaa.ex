defmodule Magnetissimo.Workers.Nyaa do
  use Oban.Worker,
    queue: :nyaa,
    max_attempts: 3

  alias Magnetissimo.Crawlers.Nyaa

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"search_term" => search_term} = _args}) do
    Nyaa.search(search_term)
    :ok
  end
end
