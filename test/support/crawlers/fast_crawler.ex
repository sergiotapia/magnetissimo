defmodule Magnetissimo.FastCrawler do
  @moduledoc """
  A crawler for `Magnetissimo.SourceSearch` tests that answers at once, filed
  under YTS.

  It finds one torrent named after the term. A term containing "crash" raises
  and one containing "fail" returns an error, so a test can make one source
  misbehave next to a healthy one. Every call is reported to the pid in
  `Application.get_env(:magnetissimo, :crawler_test_pid)`, if one is set.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  alias Magnetissimo.Torrents

  @impl true
  def source_name, do: "YTS"

  @impl true
  def latest, do: {:ok, []}

  @impl true
  def search(term) do
    report(term)

    cond do
      term =~ "crash" -> raise "fast crawler crashed"
      term =~ "fail" -> {:error, :unavailable}
      true -> {:ok, [attrs("#{term} fast", source_name())]}
    end
  end

  defp report(term) do
    case Application.get_env(:magnetissimo, :crawler_test_pid) do
      nil -> :ok
      pid -> send(pid, {:crawled, source_name(), term, self()})
    end
  end

  @doc "Valid attrs for one torrent, filed under `source`."
  def attrs(name, source) do
    hash = :crypto.hash(:sha, name) |> Base.encode16(case: :lower)

    %{
      name: name,
      canonical_url: "https://example.test/#{hash}",
      published_at: DateTime.utc_now(),
      seeders: 5,
      leechers: 1,
      size_in_bytes: 1_000,
      magnet_hash: hash,
      magnet_url: "magnet:?xt=urn:btih:#{hash}",
      category_id: Torrents.get_category_by_name_or_alias!("Other").id,
      source_id: Torrents.get_source_by_name!(source).id
    }
  end
end
