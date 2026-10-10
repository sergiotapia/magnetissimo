defmodule Magnetissimo.Crawlers.Nyaa.Site do
  @moduledoc """
  Defines one Nyaa site as a crawler module.

  Nyaa and Sukebei run the same software, so each is a `use` of this with
  what differs: `:source` (the `sources.name` row), `:rss_url`, `:tracker`,
  and `:categories`, the site's category ids mapped onto Torznab names, with
  the `:fallback` for an id the mapping lacks. The two sites reuse the same
  ids for different things, so each keeps its own mapping. All the work lives
  in `Magnetissimo.Crawlers.Nyaa.Feed`.
  """

  defmacro __using__(site) do
    quote location: :keep, bind_quoted: [site: site] do
      @behaviour Magnetissimo.Crawlers.Crawler

      alias Magnetissimo.Crawlers.Categories
      alias Magnetissimo.Crawlers.Nyaa.Feed

      @site Keyword.put(
              site,
              :categories,
              Categories.mapping!(site[:source], site[:categories], fallback: site[:fallback])
            )

      @impl true
      def source_name, do: @site[:source]

      @impl true
      def categories, do: @site[:categories]

      @doc "Fetches the newest items."
      @impl true
      def latest, do: Feed.latest(@site)

      @doc "Looks one term up on the site."
      @impl true
      def search(term), do: Feed.search(@site, term)
    end
  end
end
