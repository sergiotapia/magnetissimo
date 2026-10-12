defmodule Magnetissimo.DHT.ClassifierTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Classifier
  alias Magnetissimo.Taxonomy

  @gb 1_000_000_000
  @mb 1_000_000

  defp category(name, files) do
    files = for {path, size} <- files, do: %{path: path, size: size}

    case Classifier.classify(%{name: name, files: files}) do
      {:ok, id} -> Taxonomy.fetch!(id).name
      :banned -> :banned
    end
  end

  defp one(name, size \\ @gb), do: category(name, [{name, size}])

  test "video is a movie unless it is an episode, with the resolution picking the subcategory" do
    assert one("Scarecrows.1988.1080p.BluRay.mkv") == "Movies/HD"
    assert one("Dune.Part.Two.2024.2160p.WEB.mkv") == "Movies/UHD"
    assert one("Old.Film.1950.DVDRip.avi") == "Movies/SD"
    assert one("Some.Film.2020.x265.mkv") == "Movies/x265"
    assert one("Untagged Film.mp4") == "Movies"

    assert one("Star.Wars.Maul.S01E03.1080p.mkv") == "TV/HD"
    assert category("The.Show.S02.720p", [{"a.mkv", @gb}]) == "TV/HD"
    assert one("Show 3x07.avi") == "TV"
  end

  test "a season pack named for the show alone is TV by its episode files" do
    files =
      for i <- 1..12,
          do: {"Lucky Star/Lucky Star - #{String.pad_leading("#{i}", 2, "0")}.mkv", 300 * @mb}

    assert category("Lucky Star (Subbed & Dubbed)", files) == "TV"
  end

  test "fansub releases are anime" do
    assert one("[SubsPlease] Sousou no Frieren - 28 (1080p) [ABCD1234].mkv") == "TV/Anime"
  end

  test "audio is lossless, mp3 or an audiobook" do
    assert category("Album (1994)", [{"01.flac", 30 * @mb}, {"cover.jpg", @mb}]) ==
             "Audio/Lossless"

    assert category("Album", [{"01.mp3", 9 * @mb}]) == "Audio/MP3"
    assert category("Book", [{"Book.m4b", 300 * @mb}]) == "Audio/Audiobook"
    assert category("A Novel (Unabridged)", [{"01.mp3", 90 * @mb}]) == "Audio/Audiobook"
  end

  test "books, comics and software" do
    assert category("Murtagh (2023)", [{"a.epub", @mb}, {"a.pdf", 2 * @mb}]) == "Books/EBook"
    assert category("Comic 001", [{"c.cbz", 40 * @mb}]) == "Books/Comics"
    assert category("Tool 2.0", [{"setup.exe", 50 * @mb}]) == "PC"
    assert category("Game-FitGirl Repack", [{"setup.exe", @mb}, {"data.bin", @gb}]) == "PC/Games"
    assert category("App for Android", [{"app.apk", 50 * @mb}]) == "PC/Mobile-Android"
    assert category("Linux Distro", [{"distro.iso", @gb}]) == "PC/ISO"
  end

  test "adult content by keyword, with episodes winning over the loose words" do
    assert one("Site.21.05.12.Name.XXX.1080p.mp4") == "XXX"
    assert one("FC2-PPV-2457143.mp4") == "XXX"
    assert one("FC2PPV 3381983.mp4") == "XXX"
    assert one("Hardcore Compilation.mp4") == "XXX"
    assert category("Gallery", [{"pornstar 01.jpg", 5 * @mb}]) == "XXX/ImageSet"
    assert one("Sex.Education.S01E01.1080p.mkv") == "TV/HD"
    assert category("SABA-938", [{"SABA-938.mp4", @gb}]) == "XXX"
    assert category("109IENFH-29501-C", [{"a.mp4", @gb}]) == "XXX"
    assert one("【看黄片 btsuu.cc】星空传媒XKG145.mp4") == "XXX"
    assert one("Blade-Runner-2049.mkv") == "Movies"
    assert one("Alien-1979.mkv") == "Movies"
    assert one("NLE-038-C 狙われた美人な母 碓氷紗也.mp4") == "XXX"
    assert one("THX-1138 1971 1080p.mkv") == "Movies/HD"
  end

  test "anything else is Other" do
    assert category("Archive", [{"STRIFE.7z", 100 * @mb}]) == "Other"
  end

  test "banned keywords refuse the torrent, in the name or in any file" do
    assert one("something pthc something") == :banned
    assert category("Innocent name", [{"folder/preteen video.mp4", @gb}]) == :banned
    assert one("Twelve 12yo") == :banned
  end
end
