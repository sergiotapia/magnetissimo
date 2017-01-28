defmodule Magnetissimo.PageView do
  use Magnetissimo.Web, :view
  import Scrivener.HTML

  def readable_size(bytes) do
    cond do
      # bytes < 1024 ->
      #   "#{bytes} B"
      # bytes < 1048576 ->
      #   "#{bytes/1024} KB"
      # bytes < 1073741824 ->
      #   "#{bytes/1048576} MB"
      true ->
        "#{bytes}"
    end
  end

  def seeders(seeders) do
    seeders || 0
  end

  def leechers(leechers) do
    leechers || 0
  end
end
