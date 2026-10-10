defmodule Magnetissimo.Taxonomy do
  @moduledoc """
  The categories every torrent is filed under.

  This is the Newznab/Torznab standard category list, unchanged: the numbers
  and names Sonarr, Radarr, Prowlarr and Jackett all speak. Every site names
  its own categories differently; each crawler maps the site's categories onto
  these, so a torrent from any source lands in the same place a torrent client
  expects it.

  Two levels. A top-level category's number is a multiple of 1000 (`5000`,
  `"TV"`), and its children share the thousand (`5070`, `"TV/Anime"`). A
  torrent can be filed under either: a site that only says "TV" is filed
  under TV, and filtering by TV includes TV/Anime.

  The list lives in code because it is knowledge, not data. It never changes
  at runtime, so nothing has to be seeded or kept in sync, and a mapping that
  names a category that does not exist fails to compile (see
  `Magnetissimo.Crawlers.Categories`).

  To add a source, take its category mapping from the Prowlarr indexer
  definition for that site (`categorymappings` in
  https://github.com/Prowlarr/Indexers), which is already written in these
  names, and refine it where the site gives more detail.
  """

  alias Magnetissimo.Taxonomy.Category

  # https://github.com/Prowlarr/Prowlarr/blob/develop/src/NzbDrone.Core/Indexers/NewznabStandardCategory.cs
  # Newznab's legacy 0000 "Other" range is left out: 8000 is the Other in use.
  @standard [
    {1000, "Console"},
    {1010, "Console/NDS"},
    {1020, "Console/PSP"},
    {1030, "Console/Wii"},
    {1040, "Console/XBox"},
    {1050, "Console/XBox 360"},
    {1060, "Console/Wiiware"},
    {1070, "Console/XBox 360 DLC"},
    {1080, "Console/PS3"},
    {1090, "Console/Other"},
    {1110, "Console/3DS"},
    {1120, "Console/PS Vita"},
    {1130, "Console/WiiU"},
    {1140, "Console/XBox One"},
    {1180, "Console/PS4"},
    {2000, "Movies"},
    {2010, "Movies/Foreign"},
    {2020, "Movies/Other"},
    {2030, "Movies/SD"},
    {2040, "Movies/HD"},
    {2045, "Movies/UHD"},
    {2050, "Movies/BluRay"},
    {2060, "Movies/3D"},
    {2070, "Movies/DVD"},
    {2080, "Movies/WEB-DL"},
    {2090, "Movies/x265"},
    {3000, "Audio"},
    {3010, "Audio/MP3"},
    {3020, "Audio/Video"},
    {3030, "Audio/Audiobook"},
    {3040, "Audio/Lossless"},
    {3050, "Audio/Other"},
    {3060, "Audio/Foreign"},
    {4000, "PC"},
    {4010, "PC/0day"},
    {4020, "PC/ISO"},
    {4030, "PC/Mac"},
    {4040, "PC/Mobile-Other"},
    {4050, "PC/Games"},
    {4060, "PC/Mobile-iOS"},
    {4070, "PC/Mobile-Android"},
    {5000, "TV"},
    {5010, "TV/WEB-DL"},
    {5020, "TV/Foreign"},
    {5030, "TV/SD"},
    {5040, "TV/HD"},
    {5045, "TV/UHD"},
    {5050, "TV/Other"},
    {5060, "TV/Sport"},
    {5070, "TV/Anime"},
    {5080, "TV/Documentary"},
    {5090, "TV/x265"},
    {6000, "XXX"},
    {6010, "XXX/DVD"},
    {6020, "XXX/WMV"},
    {6030, "XXX/XviD"},
    {6040, "XXX/x264"},
    {6045, "XXX/UHD"},
    {6050, "XXX/Pack"},
    {6060, "XXX/ImageSet"},
    {6070, "XXX/Other"},
    {6080, "XXX/SD"},
    {6090, "XXX/WEB-DL"},
    {7000, "Books"},
    {7010, "Books/Mags"},
    {7020, "Books/EBook"},
    {7030, "Books/Comics"},
    {7040, "Books/Technical"},
    {7050, "Books/Other"},
    {7060, "Books/Foreign"},
    {8000, "Other"},
    {8010, "Other/Misc"},
    {8020, "Other/Hashed"}
  ]

  @categories Enum.map(@standard, fn {id, name} ->
                parent_id = if rem(id, 1000) == 0, do: nil, else: div(id, 1000) * 1000
                label = name |> String.split("/", parts: 2) |> List.last()
                %Category{id: id, name: name, label: label, parent_id: parent_id}
              end)

  @by_id Map.new(@categories, &{&1.id, &1})
  @by_name Map.new(@categories, &{&1.name, &1})
  @other_id 8000
  @xxx_id 6000

  @doc "Every category, in standard order."
  @spec all() :: [Category.t()]
  def all, do: @categories

  @doc "Every category number."
  @spec ids() :: [pos_integer()]
  def ids, do: Map.keys(@by_id)

  @doc "The category a torrent goes under when its source does not say."
  @spec other_id() :: pos_integer()
  def other_id, do: @other_id

  @doc "The top-level adult category."
  @spec xxx_id() :: pos_integer()
  def xxx_id, do: @xxx_id

  @doc "The category with this number, or `nil`."
  @spec get(integer()) :: Category.t() | nil
  def get(id), do: Map.get(@by_id, id)

  @doc "The category with this number. Raises for one that does not exist."
  @spec fetch!(integer()) :: Category.t()
  def fetch!(id), do: Map.fetch!(@by_id, id)

  @doc """
  The number of the category with this standard name, such as
  `"Movies/UHD"`. Raises `ArgumentError` for a name that is not in the list.
  """
  @spec id!(String.t()) :: pos_integer()
  def id!(name) do
    case Map.fetch(@by_name, name) do
      {:ok, category} -> category.id
      :error -> raise ArgumentError, "#{inspect(name)} is not a Torznab category"
    end
  end

  @doc """
  The numbers a filter on `id` matches: the category itself and, for a
  top-level one, every child.
  """
  @spec family_ids(pos_integer()) :: [pos_integer()]
  def family_ids(id) do
    [id | for(%Category{parent_id: ^id, id: child} <- @categories, do: child)]
  end

  @doc "The top-level category a category belongs to: itself, or its parent."
  @spec root(Category.t()) :: Category.t()
  def root(%Category{parent_id: nil} = category), do: category
  def root(%Category{parent_id: parent_id}), do: fetch!(parent_id)

  @doc """
  The tree, as `[{top_level, children}]`, keeping only the categories `keep?`
  returns true for and every top level with a kept child.
  """
  @spec tree((Category.t() -> boolean())) :: [{Category.t(), [Category.t()]}]
  def tree(keep? \\ fn _category -> true end) do
    for %Category{parent_id: nil} = root <- @categories,
        children =
          for(%Category{parent_id: id} = c <- @categories, id == root.id, keep?.(c), do: c),
        keep?.(root) or children != [] do
      {root, children}
    end
  end
end
