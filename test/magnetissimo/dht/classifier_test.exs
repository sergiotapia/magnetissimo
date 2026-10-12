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

  # A torrent of one video, for names that are not file names.
  defp video(name), do: category(name, [{"video.mp4", @gb}])

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

  test "without a resolution, the source picks the quality" do
    assert one("The Lighthouse (2019) BDRemux 1080p.mkv") == "Movies/BluRay"
    assert video("Uyut.2019.DVD9.PAL.AIR23MJ") == "Movies/DVD"
    assert video("Bessmertnye.2021.WEB-DLRip.25Kuzmich") == "Movies/SD"
    assert video("Saving.Private.Ryan.1998.BDRip.BG.Audio") == "Movies/SD"
    assert video("Dune.Part.Two.2024.BDRip.1080p") == "Movies/HD"
    assert video("[shincaps] Film (KIDS 1440x1080 MPEG2 AAC)") == "Movies/HD"
    assert video("MobLand.2025.S01.WEB-DLRip-AVC.seleZen") == "TV/SD"
    assert video("Show.S01.1080p.BluRay.REMUX") == "TV/HD"

    assert category("Mumiya Legendy", [{"VIDEO_TS/VTS_01_1.VOB", @gb}]) == "Movies/DVD"
    assert category("Film", [{"Film/BDMV/STREAM/00000.m2ts", 20 * @gb}]) == "Movies/BluRay"
  end

  test "a season pack named for the show alone is TV by its episode files" do
    files =
      for i <- 1..12,
          do: {"Lucky Star/Lucky Star - #{String.pad_leading("#{i}", 2, "0")}.mkv", 300 * @mb}

    assert category("Lucky Star (Subbed & Dubbed)", files) == "TV"
  end

  test "seasons in other languages, dated shows and numbered episodes are TV" do
    assert video("Realnye.pacany.9 сезон.(2017).SATRip AVC.Files-x") =~ "TV"
    assert video("Para Toda La Humanidad - Temporada 1 [HDTV 720p][Cap.101]") == "TV/HD"
    assert video("Mad Men S01-S04 (2007-)") =~ "TV"
    assert video("My Little Pony - Friendship Is Magic (2010-2018) Seasons 1-8 WEB-DLRip") =~ "TV"
    assert video("BECK_[1-26_of_26]") =~ "TV"
    assert video("Panorama.2026.10.05.Cancer.Before.50.480p.x264-mSD") == "TV/SD"
    assert video("The.Daily.Show.2026.06.08.Jane.Fonda.720p.HEVC.x265-MeGusta") == "TV/HD"
    assert video("La belle saison (2015)") =~ "Movies"

    numbered = for i <- 1..3, do: {"[NAOKI-Raws] Higurashi no Naku Koro ni 0#{i}.mkv", 300 * @mb}
    assert category("higurashi", numbered) =~ "TV"

    bracketed = for i <- 1..3, do: {"[VCB-Studio] Sakura Quest [0#{i}][1080p].mkv", 300 * @mb}
    assert category("Sakura Quest [BDRip 1080p]", bracketed) =~ "TV"

    codecs = for i <- 1..3, do: {"Film #{i}. 720p.BluRay.x 264.mkv", @gb}
    assert category("Films", codecs) =~ "Movies"

    two_parts = for i <- 1..2, do: {"Film Part 0#{i}.mkv", @gb}
    assert category("Film", two_parts) =~ "Movies"
  end

  test "leagues and competitions are TV/Sport" do
    assert video("NFL 2026 Week 05 Tampa Bay Buccaneers at Dallas Cowboys 1080P.mkv") ==
             "TV/Sport"

    assert video("NBA_20260313_NYK @ IND_1080p60_FSN-IND.mkv") == "TV/Sport"

    assert video("Campeonato Brasileiro 2020. Série A. Matchday 11. Flamengo — Goiás") ==
             "TV/Sport"

    assert video("Чемпионат Бельгии 2019-20. 20 тур. Гент - Брюгге") == "TV/Sport"
    assert video("F1 (2025) 2160p") == "Movies/UHD"
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

    chapters = for i <- 1..10, do: {"#{i}.mp3", 20 * @mb}

    assert category("Тен Эдуард - Шайтан Иван. Книга 1 [Николай Прокофьев]", chapters) ==
             "Audio/Audiobook"

    assert category("Сенкевич Генрик - Камо грядеши [Петров Игорь]", chapters) ==
             "Audio/Audiobook"

    assert category("Ария - Герой асфальта (Сборник песен)", chapters) == "Audio/MP3"

    assert category("Forest Kingdom (John Keating) - 2014 (64kbps)", chapters) ==
             "Audio/Audiobook"

    long = [{"The Perennial Philosophy.mp3", 361 * @mb}]
    assert category("Aldous Huxley - The Perennial Philosophy", long) == "Audio/Audiobook"
    assert category("Essential Mix 2020-01-01", long) == "Audio/MP3"
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

  test "Japanese product codes, behind a forum's address or tags, are adult" do
    for name <- [
          "kss55.cc@CLUB-936C",
          "aavv39.xyz@117NPH-063",
          "第一會所新片@SIS001@KAVR-156-A",
          "madoubt.com 369262.xyz JUFE-448",
          "18bt.net_STARS-871C.mp4",
          "HEYZO-2700-FHD",
          "SDMU-802-U",
          "XV-1022HD",
          "EKDV-779ch",
          "KIDM-596(dvd)",
          "sddo-033[javstar.com].wmv",
          "sone-607",
          "MNGS_054_C_U.mp4",
          "HUNT680.avi",
          "dccdom.com@SSIS255C",
          "[HIBINO] SW-276 史上最强勃起藥.mp4",
          "CJOD-037.跡美しゅり",
          "SNTK-009 ナンパ連れ込みSEX隠し撮り Vol.9[2015-08-25]"
        ] do
      assert video(name) == "XXX", name
    end

    for name <- ["Alien-1979.mkv", "THX-1138 1971 1080p.mkv", "Blade-Runner-2049.mkv"] do
      refute video(name) == "XXX", name
    end

    refute video("KMHR-054 Koizumi Hinata Excited Constantly") == "XXX"
    refute video("Order_No_027.mkv") == "XXX"
    refute video("BDRIP_720p.mkv") == "XXX"
  end

  test "Western scene releases and studio names are adult" do
    assert video("RKPrime.20.12.26.Jewelz.Blu.Notice.Me.Take.Me..480p.MP4") == "XXX"
    assert video("BadoinkVR_Leveling_Up_7k_180_180x180_3dh.mp4") == "XXX"
    assert video("Mywife-1613_No.1008.mp4") == "XXX"
    assert video("(Caribbean)(070514-637) 1pondo") == "XXX"
    assert video("精品小旅馆偷窥大学生情侣.mp4") == "XXX"
    refute video("The.Daily.Show.2026.06.08.Jane.Fonda.720p.mkv") =~ "XXX"
    refute video("Pokemon Squirtle Special.mkv") =~ "XXX"
  end

  test "keywords never read a file's extension" do
    files = for i <- 1..2, ext <- ["mkv", "ass"], do: {"Sakura Quest [0#{i}].#{ext}", 300 * @mb}
    refute category("Sakura Quest", files) =~ "XXX"
  end

  test "a soundtrack's track names are not read for adult words" do
    files = [{"Dorohedoro [01].mkv", @gb}, {"OST/18. Upset small tits.flac", 30 * @mb}]
    refute category("Dorohedoro", files) =~ "XXX"
  end

  test "games are told from other software by their data, groups and repackers" do
    assert category("Gothic 1 Remake (2026)", [{"a.ucas", 10 * @gb}, {"trailer.mp4", @gb}]) ==
             "PC/Games"

    files = [{"setup.exe", @mb}, {"intro.mp4", @gb}, {"game.dat", 10 * @gb}]
    assert category("RoboCop.Rogue.City-InsaneRamZes", files) == "PC/Games"
    assert category("Tool", files) == "PC"

    assert category("Some Game", [
             {"game.exe", 50 * @mb},
             {"music.ogg", 400 * @mb},
             {"x.dat", @gb}
           ]) ==
             "PC"

    assert category("The.Sims.4-RELOADED", [{"sims.iso", @gb}]) == "PC/Games"
    assert category("Механоиды. Антология_[R.G. Catalyst]", [{"a.iso", @gb}]) == "PC/Games"
    assert category("Euro Truck Simulator 2", [{"setup.exe", @gb}]) == "PC/Games"

    office = "Microsoft Office 2007 Enterprise SP3 RePack by KpoJIuK"
    assert category(office, [{"setup.exe", @gb}]) == "PC"
  end

  test "doujinshi and adult picture sets are adult image sets" do
    zip = fn name -> category(name, [{name <> ".zip", 80 * @mb}]) end

    assert zip.("(C97) [Manmaru Hoppe (Yawaraka Midori)] Waka-chan to Issho 2") == "XXX/ImageSet"
    assert zip.("(成年コミック) [雑誌] WEEKLY 快楽天 2023 No.11") == "XXX/ImageSet"
    assert zip.("[Momoyama Jirou] Kairaku no Ikenie [English] [desudesu]") == "XXX/ImageSet"
    assert zip.("[furrAtelier] Label [AI Generated]") == "XXX/ImageSet"

    assert category("[Yadokugaeru (Locon)] Seisenryou 207 gou [Digital]", [{"01.jpg", @mb}]) ==
             "XXX/ImageSet"

    assert category("Stolen Nude Pics", [{"01.jpg", @mb}]) == "XXX/ImageSet"
    assert category("NASA [optik.1557]", [{"01.jpg", @mb}]) == "Other"
  end

  test "archives are filed by their name" do
    rar = fn name -> category(name, [{name <> ".rar", 500 * @mb}]) end

    assert rar.("DLRAW.APP_Kishio no Shokutaku vol 01-06") == "Books/Comics"
    assert rar.("Kakukaku Shikajika v05") == "Books/Comics"
    assert rar.("Wish v01-04 (2002-2003 Tokyopop)") == "Books/Comics"
    assert rar.("Tenorshare 4 uKey iTunes Backup 5.2.2.8 + Keygen") == "PC"
    assert rar.("The.Excavation.of.Hobs.Barrow.v1.05") == "PC"
    assert rar.("Halls.of.Torment.v2023.06.28") == "PC"
    assert rar.("MASH [BluRay 720p X264 MKV][AC3 2.0 Castellano][1970]") == "Movies/HD"
    assert category("Movie", [{"movie.part01.rar", @gb}, {"movie.r00", @gb}]) == "Other"
  end

  test "more video formats, and console games" do
    assert one("[诸神&动漫国][新世纪福音战士新剧场版][序].rmvb") =~ "Movies"
    assert category("Dead Cells [NSP]", [{"Dead Cells.nsp", @gb}]) == "Console/Other"
    assert category("Pokemon X", [{"pokemon.3ds", @gb}]) == "Console/3DS"
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
