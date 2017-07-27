defmodule Fixtures do
  @fixtures_basepath "test/fixtures/"

  def load(fixture_name) do
    fixture_name
    |> filename
    |> File.read!
  end

  defp filename(name), do: Path.absname(@fixtures_basepath <> name)
end
