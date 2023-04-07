defmodule Magnetissimo.Torrents.Source do
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: {Ecto.Nanoid, :autogenerate, []}}
  @foreign_key_type :string
  typed_schema "sources" do
    field :name, :string
    field :url, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
  end
end
