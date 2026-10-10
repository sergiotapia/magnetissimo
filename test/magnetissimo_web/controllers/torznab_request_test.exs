defmodule MagnetissimoWeb.TorznabRequestTest do
  use ExUnit.Case, async: true

  alias MagnetissimoWeb.TorznabRequest

  defp term(params) do
    {:ok, %TorznabRequest{term: term}} = TorznabRequest.parse(params)
    term
  end

  test "Sonarr's season and episode become the name a release carries" do
    tv = %{"t" => "tvsearch", "q" => "Breaking Bad"}

    assert term(Map.merge(tv, %{"season" => "01", "ep" => "02"})) == "Breaking Bad S01E02"
    assert term(Map.merge(tv, %{"season" => "S1", "ep" => "E2"})) == "Breaking Bad S01E02"
    assert term(Map.merge(tv, %{"season" => "00", "ep" => "3"})) == "Breaking Bad S00E03"
    assert term(Map.put(tv, "season", "5")) == "Breaking Bad S05"

    assert term(Map.merge(tv, %{"season" => "2026", "ep" => "10/05"})) ==
             "Breaking Bad 2026.10.05"

    assert term(tv) == "Breaking Bad"
  end

  test "a movie gets its year unless the title already has it" do
    assert term(%{"t" => "movie", "q" => "Dune", "year" => "2021"}) == "Dune 2021"
    assert term(%{"t" => "movie", "q" => "Dune 2021", "year" => "2021"}) == "Dune 2021"
  end

  test "music and books join their parts, even with an empty q" do
    music = %{"t" => "music", "q" => "", "artist" => "Weezer", "album" => "Pinkerton"}
    assert term(music) == "Weezer Pinkerton"

    book = %{"t" => "book", "author" => "Andy Weir", "title" => "Project Hail Mary"}
    assert term(book) == "Andy Weir Project Hail Mary"
    assert term(%{"t" => "book", "title" => " Dune "}) == "Dune"
  end

  test "no text is a poll for the newest, and ids alone match nothing" do
    assert {:ok, %{term: nil, unsupported?: false}} = TorznabRequest.parse(%{"t" => "tvsearch"})

    # Sonarr would only send an id alone if the caps offered it.
    assert {:ok, %{term: nil, unsupported?: false}} =
             TorznabRequest.parse(%{"t" => "tvsearch", "season" => "1", "ep" => "2"})

    assert {:ok, %{term: nil, unsupported?: true}} =
             TorznabRequest.parse(%{"t" => "movie", "imdbid" => "0133093"})
  end

  test "categories take their families and parents, and bad paging is defaulted" do
    {:ok, request} =
      TorznabRequest.parse(%{
        "T" => "search",
        "Cat" => "5040, 2000,nope,123456",
        "limit" => "500",
        "offset" => "-3"
      })

    assert 5040 in request.category_ids and 5000 in request.category_ids
    assert 2045 in request.category_ids
    refute 5070 in request.category_ids
    assert request.limit == TorznabRequest.max_limit()
    assert request.offset == 0

    assert {:ok, %{limit: 100, offset: 0}} =
             TorznabRequest.parse(%{"t" => "search", "limit" => "x", "offset" => "1e3"})

    assert {:ok, %{limit: 25, offset: 50}} =
             TorznabRequest.parse(%{"t" => "search", "limit" => "25", "offset" => "50"})
  end

  test "functions it does not have are Newznab errors" do
    assert {:ok, %{function: :caps}} = TorznabRequest.parse(%{"t" => "caps"})
    assert {:error, 200, _} = TorznabRequest.parse(%{})
    assert {:error, 202, _} = TorznabRequest.parse(%{"t" => "nonsense"})
    assert {:error, 203, _} = TorznabRequest.parse(%{"t" => "details"})
  end
end
