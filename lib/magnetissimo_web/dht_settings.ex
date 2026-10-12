defmodule MagnetissimoWeb.DhtSettings do
  @moduledoc """
  The `/dht` settings form: the on/off switch and the rate slider, read from
  and written to `Magnetissimo.DHT.Settings`.

  The slider is a range input, so it sends a position, 0 to 2, gentlest
  first, which is mapped to a preset's name here. Both the LiveView and the
  no-JavaScript POST (`MagnetissimoWeb.DhtSettingsController`) read the form
  through `attrs/1`.
  """

  alias Magnetissimo.DHT.Settings

  @doc "The form for the saved settings."
  def form(%Settings{} = settings) do
    Phoenix.Component.to_form(
      %{
        "enabled" => to_string(settings.enabled),
        "rate" => Integer.to_string(position(settings.rate))
      },
      as: :dht
    )
  end

  @doc "The attrs `Magnetissimo.DHT.update_settings/1` takes, from the form's params."
  def attrs(params) when is_map(params) do
    %{enabled: params["enabled"] in ["true", "on"], rate: rate(params["rate"])}
  end

  @doc "Where a preset sits on the slider."
  def position(rate), do: Enum.find_index(Settings.rates(), &(&1 == rate)) || 0

  defp rate(position) when is_binary(position) do
    case Integer.parse(position) do
      {index, ""} -> Enum.at(Settings.rates(), index, "gentle")
      _ -> if position in Settings.rates(), do: position, else: "gentle"
    end
  end

  defp rate(_position), do: "gentle"
end
