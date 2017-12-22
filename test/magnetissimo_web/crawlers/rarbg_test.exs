defmodule Magnetissimo.Crawlers.RarbgTest do
  use ExUnit.Case

  setup do
    Tesla.Mock.mock fn
      %{method: :get, url: "https://torrentapi.org/pubapi_v2.php?get_token=get_token"} ->
        %Tesla.Env{status: 200, body: "{\"token\":\"i92s07dhtv\"}"}
    end

    :ok
  end

  test "returns token" do
    {:ok, token} = Magnetissimo.Crawlers.Rarbg.get_token()
    assert String.length(token) == 10
  end
end