defmodule Magnetissimo.Utils do
  @doc """
  Returns the size in bytes from a string like "1.2 GB"
  in integer format.

  ## Examples

      iex> size_to_bytes("1.2 GB")
      1288490188

      iex> size_to_bytes("1.2 MB")
      1258291

      iex> size_to_bytes("1.2 KB")
      1228

      iex> size_to_bytes("1.2 B")
      1
  """
  @spec size_to_bytes(String.t()) :: integer()
  def size_to_bytes(size_string) do
    [size, unit] = String.split(size_string, ~r/\p{Zs}+/u)
    {size, _} = Float.parse(size)
    unit = String.downcase(unit)

    case unit do
      "tb" -> size * 1_000_000_000_000
      "TB" -> size * 1_000_000_000_000
      "tib" -> size * 1_000_000_000_000
      "TiB" -> size * 1_000_000_000_000
      "gb" -> size * 1_000_000_000
      "GB" -> size * 1_000_000_000
      "gib" -> size * 1_000_000_000
      "GiB" -> size * 1_000_000_000
      "mb" -> size * 1_000_000
      "MB" -> size * 1_000_000
      "mib" -> size * 1_000_000
      "MiB" -> size * 1_000_000
      "kb" -> size * 1_000
      "KB" -> size * 1_000
      "kib" -> size * 1_000
      "KiB" -> size * 1_000
      "b" -> size
      "B" -> size
    end
    |> Kernel.trunc()
  end
end
