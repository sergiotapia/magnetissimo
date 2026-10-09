defmodule MagnetissimoWeb.ConnCase do
  @moduledoc """
  The case for tests that go through the router: each test gets a `conn`, and
  its own SQL sandbox (shared when the test isn't async), so database changes
  roll back when it ends.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint MagnetissimoWeb.Endpoint

      use MagnetissimoWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MagnetissimoWeb.ConnCase
    end
  end

  setup tags do
    Magnetissimo.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
