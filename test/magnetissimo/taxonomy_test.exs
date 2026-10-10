defmodule Magnetissimo.TaxonomyTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.Taxonomy

  test "every child shares its parent's thousand, and every parent exists" do
    for category <- Taxonomy.all() do
      case category.parent_id do
        nil ->
          assert rem(category.id, 1000) == 0
          assert category.label == category.name

        parent_id ->
          assert div(category.id, 1000) * 1000 == parent_id
          parent = Taxonomy.fetch!(parent_id)
          assert category.name == "#{parent.name}/#{category.label}"
      end
    end
  end

  test "names resolve to the standard Torznab numbers" do
    assert Taxonomy.id!("Movies") == 2000
    assert Taxonomy.id!("Movies/UHD") == 2045
    assert Taxonomy.id!("TV/Anime") == 5070
    assert Taxonomy.id!("XXX/ImageSet") == 6060
    assert Taxonomy.id!("Other") == Taxonomy.other_id()
    assert Taxonomy.id!("XXX") == Taxonomy.xxx_id()

    assert_raise ArgumentError, ~r/"Anime" is not a Torznab category/, fn ->
      Taxonomy.id!("Anime")
    end
  end

  test "a top-level category's family is itself and its children" do
    assert Taxonomy.family_ids(5070) == [5070]

    family = Taxonomy.family_ids(2000)
    assert hd(family) == 2000
    assert 2045 in family
    refute 5040 in family
  end

  test "a Torznab cat list matches families, and a subcategory's parent" do
    ids = Taxonomy.torznab_ids([5030, 5040, 5040, 2000, 99, 100_010])

    assert 5000 in ids and 5030 in ids and 5040 in ids
    refute 5070 in ids
    assert 2045 in ids
    assert ids == Enum.uniq(ids)
    assert Taxonomy.torznab_ids([99]) == []
  end

  test "the tree keeps a top level with a kept child, and drops the rest" do
    tree = Taxonomy.tree(&(&1.id in [2045, 8000]))

    assert [{movies, [uhd]}, {other, []}] = tree
    assert {movies.name, uhd.name, other.name} == {"Movies", "Movies/UHD", "Other"}
  end
end
