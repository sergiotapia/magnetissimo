defmodule Magnetissimo.SizeConverter do
  def size_to_bytes(size, unit) when is_binary(size) do
    {size_int, _} = Integer.parse(size)
    size_to_bytes(size_int, unit)
  end

  def size_to_bytes(size_int, "KB") do
    size_int * 1024
  end

  def size_to_bytes(size_int, "MB") do
    size_to_bytes(size_int, "KB") * 1024
  end

  def size_to_bytes(size_int, "GB") do
    size_to_bytes(size_int, "MB") * 1024
  end

  def size_to_bytes(size_int, "TB") do
    size_to_bytes(size_int, "GB") * 1024
  end
end
