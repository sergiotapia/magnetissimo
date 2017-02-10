defmodule Magnetissimo.Crawler.Common do
  defmacro __using__(_) do
    quote do
			alias Magnetissimo.KV
			def process({:torrent_link_cache, url}, queue) do
				case KV.cached?(url) do
          {:ok, timestamp} -> process({:torrent_link, url}, queue)
          false -> IO.puts "Skipping #{url}"
        end
				queue
			end
    end
  end
end
