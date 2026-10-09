defmodule Magnetissimo.DataCase do
  @moduledoc """
  The case for tests that touch the database. Each test runs in its own SQL
  sandbox, shared with other processes when the test isn't async, so every
  change rolls back when the test ends.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Magnetissimo.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Magnetissimo.DataCase
    end
  end

  setup tags do
    Magnetissimo.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Sandbox.start_owner!(Magnetissimo.Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Torrents.create_torrent(%{magnet_hash: "nope"})
      assert "must be a 40-character lowercase hex BitTorrent v1 infohash" in
               errors_on(changeset).magnet_hash

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
