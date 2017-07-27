defmodule Mix.Tasks.Fixtures.Download do
  use Mix.Task

  @fixtures_basepath "test/fixtures/"
  @chrome_ua "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"

  @headers [
            {"Accept", "text/html,application/xhtml+xml"},
            {"User-Agent", @chrome_ua}
           ]

  @options [follow_redirect: true, max_redirect: 10]

  @fixtures %{
    "limetorrents" => "https://www.limetorrents.cc/search/movies/sintel-2010/",
    "limetorrents_torrent_info" => "https://www.limetorrents.cc/Sintel-(2010)-BR2Mini-DVD-DD5-1-NL-Subs-torrent-938931.html",
    "torrentdownloads" => "https://www.torrentdownloads.me/search/?search=sintel+2010",
    "torrentdownloads_torrent_info" => "https://www.torrentdownloads.me/torrent/1652059056/Sintel+2010+2K+SURROUND+x264-VODO",
    "worldwidetorrents" => "http://worldwidetorrents.eu/torrents-search.php?search=It%27s+a+Wonderful+Life+1946&cat=0&incldead=0&lang=0"
  }

  @shortdoc "update test fixtures from upstream"

  def run([fixture_name]) do
    {:ok, _started} = Application.ensure_all_started(:httpoison)

    case Map.fetch(@fixtures, fixture_name) do
      {:ok, url} -> download(fixture_name, url)
      _ -> IO.warn "invalid fixture name, valid names are: #{fixtures_names}"
    end
  end

  defp download(fixture_name, url) do
    case HTTPoison.get(url, @headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        save_response(fixture_name, body)
      {:ok, %HTTPoison.Response{status_code: code}} ->
        IO.warn "#{url} returned invalid status code: #{code}"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.warn "HTTPoison returned error: #{inspect reason}"
    end
  end

  defp save_response(fixture_name, body) do
    file =
      fixture_name
      |> filename
      |> File.open!([:write])

    case IO.binwrite(file, body) do
      {:error, error} ->
        IO.warn "error occured while writing the file: #{inspect error}"
      _ ->
        IO.puts "#{fixture_name} successfully updated"
    end

    File.close(file)
  end

  defp filename(name), do: Path.absname(@fixtures_basepath <> name)

  defp fixtures_names do
    @fixtures |> Enum.map_join(", ", fn({name, url}) -> name end)
  end
end
