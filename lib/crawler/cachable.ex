defmodule Magnetissimo.Crawler.Cachable do
  defmacro __using__(_) do
    quote do
			alias Magnetissimo.KV
			def process({:torrent_link_cache, url}, queue) do
				case KV.cached?(url) do
          false -> process_cache(url, queue)
          {:ok, timestamp} ->
            now = :os.system_time(:seconds)
            if timestamp < now - 1*60*60 do
              IO.puts "Cache expired for #{url}"
              process_cache(url, queue)
            else
              IO.puts "Already cached at #{timestamp} #{url}"
            end
        end
				queue
			end

      def process_cache(url, queue) do
        process({:torrent_link, url}, queue)
        KV.cache(url)
        IO.puts "Caching #{url}"
      end
    end
  end
end
