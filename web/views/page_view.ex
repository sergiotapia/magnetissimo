defmodule Magnetissimo.PageView do
  use Magnetissimo.Web, :view
  import Scrivener.HTML

  def seeders(seeders) do
    seeders || 0
  end

  def leechers(leechers) do
    leechers || 0
  end
end
