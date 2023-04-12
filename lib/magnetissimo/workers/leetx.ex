defmodule Magnetissimo.Workers.Leetx do
  use Oban.Worker,
    queue: :leetx,
    max_attempts: 3

  alias Magnetissimo.Crawlers.Leetx

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"search_term" => search_term} = _args}) do
    Leetx.search(search_term)
    :ok
  end
end
