defmodule Magnetissimo.DownloaderTest do
  use ExUnit.Case
  alias Magnetissimo.Downloader

  setup do
    Tesla.Mock.mock fn
      %{method: :get, url: "https://test.com/123/movie-hdtv"} ->
        %Tesla.Env{status: 200, body: "hello"}
      %{method: :get, url: "http://test.com/-1/broken-url"} ->
        %Tesla.Env{status: 404, body: "This doesn't exist!"}
    end

    :ok
  end

  test "downloads HTML content" do
    {:ok, content} = Downloader.download("https://test.com/123/movie-hdtv")
    assert content == "hello"
  end

  test "returns error for non 200 code" do
    {:error, reason} = Downloader.download("http://test.com/-1/broken-url")
    assert reason == 404
  end
end