defmodule MagnetissimoWeb.PaginationComponent do
  use MagnetissimoWeb, :live_component

  alias MagnetissimoWeb.Forms.PaginationForm

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-between mt-4 mb-4 md:flex-row">
      <div class="flex flex-wrap space-x-2 md:flex-nowrap">
        <%= for {page_number, current_page?} <- pages(@pagination) do %>
          <div
            phx-click="show_page"
            phx-value-page={page_number}
            phx-target={@myself}
            class={"cursor-pointer px-2 py-1 rounded-md border border-gray-300 text-sm font-medium hover:bg-gray-100 transition duration-150 ease-in-out #{if current_page?, do: "bg-blue-500 text-white", else: "bg-white text-gray-700"}"}
          >
            <%= page_number %>
          </div>
        <% end %>
      </div>
      <div class="mt-4 md:mt-0">
        <.simple_form
          :let={f}
          for={%{}}
          as={:page_size}
          phx-change="set_page_size"
          phx-target={@myself}
        >
          <.input
            type="select"
            field={f[:page_size]}
            options={[10, 20, 50, 100]}
            value={@pagination.page_size}
            class="block w-full px-4 py-2 pr-8 leading-tight bg-white border border-gray-400 rounded shadow appearance-none hover:border-gray-500 focus:outline-none focus:shadow-outline"
          />
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("show_page", params, socket) do
    parse_params(params, socket)
  end

  @impl true
  def handle_event("set_page_size", %{"page_size" => params}, socket) do
    parse_params(params, socket)
  end

  defp parse_params(params, socket) do
    %{pagination: pagination} = socket.assigns

    case PaginationForm.parse(params, pagination) do
      {:ok, opts} ->
        send(self(), {:update, opts})
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def pages(%{page_size: page_size, page: current_page, total_count: total_count}) do
    page_count = ceil(total_count / page_size)

    for page <- 1..page_count//1 do
      current_page? = page == current_page

      {page, current_page?}
    end
  end
end
