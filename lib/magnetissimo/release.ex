defmodule Magnetissimo.Release do
  @moduledoc """
  Database tasks for a release, which has no Mix.

  A release calls `migrate/0` on every boot, before the Repo's pool starts
  (see `Magnetissimo.Application`), so nothing here has to be run by hand.
  `bin/migrate` calls it too, for whoever wants the database ready before the
  server starts, and `rollback/2` is for `bin/magnetissimo eval`.
  """

  alias Magnetissimo.Seeds

  @app :magnetissimo

  @doc """
  Runs every pending migration and then refreshes the sources rows, so a
  release that adds a source can search it from its first boot.

  It holds one connection. Several connections opened on a fresh file can
  run a migration against a stale schema: an `ALTER TABLE ... DROP COLUMN`
  then fails on a column the migration before it added.
  """
  @spec migrate() :: :ok
  def migrate do
    load_app()

    Enum.each(repos(), fn repo ->
      {:ok, _, _} =
        Ecto.Migrator.with_repo(
          repo,
          fn repo ->
            versions = Ecto.Migrator.run(repo, :up, all: true)
            :ok = Seeds.run()
            versions
          end,
          pool_size: 1
        )
    end)
  end

  @doc "Rolls `repo` back to `version`."
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    :ok = Application.ensure_loaded(@app)
  end
end
