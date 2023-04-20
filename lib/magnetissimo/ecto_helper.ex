defmodule Magnetissimo.EctoHelper do
  def enum(values) do
    # An alternative to the code below could also be:
    # Ecto.ParameterizedType.init(Ecto.Enum, values: values)
    #
    # As suggested by Benjamin Milde here: https://github.com/PJUllrich/pragprog-book-tables/issues/2
    # Thank you, Benjamin!

    {:parameterized, Ecto.Enum, Ecto.Enum.init(values: values)}
  end
end
