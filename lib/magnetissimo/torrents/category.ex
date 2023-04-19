defmodule Magnetissimo.Torrents.Category do
  use TypedEctoSchema
  import Ecto.Changeset

  alias Magnetissimo.Torrents.Category
  alias Magnetissimo.Torrents.Torrent

  @primary_key {:id, :string, autogenerate: {Ecto.Nanoid, :autogenerate, []}}
  @foreign_key_type :string
  typed_schema "categories" do
    field(:name, :string)
    field(:alternative_names, {:array, :string})
    field(:slug, :string)
    field(:newznab_category_id, :string)

    belongs_to(:parent_category, Category, references: :id, foreign_key: :parent_id)
    has_many(:torrents, Torrent)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :alternative_names, :newznab_category_id, :parent_id])
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
