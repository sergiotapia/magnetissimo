defmodule Magnetissimo.Test.HelpersTest do
  use Magnetissimo.DataCase

  alias Magnetissimo.Helpers

  describe "convert_filesize/2" do
    test "can convert gigabytes to bytes" do
      assert Helpers.convert_filesize!("500 MB", "GB") == "0.50 GB"
      assert Helpers.convert_filesize!("39.2 GB", "b") == "39200000000.00 B"
    end
  end
end
