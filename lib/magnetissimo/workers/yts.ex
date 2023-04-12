defmodule Magnetissimo.Workers.Yts do
  use Oban.Worker,
    queue: :yts,
    max_attempts: 3

  alias Magnetissimo.Crawlers.Yts

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"search_term" => search_term} = _args}) do
    Yts.search(search_term)
    :ok
  end
end
