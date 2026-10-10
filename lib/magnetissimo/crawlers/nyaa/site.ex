defmodule Magnetissimo.Crawlers.Nyaa.Site do
  @moduledoc """
  Defines one Nyaa site as a crawler module.

  Nyaa and Sukebei differ only by their source row, feed URL and tracker, so
  each is a `use` of this with those three values. All the work lives in
  `Magnetissimo.Crawlers.Nyaa.Feed`.
  """

  defmacro __using__(site) do
    quote location: :keep, bind_quoted: [site: site] do
      @behaviour Magnetissimo.Crawlers.Crawler

      alias Magnetissimo.Crawlers.Nyaa.Feed

      @site site

      @impl true
      def source_name, do: @site[:source]

      @doc "Fetches the newest items."
      @impl true
      def latest, do: Feed.latest(@site)

      @doc "Looks one term up on the site."
      @impl true
      def search(term), do: Feed.search(@site, term)
    end
  end
end
