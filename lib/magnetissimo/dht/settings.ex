defmodule Magnetissimo.DHT.Settings do
  @moduledoc """
  Whether the DHT crawler runs, and at which rate preset. One row, changed on
  the `/dht` page through `Magnetissimo.DHT.update_settings/1`.

  There is no row until the first change, and no row reads as the defaults:
  off, at `gentle`. The crawler stays off until someone turns it on, because
  it talks to thousands of strangers and keeps a home router busy.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @rates ~w(gentle normal max)

  @type t :: %__MODULE__{}

  schema "dht_settings" do
    field :enabled, :boolean, default: false
    field :rate, :string, default: "gentle"

    timestamps(type: :utc_datetime_usec)
  end

  @doc "The rate presets a reader can pick, gentlest first."
  def rates, do: @rates

  @doc "Casts what the `/dht` form sends: the switch and the rate."
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:enabled, :rate])
    |> validate_required([:enabled, :rate])
    |> validate_inclusion(:rate, @rates)
  end
end
