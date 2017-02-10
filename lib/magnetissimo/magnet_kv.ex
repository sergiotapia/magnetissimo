defmodule Magnetissimo.MagnetKV do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def cached?(magnet) do
    timestamp = Agent.get(__MODULE__, &Map.get(&1, magnet))
		case timestamp do
			nil -> false
      timestamp -> {:ok, timestamp}
		end
  end

  def cache(magnet) do
		timestamp = :os.system_time(:seconds)
    Agent.update(__MODULE__, &Map.put(&1, magnet, timestamp))
		{:ok, timestamp}
  end
end
