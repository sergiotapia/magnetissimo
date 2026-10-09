defmodule MagnetissimoWeb.DossierComponentsTest do
  use ExUnit.Case, async: true

  import MagnetissimoWeb.DossierComponents

  test "short_category/1 drops the parent" do
    assert short_category("Video - Movies") == "Movies"
    assert short_category("Books - Non-English translated") == "Non-English translated"
    assert short_category("Other") == "Other"
  end

  test "fingerprint_cells/1 is a 12x12 mirrored bitmap derived from the hash" do
    cells = fingerprint_cells("0fb89b2883ba7e654bd0e45d3b90e072e3f7e80e")

    assert cells != []
    assert Enum.all?(cells, fn {x, y} -> x in 0..11 and y in 0..11 end)

    # Every lit cell has its mirror lit.
    for {x, y} <- cells, do: assert({11 - x, y} in cells)

    # And a different hash gives a different glyph.
    assert cells != fingerprint_cells("ffffffffffffffffffffffffffffffffffffffff")
  end
end
