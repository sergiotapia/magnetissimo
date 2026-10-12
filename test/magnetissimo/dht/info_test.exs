defmodule Magnetissimo.DHT.InfoTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Bencode
  alias Magnetissimo.DHT.Info
  alias Magnetissimo.Torrents.Torrent

  defp parse(info), do: info |> Bencode.encode() |> IO.iodata_to_binary() |> Info.parse()

  test "reads a single-file torrent" do
    assert parse(%{"name" => "Movie.2024.mkv", "length" => 5_000}) ==
             {:ok,
              %{
                name: "Movie.2024.mkv",
                size: 5_000,
                files: [%{path: "Movie.2024.mkv", size: 5_000}],
                file_count: 1
              }}
  end

  test "reads a multi-file torrent, skipping padding files" do
    {:ok, info} =
      parse(%{
        "name" => "Show S01",
        "files" => [
          %{"length" => 4_000, "path" => ["Season 1", "E01.mkv"]},
          %{"length" => 96, "path" => [".pad", "96"], "attr" => "p"},
          %{"length" => 3_000, "path" => ["E02.mkv"]}
        ]
      })

    assert info.name == "Show S01"
    assert info.size == 7_000

    assert info.files == [
             %{path: "Season 1/E01.mkv", size: 4_000},
             %{path: "E02.mkv", size: 3_000}
           ]
  end

  test "prefers the utf-8 names and reads other bytes as Latin-1" do
    {:ok, info} = parse(%{"name" => "x", "name.utf-8" => "Amélie", "length" => 2_000})
    assert info.name == "Amélie"

    {:ok, info} = parse(%{"name" => <<"Am", 0xE9, "lie">>, "length" => 2_000})
    assert info.name == "Amélie"
  end

  test "keeps the first thousand files and counts them all" do
    files = for i <- 1..1_500, do: %{"length" => 10, "path" => ["#{i}.txt"]}
    {:ok, info} = parse(%{"name" => "Many", "files" => files})

    assert length(info.files) == Torrent.max_files()
    assert info.file_count == 1_500
  end

  test "refuses private, tiny, nameless and malformed torrents" do
    assert parse(%{"name" => "Secret", "length" => 5_000, "private" => 1}) == {:error, :private}
    assert parse(%{"name" => "Tiny", "length" => 10}) == {:error, :too_small}
    assert parse(%{"name" => "", "length" => 5_000}) == {:error, :no_name}
    assert parse(%{"name" => <<"a", 0, "b">>, "length" => 5_000}) == {:error, :nul_in_name}
    assert parse(%{"name" => "No files"}) == {:error, :no_files}
    assert parse(%{"name" => "Bad", "files" => [%{"length" => 5_000}]}) == {:error, :bad_path}
    assert Info.parse("not bencode") == {:error, :invalid}
  end

  test "refuses sizes no real torrent has, which would not fit the database" do
    assert parse(%{"name" => "Huge", "length" => 99_999_999_999_999_999_999}) ==
             {:error, :no_files}

    files = for _ <- 1..3, do: %{"length" => 1_000_000_000_000_000, "path" => ["x"]}
    assert parse(%{"name" => "Many huge", "files" => files}) == {:error, :too_big}
  end
end
