defmodule Magnetissimo.CrawlerTest do
  use ExUnit.Case

  test "parses torrent name from magnet link" do
    magnet = "magnet:?xt=urn:btih:4DE8B124EC5E2FB166D5AAFC8FB352ED6C722331&dn=Metallica+-+S%26amp%3BM+%282016%29+%5B24-96+HD+FLAC%5D&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.piratepublic.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftorrent.gresille.org%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.aletorrenty.pl%3A2710%2Fannounce&tr=udp%3A%2F%2Fshadowshq.eddie4.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.sktorrent.net%3A6969%2Fannounce&tr=udp%3A%2F%2Fbt.xxx-tracker.com%3A2710%2Fannounce&tr=udp://tracker.openbittorrent.com:80/announce&tr=udp://tracker.leechers-paradise.org:6969/announce&tr=udp://coppersurfer.tk:6969/announce"
    name = Magnetissimo.Crawler.magnet_torrent_name(magnet)
    assert name != nil
  end

end
