defmodule Magnetissimo.Crawlers.Nyaa do
  use GenServer
  import SweetXml
  require Logger
  alias Magnetissimo.{Repo, Torrent}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    schedule_rss_fetch()
    {:ok, state}
  end

  def handle_info(:rss_fetch, state) do
    rss_body = rss()

    %{torrents: torrents} =
      rss_body
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./guid/text()",
          published_at: ~x"./pubDate/text()",
          seeds: ~x"./nyaa:seeders/text()",
          leechers: ~x"./nyaa:leechers/text()",
          magnet_url: ~x"./nyaa:infoHash/text()",
          size: ~x"./nyaa:size/text()"
        ]
      )

    Enum.each(torrents, fn torrent_data ->
      save_torrent(torrent_data)
    end)

    schedule_rss_fetch()
    {:noreply, state}
  end

  defp save_torrent(data) do
    {seeds, _} = List.to_string(data.seeds) |> Integer.parse()
    {leechers, _} = List.to_string(data.leechers) |> Integer.parse()
    name = List.to_string(data.name)
    canonical_url = List.to_string(data.canonical_url)
    magnet_url = List.to_string(data.magnet_url)

    torrent =
      Torrent.changeset(%Torrent{}, %{
        name: name,
        canonical_url: canonical_url,
        magnet_url: magnet_url,
        leechers: leechers,
        seeds: seeds,
        website_source: "Nyaa",
        size: 0
      })

    Repo.insert(torrent)
  end

  defp rss do
    Logger.info("[Nyaa] Downloading url: https://nyaa.si/?page=rss")

    "https://nyaa.si/?page=rss"
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  defp schedule_rss_fetch do
    Process.send_after(self(), :rss_fetch, 5_000)
  end
end
