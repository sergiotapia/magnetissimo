defmodule Magnetissimo.Crawlers.Nyaa do
  use GenServer
  import SweetXml

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    schedule_rss_fetch()
    {:ok, state}
  end

  def handle_info(:rss_fetch, state) do
    rss_body = rss()

    result =
      rss_body
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./guid/text()",
          published_at: ~x"./pubDate/text()",
          seeders: ~x"./nyaa:seeders/text()",
          leechers: ~x"./nyaa:leechers/text()",
          magnet_url: ~x"./nyaa:infoHash/text()",
          size: ~x"./nyaa:size/text()"
        ]
      )

    # TODO - Persist torrents into database.

    schedule_rss_fetch()
    {:noreply, state}
  end

  defp rss do
    "https://nyaa.si/?page=rss"
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  defp schedule_rss_fetch do
    Process.send_after(self(), :rss_fetch, 5_000)
  end
end
