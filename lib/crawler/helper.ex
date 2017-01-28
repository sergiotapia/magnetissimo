defmodule Magnetissimo.Crawler.Helper do
  require Logger

  @headers [{"Accept", "text/html,application/xhtml+xml"}]
  @options [follow_redirect: true, max_redirect: 10]

  @spec download(String.t) :: String.t | nil
  def download(url) do
    with {:ok, url} <- check_content(url),
         {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: _}} <- fetch(url) do
          body
    else
      :error ->
        {:error, :bad_url}
        Logger.warn "Bad URL!"
        nil

      {:ok, %HTTPoison.Response{status_code: 502, body: _, headers: _}} ->
        Logger.warn "502 Bad Gateway on #{url}"
        nil

      {:ok, %HTTPoison.Response{status_code: 404, body: _, headers: _}} ->
        Logger.warn "404 Page not Found on #{url}"
        nil

      {:error, error} ->
        Logger.error inspect(error)
        nil
    end
  end

  @spec check_content(String.t) :: {:ok, String.t} | {:error, term()}
  def check_content(url) do
    response = HTTPoison.head(url, @headers, @options)
               |> check_response

    result = with  {:ok, headers} <- response
                   {{"Content-Type", types}, _rest} <- List.keytake(headers, "Content-Type", 0),
                   :ok <-  verify_mime(types) do
                    {:ok, url}
            else
              {:moved, location} -> check_content(location)
              {:error, err}      -> {:error, err}
            end
    result
  end

  # @spec check_response({atom(), %HTTPoison.Response{}}) :: {:ok, String.t} | {:moved, [...]} | {:error, %HTTPoison.Response}
  defp check_response({:ok, %HTTPoison.Response{status_code: code, body: _data, headers: headers}}) do
    case code do
      c when c in [301,302] ->
        {{"Location", location}, _rest} = List.keytake(headers, "Location", 0)
        {:moved, location}
      _                     ->
        {:ok, headers}
    end
  end

  defp check_response({:error, err}), do: {:error, err}

  @spec fetch(String.t) :: {:ok, %HTTPoison.Response{}} | {:error, %HTTPoison.Response{}}
  defp fetch(url) do
    HTTPoison.get(url, @headers, [recv_timeout: :infinity] ++ @options)
  end

  defp verify_mime(types) do
    case Regex.run(~r/^text\/html.*/iu, types, capture: :all_but_first) do
      nil -> {:error, :wrong_headers}
      _   -> :ok
    end
  end


  def size_to_bytes(size, unit) when is_binary(size) do
    {size_int, _} = Integer.parse(size)
    size_to_bytes(size_int, unit)
  end

  def size_to_bytes(size_int, "KB") do
    size_int * 1024
  end

  def size_to_bytes(size_int, "MB") do
    size_to_bytes(size_int, "KB") * 1024
  end

  def size_to_bytes(size_int, "GB") do
    size_to_bytes(size_int, "MB") * 1024
  end

  def size_to_bytes(size_int, "TB") do
    size_to_bytes(size_int, "GB") * 1024
  end
end
