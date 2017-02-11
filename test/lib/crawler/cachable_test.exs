defmodule Magnetissimo.Crawler.CachableExample do
  use GenServer
  use Magnetissimo.Crawler.Cachable

  def start_link do
    GenServer.start_link(__MODULE__, initial_queue)
  end

  def init(queue) do
    GenServer.cast(self, :work)
    Process.send_after(self(), :work, 1 * 1 * 100) # 5 seconds
    {:ok, queue}
  end

  def initial_queue do
    :queue.from_list(["some.url"])
  end

  def process({:torrent_link, url}, queue) do
    Enum.filter(queue, fn(item) -> item !== {:torrent_link, url} end)
  end
  def process({:page_link, url}, queue) do
  end

  # Callbacks

  def handle_cast(:work, queue) do
    case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        queue = queue_2
        queue = process(item, queue)
      _ ->
        IO.puts "Queue is empty - restarting queue."
        queue = initial_queue
    end
    {:noreply, queue}
  end
end

defmodule Magnetissimo.Crawler.CachableTest do
  use ExUnit.Case, async: true

  test "keeps track of cached torrent_links" do
    {:ok, _} = Magnetissimo.Crawler.CachableExample.start_link

    assert [] == Magnetissimo.Crawler.CachableExample.process({:torrent_link_cache, "some.url"}, [])
    assert [] == Magnetissimo.Crawler.CachableExample.process({:torrent_link_cache, "some.url"}, [])
  end

end
