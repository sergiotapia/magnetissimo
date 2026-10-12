defmodule MagnetissimoWeb.DhtSettingsController do
  @moduledoc """
  `POST /dht/settings`: the DHT switch and rate for a page without
  JavaScript. With JavaScript the LiveView saves them as they change.
  """
  use MagnetissimoWeb, :controller

  alias Magnetissimo.DHT
  alias MagnetissimoWeb.DhtSettings

  def update(conn, %{"dht" => params}) do
    case DHT.update_settings(DhtSettings.attrs(params)) do
      {:ok, _settings} ->
        redirect(conn, to: ~p"/dht")

      {:error, _changeset} ->
        conn |> put_flash(:error, "Those settings didn't save.") |> redirect(to: ~p"/dht")
    end
  end

  def update(conn, _params), do: redirect(conn, to: ~p"/dht")
end
