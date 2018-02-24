defmodule Magnetissimo.RegexCase do
  defmacro regex_case(string, do: lines) do
  new_lines = Enum.map lines, fn ({:->, context, [[regex], result]}) ->
    condition = quote do: String.match?(unquote(string), unquote(regex))
    {:->, context, [[condition], result]}
  end

  # Base case if nothing matches; "cond" complains otherwise.
  base_case = quote do: (true -> nil)
  new_lines = new_lines ++ base_case

  quote do
    cond do
      unquote(new_lines)
    end
  end
end
end
