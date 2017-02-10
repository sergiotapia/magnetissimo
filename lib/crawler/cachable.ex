defmodule Magnetissimo.Crawler.Cachable do
  defmacro __using__(_) do
    quote do
			alias Magnetissimo.KV
			def process({:torrent_link_cache, url}, queue) do
				case KV.cached?(url) do
          {:ok, timestamp} -> IO.puts "Already cached at #{timestamp} #{url}"
          false ->
            queue = [{:torrent_link, url} | queue]
            KV.cache(url)
        end
				queue
			end
    end
  end
end
