defmodule Magnetissimo.Crawlers.Rarbg do
  @moduledoc """
  Downloads and saves the latest torrents from Rarbg.
  """

  use Timex
  alias Magnetissimo.Downloader
  alias Magnetissimo.Torrent

  def crawl() do
    {:ok, body} = Downloader.download(latest_url())
    case parse(Poison.decode!(body)) do
      {:ok, torrents} ->
        Enum.each(torrents, fn(torrent) -> Torrent.save(torrent) end)
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Parses json response from torrentapi.org into list of
  torrent structs.
  """
  def parse(%{"torrent_results" => results}) do
    torrents =
      results
      |> Enum.map(fn(torrent) ->
        pub_datetime = Timex.parse!(torrent["pubdate"], "%Y-%m-%d %l:%M:%S %z", :strftime)
        %{
          title: torrent["title"],
          magnet_url: torrent["download"],
          seeders: torrent["seeders"],
          leechers: torrent["leechers"],
          size: Integer.to_string(torrent["size"]),
          publication_date: pub_datetime,
          source_url: torrent["info_page"]
        }
      end)
    {:ok, torrents}
  end

  def parse(%{"error" => reason}) do
    {:error, reason}
  end

  @doc """
  Builds out URL to fetch last 100 torrents in the torrentapi
  website.
  """
  def latest_url() do
    {:ok, token} = get_token()
    "https://torrentapi.org/pubapi_v2.php?mode=list&token=#{token}&sort=last&format=json_extended&limit=100"
  end

  @doc """
  Fetches valid token from torrentapi.org for API access.

  Return `{:ok, token}`

  ## Examples

      iex> Magnetissimo.Crawlers.Rarbg.get_token()
      {:ok, "abcdefghij"}

  """
  @spec get_token() :: {:ok, binary}
  def get_token() do
    case Downloader.download("https://torrentapi.org/pubapi_v2.php?get_token=get_token") do
      {:ok, body} ->
        %{"token" => token} = Poison.decode!(body)
        {:ok, token}
      _ ->
        {:error, "Could not fetch new token"}
    end
  end
end