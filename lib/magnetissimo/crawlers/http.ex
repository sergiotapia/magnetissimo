defmodule Magnetissimo.Crawlers.Http do
  @moduledoc """
  The one GET every crawler makes, and what its answer means.

  A 200 is the body; any other status, or no answer at all, is the reason the
  site could not be asked, for `Magnetissimo.SourceSearch` to show. What the
  body has to look like is the crawler's business.

  Nothing is retried: a search is a one-shot question, so retrying only holds
  a process open while a site is down, and adds to the burst a rate-limited
  site shuts out.
  """

  @user_agent "Magnetissimo/0.1"

  @doc """
  GETs `url` with Req. `options` go to `Req.get/2` and win over the defaults,
  which are the user agent and no retries.
  """
  @spec get(String.t(), keyword()) :: {:ok, term()} | {:error, term()}
  def get(url, options) do
    options = Keyword.merge([headers: [user_agent: @user_agent], retry: false], options)

    case Req.get(url, options) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end
end
