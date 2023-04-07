defmodule Magnetissimo.Torrents.Category do
  use TypedEctoSchema
  import Ecto.Changeset

  alias Magnetissimo.Torrents.Torrent

  @primary_key {:id, :string, autogenerate: {Ecto.Nanoid, :autogenerate, []}}
  @foreign_key_type :string
  typed_schema "categories" do
    field :name, :string
    field :slug, :string

    has_many :torrents, Torrent

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_slug()
  end

  def put_slug(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{name: name}} ->
        slug = Slug.slugify(name, separator: "-")

        changeset
        |> put_change(:slug, slug)

      _ ->
        changeset
    end
  end
end
