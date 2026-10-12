defmodule Magnetissimo.Torrents.FileList do
  @moduledoc """
  A torrent's file list, `[%{"path" => path, "size" => bytes}]`, stored as one
  JSON text column.

  It is its own type rather than `{:array, :map}` because the SQLite adapter
  dumps an array of maps element by element: `Repo.insert_all/3`, which is how
  `Magnetissimo.Torrents.index_torrents/2` writes, stored each map as a JSON
  string inside a JSON array, and the list read back as `nil`.
  """

  use Ecto.Type

  @impl true
  def type, do: :string

  @impl true
  def cast(files) when is_list(files) do
    if Enum.all?(files, &file?/1),
      do: {:ok, Enum.map(files, &normalize/1)},
      else: :error
  end

  def cast(_files), do: :error

  @impl true
  def dump(files) when is_list(files), do: {:ok, Jason.encode!(files)}
  def dump(_files), do: :error

  @impl true
  def load(json) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, files} when is_list(files) -> {:ok, files}
      _ -> :error
    end
  end

  def load(_json), do: :error

  defp file?(%{"path" => path, "size" => size}), do: is_binary(path) and is_integer(size)
  defp file?(%{path: path, size: size}), do: is_binary(path) and is_integer(size)
  defp file?(_file), do: false

  defp normalize(%{"path" => path, "size" => size}), do: %{"path" => path, "size" => size}
  defp normalize(%{path: path, size: size}), do: %{"path" => path, "size" => size}
end
