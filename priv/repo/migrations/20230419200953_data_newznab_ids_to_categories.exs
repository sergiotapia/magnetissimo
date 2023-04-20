defmodule Magnetissimo.Repo.Migrations.DataNewznabIdsToCategories do
  use Ecto.Migration

  import Ecto.Query
  alias Magnetissimo.Torrents

  def change do
    # https://buildmedia.readthedocs.org/media/pdf/newznab/latest/newznab.pdf

    # We need to go through each existing category, and set
    # the newznab_category_id field.

    repo = repo()

    Torrents.list_category_tree_by_name("Anime", repo)
    |> Enum.each(fn category ->
      change = Torrents.change_category(category, %{newznab_category_id: "5070"})
      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Audio", repo)
    |> Enum.each(fn category ->
      change = Torrents.change_category(category, %{newznab_category_id: "3000"})
      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Books", repo)
    |> Enum.each(fn category ->
      change = Torrents.change_category(category, %{newznab_category_id: "7000"})
      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Video - Movies", repo)
    |> Enum.each(fn category ->
      change = Torrents.change_category(category, %{newznab_category_id: "2040,2045,2050,2060"})
      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Video - Television", repo)
    |> Enum.each(fn category ->
      change =
        Torrents.change_category(category, %{
          newznab_category_id: "5000,5020,5030,5040,5045,5050,5060"
        })

      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Video - Documentaries", repo)
    |> Enum.each(fn category ->
      change = Torrents.change_category(category, %{newznab_category_id: "5080"})
      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Video - XXX", repo)
    |> Enum.each(fn category ->
      change =
        Torrents.change_category(category, %{
          newznab_category_id: "6000,6010,6020,6030,6040,6050,6070"
        })

      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Images", repo)
    |> Enum.each(fn category ->
      change = Torrents.change_category(category, %{newznab_category_id: "8000"})
      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Software", repo)
    |> Enum.each(fn category ->
      change =
        Torrents.change_category(category, %{
          newznab_category_id: "4000,4010,4020,2030,4040,4050,4060,4070"
        })

      repo.update!(change)
    end)

    Torrents.list_category_tree_by_name("Other", repo)
    |> Enum.each(fn category ->
      change = Torrents.change_category(category, %{newznab_category_id: "8000"})
      repo.update!(change)
    end)
  end
end
