defmodule Magnetissimo.Crawlers.Categories do
  @moduledoc """
  A source's own categories, mapped onto `Magnetissimo.Taxonomy`.

  Each crawler declares its mapping the way a Prowlarr indexer definition
  does: the site's own key for a category on the left, a Torznab category
  name on the right. The key is the most stable thing the site publishes:
  Nyaa's category id (`"1_2"`) rather than its display name, which differs
  between its own menu and its feed.

      @categories Categories.mapping!("Nyaa.si", %{"1_2" => "TV/Anime"}, fallback: "Other")

  `mapping!/3` runs at compile time, so a name that is not in the taxonomy
  fails the build rather than misfiling torrents at runtime.

  `:fallback` is where a torrent goes when its site category is missing or
  unknown. An adult-only source falls back to `"XXX"`, never to a category
  that would put its torrents next to work-safe ones.
  """

  require Logger

  alias Magnetissimo.Taxonomy

  @enforce_keys [:source, :ids, :fallback]
  defstruct [:source, :ids, :fallback]

  @type t :: %__MODULE__{
          source: String.t(),
          ids: %{String.t() => pos_integer()},
          fallback: pos_integer()
        }

  @doc """
  Builds a mapping from `%{site_key => torznab_name}`. Raises `ArgumentError`
  for a name that is not a Torznab category.
  """
  @spec mapping!(String.t(), %{String.t() => String.t()}, keyword()) :: t()
  def mapping!(source, names, opts) do
    %__MODULE__{
      source: source,
      ids: Map.new(names, fn {key, name} -> {key, Taxonomy.id!(name)} end),
      fallback: Taxonomy.id!(Keyword.fetch!(opts, :fallback))
    }
  end

  @doc """
  The category number for a site key.

  A missing key (`nil` or `""`) is a site that did not say, and quietly takes
  the fallback. A key the mapping does not know is a site that added or
  renamed a category; it also takes the fallback, and is logged so the
  mapping can be brought up to date.
  """
  @spec resolve(t(), String.t() | nil) :: pos_integer()
  def resolve(%__MODULE__{fallback: fallback}, key) when key in [nil, ""], do: fallback

  def resolve(%__MODULE__{} = mapping, key) do
    case Map.fetch(mapping.ids, key) do
      {:ok, id} ->
        id

      :error ->
        Logger.warning("[#{mapping.source}] unmapped category #{inspect(key)}")
        mapping.fallback
    end
  end
end
