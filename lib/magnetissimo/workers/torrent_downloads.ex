defmodule Magnetissimo.Workers.TorrentDownloads do
  use Oban.Worker,
    queue: :torrent_downloads,
    max_attempts: 3

  alias Magnetissimo.Crawlers.TorrentDownloads

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"search_term" => search_term} = _args}) do
    TorrentDownloads.search(search_term)
    :ok
  end
end
