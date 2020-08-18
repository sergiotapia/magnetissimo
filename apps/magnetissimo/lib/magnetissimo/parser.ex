defmodule Magnetissimo.Parser do
  require Logger
  
  def pubdate(datetime, format, opts \\ [])
  def pubdate(datetime, format, opts) when is_list(datetime) do
    pubdate(List.to_string(datetime), format, opts) end
  def pubdate(datetime, format, opts) do
    Logger.debug("[#{__MODULE__}] Parsing datetime: #{datetime}, #{format} (#{opts})")
        
    case (cond do
      opts == [] -> datetime |> Timex.parse(format)
      true -> datetime |> Timex.parse(format, opts)
    end) do
      {:ok, published_at} -> published_at
      {:error, reason} ->
        Logger.error("[#{__MODULE__}] Could not parse datetime (format, opts): #{datetime} (#{format}, #{opts})")
        Logger.error("[#{__MODULE__}] Error: #{reason}")
        nil
    end
  end

  def magnet_hash(string) when is_list(string)
    do magnet_hash(List.to_string(string)) end
  def magnet_hash(string) do
    List.to_string(Regex.run(~r/[A-F\d]{40}/i, string))
  end

  def bytes(size_string, units \\ "bytes")
  def bytes(size, units) when is_list(size) do
    bytes(List.to_string(size), units) end
  def bytes(size_string, units) do
    with {size, _} <- String.replace(size_string, ",", "") |> Float.parse() do
      trunc(Float.ceil(size * bytes_multiplier(units)))
    else
      _ ->
        Logger.error("[#{__MODULE__}] Could not get size from string: #{size_string}")
        0
    end
  end

  defp bytes_multiplier(units) do
    units = String.downcase(units)
    cond do
      units in ["gb", "gib"] -> 1073741824
      units in ["mb", "mib"] -> 1048576
      units in ["kb", "kib"] -> 1024
      units in ["b", "bytes"] -> 1
      true -> 
        Logger.error("[#{__MODULE__}] Could not match size units: #{units}")
        0
    end
  end

  def integer(value) when is_integer(value) do value end
  def integer(value) when is_list(value) do
    integer(List.to_string(value)) end
  def integer(value) do
    case value |> Integer.parse() do
      {integer, _} -> integer
      :error ->
        Logger.error("[#{__MODULE__}] Could not get integer from '#{value}'")
        0
    end
  end

  def float(value) when is_float(value) do value end
  def float(value) when is_list(value) do
    float(List.to_string(value)) end
  def float(value) do
    case value |> Float.parse() do
      {float, _} -> float
      :error ->
        Logger.error("[#{__MODULE__}] Could not get float from '#{value}'")
        0.0
    end
  end
  
end
