defmodule Magnetissimo.Torrents.FileListSearchTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Torrents
  alias Magnetissimo.Torrents.Query
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()
    :ok
  end

  defp fixture(name, files \\ nil) do
    TorrentsFixtures.torrent_fixture(%{
      name: name,
      description: nil,
      files: files,
      file_count: files && length(files)
    })
  end

  defp file(path, size \\ 1_000_000), do: %{path: path, size: size}

  defp names(query, opts \\ []) do
    query |> Torrents.search_torrents(opts) |> Enum.map(& &1.name)
  end

  test "a torrent is found by a file inside it" do
    fixture("Show S01 1080p", [file("Show.S01/Show.S01E01.mkv"), file("Subs/Klingon.srt")])
    fixture("Another Show S02")

    assert names("klingon") == ["Show S01 1080p"]
    assert Torrents.count_search_torrents("klingon") == 1
  end

  test "file sizes are not searchable" do
    fixture("Big Pack", [file("disc.iso", 2_019_123_456)])

    assert names("2019123") == []
  end

  test "a search of names only ignores file lists" do
    fixture("Show S01 1080p", [file("Subs/Klingon.srt")])

    assert names("klingon", scope: :name) == []
  end

  test "a short word in a file name is found through the word index" do
    fixture("Album Pack", [file("CD 1/01 - Up.flac")])

    assert names("up") == ["Album Pack"]
  end

  test "an exclusion leaves out a torrent with a matching file" do
    fixture("Movie 2024 1080p", [file("Movie.mkv"), file("Sample/sample.mkv")])
    fixture("Movie 2024 720p", [file("Movie.mkv")])

    assert names(Query.parse("movie 2024 -sample")) == ["Movie 2024 720p"]
  end

  test "quoted text matches a file name" do
    fixture("Pack", [file("[Group] Episode 01.mkv")])

    assert names(Query.parse(~s("[Group] Episode"))) == ["Pack"]
  end

  test "a name match ranks above a file match" do
    fixture("Something Else", [file("Frieren/Frieren - 01.mkv")])
    fixture("Sousou no Frieren 01")

    assert names("frieren") == ["Sousou no Frieren 01", "Something Else"]
  end

  test "the file list is stored with its paths and sizes" do
    torrent = fixture("Pack", [file("a/b.mkv", 5), file("c.nfo", 7)])

    assert torrent.files == [
             %{"path" => "a/b.mkv", "size" => 5},
             %{"path" => "c.nfo", "size" => 7}
           ]

    assert torrent.file_count == 2
    assert torrent.file_names == "a/b.mkv\nc.nfo"
  end
end
