defmodule Magnetissimo.Taxonomy.Category do
  @moduledoc """
  One category of `Magnetissimo.Taxonomy`.

  `id` is the Newznab/Torznab number and `name` the standard name, such as
  `2045` and `"Movies/UHD"`. `parent_id` is `nil` for a top-level category
  (`2000`, `"Movies"`). `label` is the name without its parent (`"UHD"`), for
  places where the parent is already on screen.
  """

  @enforce_keys [:id, :name, :label, :parent_id]
  defstruct [:id, :name, :label, :parent_id]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          label: String.t(),
          parent_id: pos_integer() | nil
        }
end
