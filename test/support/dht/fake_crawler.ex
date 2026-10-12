defmodule Magnetissimo.DHT.FakeCrawler do
  @moduledoc """
  What `Magnetissimo.DHT.Runner` starts in tests in place of the crawler: a
  process holding the config it was started with, and nothing else.
  """

  def start_link(config), do: Agent.start_link(fn -> config end)
end
