defmodule MagnetissimoWeb.Forms.SortingForm do
  import Ecto.Changeset

  alias Magnetissimo.EctoHelper

  @fields %{
    sort_by: EctoHelper.enum([:name, :size_in_bytes, :seeders, :leechers]),
    sort_dir: EctoHelper.enum([:asc, :desc])
  }

  @default_values %{
    sort_by: :seeders,
    sort_dir: :desc
  }

  def parse(params) do
    {@default_values, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  @spec default_values(map) :: %{:sort_by => any, :sort_dir => any, optional(any) => any}
  def default_values(overrides \\ %{}), do: Map.merge(@default_values, overrides)
end
