defmodule Magnetissimo.Downloader do
  @moduledoc """
  Helper functions for download content from the web.
  """

  use Tesla

  @doc """
  Downloads content from a given URL address.

  Return `{:ok, body} | {:error, status_code}`

  ## Examples

      iex> Magnetissimo.Downloader.download("http://example.com")
      {:ok, "<body>...</body>"}

      iex> Magnetissimo.Downloader.download("http://bad-url.com")
      {:error, 404}

  """
  @spec download(binary) :: {:ok, binary} | {:error, term}
  def download(url) do
    case get(url) do
      %Tesla.Env{status: 200, body: body} ->
        {:ok, body}
      %Tesla.Env{status: status} ->
        {:error, status}
    end
  end
end
