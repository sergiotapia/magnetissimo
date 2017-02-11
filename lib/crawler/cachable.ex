defmodule Magnetissimo.Crawler.Cachable do
  defmacro __using__(_) do
    quote do
			alias Magnetissimo.KV
			def process({:torrent_link_cache, url}, queue) do
				case KV.cached?(url) do
          false ->
            process({:torrent_link, url}, queue)
            KV.cache(url)
            IO.puts "Caching #{url}"
          {:ok, timestamp} -> IO.puts "Already cached at #{timestamp} #{url}"
        end
				queue
			end
    end
  end
end
