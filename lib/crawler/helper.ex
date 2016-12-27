defmodule Magnetissimo.Crawler.Helper do
  def download(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Error: #{url} is 404."
        nil
      {:error, %HTTPoison.Error{reason: _}} ->
        IO.puts "Error: #{url} just ain't workin."
        nil
    end
  end

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
