defmodule Magnetissimo.Helpers do
  def format_infohash(infohash) do
    "magnet:?xt=urn:btih:#{infohash}&dn=f&tr=udp://tracker.cyberia.is:6969/announce&tr=udp://tracker.port443.xyz:6969/announce&tr=http://tracker3.itzmx.com:6961/announce&tr=udp://tracker.moeking.me:6969/announce&tr=http://vps02.net.orel.ru:80/announce&tr=http://tracker.openzim.org:80/announce&tr=udp://tracker.skynetcloud.tk:6969/announce&tr=https://1.tracker.eu.org:443/announce&tr=https://3.tracker.eu.org:443/announce&tr=http://re-tracker.uz:80/announce&tr=https://tracker.parrotsec.org:443/announce&tr=udp://explodie.org:6969/announce&tr=udp://tracker.filemail.com:6969/announce&tr=udp://tracker.nyaa.uk:6969/announce&tr=udp://retracker.netbynet.ru:2710/announce&tr=http://tracker.gbitt.info:80/announce&tr=http://tracker2.dler.org:80/announce"
  end

  @units ["b", "kb", "mb", "gb", "tb", "pb", "eb", "zb", "yb"]
  def convert_filesize!(filesize, to_unit) do
    to_unit = String.replace(to_unit, "i", "") |> String.downcase()

    original_size = String.split(filesize, " ") |> List.first() |> String.downcase()

    original_unit =
      String.split(filesize, " ")
      |> List.last()
      |> String.downcase()
      |> String.replace("i", "")

    to_unit = String.downcase(to_unit)

    from_index = Enum.find_index(@units, fn x -> x == original_unit end)
    to_index = Enum.find_index(@units, fn x -> x == to_unit end)

    digits = (from_index - to_index) / 1

    cond do
      digits == 0.0 ->
        "#{original_size} #{String.upcase(original_unit)}"

      digits < 0.0 ->
        digits = digits * -1
        {original_size, _} = Float.parse(original_size)

        new_size =
          (original_size / :math.pow(1000.0, digits)) |> :erlang.float_to_binary(decimals: 2)

        "#{new_size} #{String.upcase(to_unit)}"

      digits > 0.0 ->
        {original_size, _} = Float.parse(original_size)

        new_size =
          (original_size * :math.pow(1000.0, digits)) |> :erlang.float_to_binary(decimals: 2)

        "#{new_size} #{String.upcase(to_unit)}"

      true ->
        ""
    end
  end
end
