defmodule MagnetissimoWeb.SearchFiltersTest do
  use ExUnit.Case, async: true

  alias MagnetissimoWeb.SearchFilters

  @gib 1024 * 1024 * 1024
  @mib 1024 * 1024
  @now ~U[2026-10-10 12:00:00.000000Z]

  defp opts(params), do: params |> SearchFilters.from_params() |> SearchFilters.opts(@now)

  describe "sizes" do
    test "read binary units, as every size on the page is" do
      for {text, bytes} <- [
            {"2 GB", 2 * @gib},
            {"2gb", 2 * @gib},
            {"2 GiB", 2 * @gib},
            {"2G", 2 * @gib},
            {"700 MB", 700 * @mib},
            {"700mib", 700 * @mib},
            {"1.5 GB", round(1.5 * @gib)},
            {"1,5 GB", round(1.5 * @gib)},
            {"512 KB", 512 * 1024},
            {"1 TB", 1024 * @gib},
            {"900 B", 900},
            {"  4  gb  ", 4 * @gib}
          ] do
        assert opts(%{"min_size" => text}) == [min_size: bytes], "for #{inspect(text)}"
      end
    end

    test "without a unit are gigabytes" do
      assert opts(%{"max_size" => "4"}) == [max_size: 4 * @gib]
    end

    test "that cannot be read are ignored, and say so" do
      for text <- ["big", "-2 GB", "2 GBs", "2 PB", "1e9", "2..5 GB", "GB", "0x10", "½ GB"] do
        filters = SearchFilters.from_params(%{"min_size" => text})
        assert SearchFilters.opts(filters, @now) == [], "for #{inspect(text)}"
        assert SearchFilters.invalid?(filters, "min_size"), "for #{inspect(text)}"
        refute SearchFilters.active?(filters)
      end
    end

    test "too big for the database are ignored" do
      assert opts(%{"min_size" => "99999999999999 TB"}) == []
    end
  end

  describe "seeders" do
    test "are whole numbers, with separators allowed" do
      assert opts(%{"min_seeders" => "10"}) == [min_seeders: 10]
      assert opts(%{"max_seeders" => "1,000"}) == [max_seeders: 1000]
      assert opts(%{"max_seeders" => "0"}) == [max_seeders: 0]
    end

    test "that are not whole numbers are ignored" do
      for text <- ["ten", "-1", "1.5", "10 seeders", "99999999999999999999999"] do
        assert opts(%{"min_seeders" => text}) == [], "for #{inspect(text)}"
      end
    end
  end

  describe "ages" do
    test "count back from now, in days unless a unit says otherwise" do
      for {text, seconds} <- [
            {"7", 7 * 86_400},
            {"7d", 7 * 86_400},
            {"7 days", 7 * 86_400},
            {"1 day", 86_400},
            {"12h", 12 * 3600},
            {"2w", 14 * 86_400},
            {"3mo", 90 * 86_400},
            {"3 months", 90 * 86_400},
            {"1y", 365 * 86_400},
            {"1.5d", 36 * 3600}
          ] do
        assert opts(%{"max_age" => text}) == [published_after: DateTime.add(@now, -seconds)],
               "for #{inspect(text)}"
      end
    end

    test "older than is published before" do
      assert opts(%{"min_age" => "1y"}) == [published_before: DateTime.add(@now, -365, :day)]
    end

    test "that cannot be read, or reach back before any torrent, are ignored" do
      for text <- ["soon", "-7d", "7m", "7 fortnights", "100000y"] do
        assert opts(%{"max_age" => text}) == [], "for #{inspect(text)}"
      end
    end
  end

  describe "scope" do
    test "is names only for in=title, and names and descriptions otherwise" do
      assert opts(%{"in" => "title"}) == [scope: :name]
      assert opts(%{"in" => "all"}) == []
      assert opts(%{"in" => "files"}) == []
      assert opts(%{}) == []
    end
  end

  test "blank fields are no filter at all" do
    filters = SearchFilters.from_params(%{"min_size" => "", "max_age" => "  ", "in" => ""})

    assert SearchFilters.opts(filters, @now) == []
    refute SearchFilters.active?(filters)
    refute SearchFilters.invalid?(filters, "min_size")
    assert SearchFilters.to_params(filters) == []
  end

  test "params a form does not have are ignored" do
    assert opts(%{"q" => "dune", "category" => "2000", "min_size" => %{"x" => 1}}) == []
  end

  test "round-trip through the URL as typed, in a fixed order" do
    params = %{
      "max_age" => "7d",
      "in" => "title",
      "min_size" => "2 GB",
      "max_seeders" => "nope",
      "q" => "dune"
    }

    filters = SearchFilters.from_params(params)

    # Kept as typed so the form shows it back, but only what reads is applied.
    assert SearchFilters.to_params(filters) ==
             [in: "title", min_size: "2 GB", max_seeders: "nope", max_age: "7d"]

    assert SearchFilters.from_params(
             Map.new(SearchFilters.to_params(filters), fn {k, v} ->
               {Atom.to_string(k), v}
             end)
           ) == filters

    assert SearchFilters.active?(filters)
    assert SearchFilters.value(filters, "min_size") == "2 GB"
    assert SearchFilters.value(filters, "min_seeders") == ""
  end

  test "summarise what is applied, in words" do
    filters =
      SearchFilters.from_params(%{
        "in" => "title",
        "min_size" => "2gb",
        "max_size" => "700 MB",
        "min_seeders" => "10",
        "max_age" => "7d",
        "min_age" => "x"
      })

    assert SearchFilters.summary(filters) ==
             [
               "titles only",
               "at least 2.0 GiB",
               "at most 700 MiB",
               "10+ seeders",
               "newer than 7d"
             ]
  end
end
