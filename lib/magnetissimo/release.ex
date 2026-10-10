defmodule Magnetissimo.Release do
  @moduledoc """
  Database tasks for a release, which has no Mix.

  A release migrates and seeds the sources on every boot (see
  `Magnetissimo.Application`), so nothing here has to be run by hand.
  `bin/migrate` calls `migrate/0` for whoever wants the database ready before
  the server starts, and `rollback/2` is for `bin/magnetissimo eval`.
  """

  alias Magnetissimo.Seeds

  @app :magnetissimo

  @doc "Runs every pending migration and refreshes the sources rows."
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &migrator(&1, :up, all: true))
    end
  end

  @doc "Rolls `repo` back to `version`."
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Migrates `repo`, then refreshes the sources rows, so a release that adds a
  source can search it from its first boot. Takes `Ecto.Migrator.run/3`'s
  arguments, which makes it a `:migrator` for the `Ecto.Migrator` child.
  """
  def migrator(repo, direction, opts) do
    versions = Ecto.Migrator.run(repo, direction, opts)
    :ok = Seeds.run()
    versions
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    :ok = Application.ensure_loaded(@app)
  end
end
