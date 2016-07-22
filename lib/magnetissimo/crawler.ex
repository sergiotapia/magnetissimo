defmodule Magnetissimo.Crawler do
  def crawl(url, root, previously_crawled) do
    cond do
      String.starts_with?(url, "magnet:") ->
        create_torrent(url)
      true ->
        cond do
          url in previously_crawled ->
            IO.puts "Already crawled, in collection: #{previously_crawled}"
            {:no_work, previously_crawled}
          true ->
            IO.puts "Processing #{url}"
            case HTTPoison.get(url) do
              {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                body
                |> Floki.find("a")
                |> Floki.attribute("href")
                |> Enum.each(fn(href) ->
                  IO.puts "--Crawl next #{href}"
                  cond do
                    String.starts_with?(href, "/")  ->
                      crawl_url = root <> href
                      IO.puts "----Diving deep #{crawl_url}"
                      crawl(crawl_url, root, [crawl_url | previously_crawled])
                    true ->
                      IO.puts "----External link, ignoring"
                  end
                end)
              {:ok, %HTTPoison.Response{status_code: 404}} ->
                IO.puts "Not found :("
              {:error, %HTTPoison.Error{reason: reason}} ->
                IO.inspect reason
            end
        end
    end
  end

  def create_torrent(url) do
    IO.puts "Creating Torrent for: #{url}"
    # Create Torrent object and save to database.
  end
end
