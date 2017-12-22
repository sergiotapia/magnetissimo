defmodule MagnetissimoWeb.PageView do
  use MagnetissimoWeb, :view
  import Scrivener.HTML

  def readable_size(bytes) do
    Sizeable.filesize(bytes)
  end

  def seeders(seeders) do
    seeders || 0
  end

  def leechers(leechers) do
    leechers || 0
  end
end
