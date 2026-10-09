defmodule Magnetissimo.Crawlers.Nyaa.Site do
  @moduledoc """
  Defines one Nyaa site as a crawler module.

  Nyaa and Sukebei differ only by their source row, feed URL and tracker, so
  each is a `use` of this with those three values. All the work lives in
  `Magnetissimo.Crawlers.Nyaa.Feed`.
  """

  defmacro __using__(site) do
    quote location: :keep, bind_quoted: [site: site] do
      alias Magnetissimo.Crawlers.Nyaa.Feed

      @site site

      @doc "Fetches the newest items and indexes them."
      @spec crawl_latest() :: :ok
      def crawl_latest, do: Feed.crawl_latest(@site)

      @doc "Looks one term up on the site and indexes whatever comes back."
      @spec search(String.t(), keyword()) :: :ok
      def search(term, opts \\ []), do: Feed.search(@site, term, opts)
    end
  end
end
