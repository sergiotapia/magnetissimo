defmodule Magnetissimo.Logger do
  @default_level "info"

  def init(_opts), do: {}

  def call(%{path_info: ["healthcheck"]} = conn, _opts) do
    Plug.Logger.call(conn, :debug)
  end
  def call(conn, _opts) do
	Plug.Logger.call(conn, String.to_existing_atom(@default_level))
  end
end
