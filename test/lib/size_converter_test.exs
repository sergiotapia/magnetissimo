defmodule Magnetissimo.SizeConverterTest do
  use ExUnit.Case, async: true

  test "converts units properly" do
    kb = Magnetissimo.SizeConverter.size_to_bytes("1", "KB")
    mb = Magnetissimo.SizeConverter.size_to_bytes("1", "MB")
    gb = Magnetissimo.SizeConverter.size_to_bytes("1", "GB")
    tb = Magnetissimo.SizeConverter.size_to_bytes("1", "TB")
    assert kb == 1024
    assert mb == 1048576
    assert gb == 1073741824
    assert tb == 1099511627776
  end
end
