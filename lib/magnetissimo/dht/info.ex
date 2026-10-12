defmodule Magnetissimo.DHT.Info do
  @moduledoc """
  Reads a torrent's info dictionary, once `Magnetissimo.DHT.PeerWire` has
  checked its hash, into what the index stores: a name, a total size and the
  file list.

  A single-file torrent has `length`; a multi-file one has `files`, each a
  `length` and a `path` as a list of components, inside a folder called
  `name`. Names prefer the `.utf-8` variants some clients add. Text that is
  not valid UTF-8 is read as Latin-1, which every byte sequence is, rather
  than dropped: an old torrent named in Windows-1252 keeps its accents mostly
  right. Padding files (BEP 47, `attr` containing `p`) are alignment filler
  and are not listed.

  Refused: a private torrent (BEP 27, `private: 1`), whose owner asked that
  it stay off the DHT and off indexes; one with no name or no files; one under
  1 KiB or over a pebibyte in total, or with a file over that; and a name or path holding a NUL byte, which no real
  filesystem allows.
  """

  alias Magnetissimo.DHT.Bencode
  alias Magnetissimo.Torrents.Torrent

  @min_size 1024
  # A torrent is a stranger's claim. SQLite stores 64-bit integers, so a
  # size past that would fail the write; nothing real is over a petabyte.
  @max_size 1_125_899_906_842_624

  @type t :: %{
          name: String.t(),
          size: non_neg_integer(),
          files: [%{path: String.t(), size: non_neg_integer()}],
          file_count: non_neg_integer()
        }

  @spec parse(binary()) :: {:ok, t()} | {:error, atom()}
  def parse(metadata) do
    with {:ok, %{} = info} <- Bencode.decode(metadata),
         :ok <- public(info),
         {:ok, name} <- name(info),
         {:ok, files} <- files(info, name) do
      size = files |> Enum.map(& &1.size) |> Enum.sum()

      cond do
        size < @min_size ->
          {:error, :too_small}

        size > @max_size ->
          {:error, :too_big}

        true ->
          {:ok,
           %{
             name: name,
             size: size,
             files: Enum.take(files, Torrent.max_files()),
             file_count: length(files)
           }}
      end
    else
      {:ok, _not_a_dict} -> {:error, :not_a_dictionary}
      {:error, reason} -> {:error, reason}
    end
  end

  defp public(%{"private" => 1}), do: {:error, :private}
  defp public(_info), do: :ok

  defp name(info) do
    case text(info["name.utf-8"] || info["name"]) do
      {:ok, ""} -> {:error, :no_name}
      result -> result
    end
  end

  defp files(%{"length" => length}, name) when is_integer(length) and length in 0..@max_size do
    {:ok, [%{path: name, size: length}]}
  end

  defp files(%{"files" => [_ | _] = files}, _name) do
    files
    |> Enum.reject(&padding?/1)
    |> Enum.reduce_while({:ok, []}, fn file, {:ok, acc} ->
      case file(file) do
        {:ok, file} -> {:cont, {:ok, [file | acc]}}
        error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, []} -> {:error, :no_files}
      {:ok, files} -> {:ok, Enum.reverse(files)}
      error -> error
    end
  end

  defp files(_info, _name), do: {:error, :no_files}

  defp padding?(%{"attr" => attr}) when is_binary(attr), do: String.contains?(attr, "p")
  defp padding?(_file), do: false

  defp file(%{"length" => length} = file) when is_integer(length) and length in 0..@max_size do
    case file["path.utf-8"] || file["path"] do
      [_ | _] = parts ->
        with {:ok, parts} <- texts(parts), do: {:ok, %{path: Enum.join(parts, "/"), size: length}}

      _ ->
        {:error, :bad_path}
    end
  end

  defp file(_file), do: {:error, :bad_file}

  defp texts(parts) do
    parts
    |> Enum.reduce_while({:ok, []}, fn part, {:ok, acc} ->
      case text(part) do
        {:ok, text} -> {:cont, {:ok, [text | acc]}}
        error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, texts} -> {:ok, Enum.reverse(texts)}
      error -> error
    end
  end

  defp text(value) when is_binary(value) do
    text = if String.valid?(value), do: value, else: :unicode.characters_to_binary(value, :latin1)

    if String.contains?(text, <<0>>),
      do: {:error, :nul_in_name},
      else: {:ok, String.trim(text)}
  end

  defp text(_value), do: {:error, :bad_name}
end
