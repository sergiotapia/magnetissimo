defmodule Magnetissimo.Helpers do
  import Ecto.Changeset

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

    cond do
      unit in ["tb", "TB", "tib", "TiB"] -> size * 1_000_000_000_000
      unit in ["gb", "GB", "gib", "GiB"] -> size * 1_000_000_000
      unit in ["mb", "MB", "mib", "MiB"] -> size * 1_000_000
      unit in ["kb", "KB", "kib", "KiB"] -> size * 1_000
      unit in ["b", "B"] -> size
    end
    |> Kernel.trunc()
  end

  def slugify(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{name: name}} ->
        slug = Slug.slugify(name, separator: "-")

        changeset
        |> put_change(:slug, slug)

      _ ->
        changeset
    end
  end
end
