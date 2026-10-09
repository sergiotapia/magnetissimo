defmodule Magnetissimo.Seeds do
  @moduledoc """
  The crawl sources and the canonical category tree, including the strings each
  site uses for a category.

  This mapping is knowledge rather than fixture data: a crawler cannot file a
  torrent without it, because every site names its categories differently. It
  lives in `lib/` so a release task can reach it too. Imported from the 2.0.0
  app, where it was duplicated between `priv/repo/seeds.exs` and a `DbSeeder`
  module.
  """

  alias Magnetissimo.Repo
  alias Magnetissimo.Torrents.Category
  alias Magnetissimo.Torrents.CategoryAlias
  alias Magnetissimo.Torrents.Source

  @sources [
    {"Nyaa.si", "https://nyaa.si"},
    {"TorrentDownloads", "https://torrentdownloads.pro"},
    {"YTS", "https://yts.mx/"},
    {"1337x", "https://www.1337x.to"}
  ]

  # {parent name, [{child name, [site's wording for it]}]}
  @categories [
    {"Anime",
     [
       {"Anime - Music Video", ["Anime - Anime Music Video"]},
       {"Anime - English-translated", ["Anime"]},
       {"Anime - Non-English translated", ["Anime - Non-English-translated"]},
       {"Anime - Raw", []}
     ]},
    {"Audio",
     [
       {"Audio - Lossless", []},
       {"Audio - Lossy", ["Music"]}
     ]},
    {"Books",
     [
       {"Books - English-translated",
        ["Literature - English-translated", "Books", "Ebooks", "e-books", "ebook"]},
       {"Books - Non-English translated", ["Literature - Non-English-translated"]},
       {"Books - Raw", ["Literature - Raw"]}
     ]},
    {"Video",
     [
       {"Video - Movies",
        [
          "Live Action - Raw",
          "Live Action - English-translated",
          "Live Action - Idol/Promotional Video",
          "Live Action - Non-English-translated",
          "Movies"
        ]},
       {"Video - Television", ["TV Shows", "TV", "television", "Television", "TV - Other"]},
       {"Video - Documentaries", ["Documentaries", "Documentary"]},
       {"Video - XXX", ["XXX"]}
     ]},
    {"Images",
     [
       {"Images - Graphics", ["Pictures - Graphics"]},
       {"Images - Photos", ["Pictures - Photos"]}
     ]},
    {"Software",
     [
       {"Software - Applications",
        ["Software", "Mac", "Linux", "Windows", "Apps", "Apple", "Other operating systems"]},
       {"Software - Games", ["Games"]}
     ]},
    {Category.fallback(), []}
  ]

  @doc """
  Inserts the sources and the category tree. Safe to run repeatedly.
  """
  def run do
    Enum.each(@sources, fn {name, url} -> upsert_source(name, url) end)
    Enum.each(@categories, &upsert_category_tree/1)
    :ok
  end

  defp upsert_category_tree({parent_name, children}) do
    parent = upsert_category(parent_name, nil)
    Enum.each(children, &upsert_child_category(&1, parent))
  end

  defp upsert_child_category({child_name, aliases}, parent) do
    category = upsert_category(child_name, parent.id)
    Enum.each(aliases, &upsert_alias(&1, category))
  end

  defp upsert_source(name, url) do
    Repo.get_by(Source, name: name) ||
      Repo.insert!(Source.changeset(%Source{}, %{name: name, url: url}))
  end

  defp upsert_category(name, parent_id) do
    Repo.get_by(Category, name: name) ||
      Repo.insert!(Category.changeset(%Category{}, %{name: name, parent_id: parent_id}))
  end

  defp upsert_alias(name, category) do
    Repo.get_by(CategoryAlias, name: name) ||
      Repo.insert!(
        CategoryAlias.changeset(%CategoryAlias{}, %{name: name, category_id: category.id})
      )
  end
end
