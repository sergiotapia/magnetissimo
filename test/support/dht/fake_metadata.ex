defmodule Magnetissimo.DHT.FakeMetadata do
  @moduledoc """
  A `Magnetissimo.DHT.Metadata` stand-in that answers from metadata the test
  registered with `serve/1`, keyed by infohash, without a socket. Any other
  hash fails as a peer that never answered would.
  """

  @behaviour Magnetissimo.DHT.Metadata

  @key {__MODULE__, :metadata}

  @doc "Serves these info dictionaries, each under its own SHA-1."
  def serve(infos) do
    :persistent_term.put(@key, Map.new(infos, &{:crypto.hash(:sha, &1), &1}))
  end

  @impl true
  def fetch(info_hash, _address) do
    case :persistent_term.get(@key, %{}) do
      %{^info_hash => metadata} -> {:ok, metadata}
      _ -> {:error, :timeout}
    end
  end
end
