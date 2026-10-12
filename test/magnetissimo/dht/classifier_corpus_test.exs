defmodule Magnetissimo.DHT.ClassifierCorpusTest do
  @moduledoc """
  Real torrents the DHT found, each with the category a person checked it
  belongs under, and its ten largest files
  (`test/support/fixtures/dht_classifier_corpus.json`). A change to the
  classifier that files any of these elsewhere fails here; if the new
  category is right, correct the label.
  """
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Classifier
  alias Magnetissimo.Taxonomy

  @corpus_path Path.expand("../../support/fixtures/dht_classifier_corpus.json", __DIR__)
  @external_resource @corpus_path
  @corpus @corpus_path |> File.read!() |> JSON.decode!()

  test "files every torrent in the corpus where a person did" do
    misfiled =
      for %{"category" => expected, "name" => name, "files" => files} <- @corpus,
          files = for(%{"path" => path, "size" => size} <- files, do: %{path: path, size: size}),
          {:ok, id} = Classifier.classify(%{name: name, files: files}),
          Taxonomy.fetch!(id).name != expected,
          do: {name, expected, Taxonomy.fetch!(id).name}

    assert misfiled == []
  end
end
