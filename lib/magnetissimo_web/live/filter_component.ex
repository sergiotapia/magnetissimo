defmodule MagnetissimoWeb.FilterComponent do
  use MagnetissimoWeb, :live_component

  alias MagnetissimoWeb.Forms.FilterForm

  def render(assigns) do
    ~H"""
    <div id="table-filter">
      <.simple_form :let={f} for={@changeset} as="filter" phx-submit="search" phx-target={@myself}>
        <div class="row">
          <div class="w-30">
            <.input
              type="text"
              phx_debounce="300"
              field={f[:name]}
              placeholder="Search for any torrent by name."
              class="p-5 mt-0 tracking-tight border-0 bg-neutral-100 rounded-xl sm:text-base placeholder:text-neutral-400"
            />
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign_changeset(assigns, socket)}
  end

  def handle_event("search", %{"filter" => filter}, socket) do
    case FilterForm.parse(filter) do
      {:ok, opts} ->
        send(self(), {:update, opts})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_changeset(%{filter: filter}, socket) do
    IO.inspect(filter)
    assign(socket, :changeset, FilterForm.change_values(filter))
  end
end
