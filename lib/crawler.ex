defmodule Magnetissimo.Crawler do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Process.send(self(), :work, [])
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    {:ok, queues} = Exq.Api.queue_size(Exq.Api.Server.server_name(nil))

    queue_sizes = for {_q, size} <- queues do
      size
    end
    enqueued_jobs = Enum.sum(queue_sizes)

    if enqueued_jobs == 0 do
      Logger.info "Initiating crawler run."
      Magnetissimo.Parsers.ThePirateBay.root_urls
      |> Enum.each(fn url -> 
        Logger.info "Queued: ThePirateBay root_urls"
        Exq.enqueue(Exq, "thepiratebay", "Magnetissimo.DownloadWorker", [url, "thepiratebay", "root_url"])
      end)

      Magnetissimo.Parsers.Demonoid.root_urls
      |> Enum.each(fn url -> 
        Logger.info "Queued: Demonoid root_urls"
        Exq.enqueue(Exq, "demonoid", "Magnetissimo.DownloadWorker", [url, "demonoid", "root_url"])
      end)

      Magnetissimo.Parsers.Isohunt.root_urls
      |> Enum.each(fn url -> 
        Logger.info "Queued: Isohunt root_urls"
        Exq.enqueue(Exq, "isohunt", "Magnetissimo.DownloadWorker", [url, "isohunt", "root_url"])
      end)

      Magnetissimo.Parsers.Limetorrents.root_urls
      |> Enum.each(fn url -> 
        Logger.info "Queued: Limetorrents root_urls"
        Exq.enqueue(Exq, "limetorrents", "Magnetissimo.DownloadWorker", [url, "limetorrents", "root_url"])
      end)

      Magnetissimo.Parsers.TorrentDownloads.root_urls
      |> Enum.each(fn url -> 
        Logger.info "Queued: TorrentDownloads root_urls"
        Exq.enqueue(Exq, "torrentdownloads", "Magnetissimo.DownloadWorker", [url, "torrentdownloads", "root_url"])
      end)

      Magnetissimo.Parsers.Leetx.root_urls
      |> Enum.each(fn url -> 
        Logger.info "Queued: 1337x root_urls"
        Exq.enqueue(Exq, "leetx", "Magnetissimo.DownloadWorker", [url, "leetx", "root_url"])
      end)
    else
      Logger.info "Enqueued jobs exist, still running."
    end

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 300) # 1 hour
  end
end