defmodule MagnetissimoWeb.FormatTest do
  use ExUnit.Case, async: true

  import MagnetissimoWeb.Format

  doctest MagnetissimoWeb.Format

  describe "bytes/1" do
    test "is binary, the way the sources show sizes" do
      assert bytes(nil) == "—"
      assert bytes(1023) == "1023 B"
      assert bytes(1024) == "1 KiB"
      assert bytes(1024 ** 2) == "1.0 MiB"
      assert bytes(1024 ** 3 - 1) == "1024 MiB"
      assert bytes(1024 ** 3) == "1.0 GiB"
      assert bytes(round(8.42 * 1024 ** 3)) == "8.4 GiB"
      assert bytes(1024 ** 6) == "1024 PiB"
    end
  end
end
