defmodule MagnetissimoWeb.Header do
  use MagnetissimoWeb, :live_component

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign_search_term(params["search_term"])

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign_search_term(params["search_term"])

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <header>
      <div class="mx-auto px-6 w-full max-w-screen-xl">
        <div class="h-20 grid grid-cols-3 items-center">
          <div>
            <%!-- <.link>
              <img src="/images/logo.svg" alt="Magnetissimo" />
            </.link> --%>
          </div>

          <div class="flex justify-center">
            <button class="py-2 px-4 flex items-center gap-1 bg-neutral-100 rounded-full text-neutral-500">
              <div class="text-sm font-semibold">33k magnets</div>
              <.icon name="hero-chevron-right-mini" class="w-4 h-4" />
            </button>
          </div>

          <div class="flex justify-end">
            <div>account</div>
            <div>toggle</div>
          </div>
        </div>

        <h1 class="mb-4 text-3xl font-extrabold tracking-tight">Search the seas.</h1>
        <%!-- <.simple_form :let={f} for={%{}} as={:search} phx-change="search" phx-submit="submit">
          <.input
            phx_debounce="300"
            field={f[:search_term]}
            value={@search_term}
            placeholder="Search anything"
            class="mt-0 p-5 bg-neutral-100 border-0 rounded-xl sm:text-base tracking-tight placeholder:text-neutral-400"
          />

          <div class="mt-3 flex flex-nowrap gap-3 overflow-x-auto overflow-hidden">
            <button :for={_ <- 0..9} class="shrink-0 py-2 px-4 bg-neutral-200 rounded-lg text-sm">
              Recent search value
            </button>
          </div>
        </.simple_form> --%>

        <hr class="my-8 border-black/10" />
      </div>
    </header>
    """
  end

  def handle_event("submit", %{"search" => %{"search_term" => search_term}}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/search/#{search_term}",
       replace: true
     )}
  end

  def handle_event("search", %{"search" => %{"search_term" => ""}}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/",
       replace: true
     )}
  end

  def handle_event("search", %{"search" => %{"search_term" => search_term}}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/search/#{search_term}",
       replace: true
     )}
  end

  defp assign_search_term(socket, nil) do
    assign(socket, :search_term, nil)
  end

  defp assign_search_term(socket, search_term) do
    assign(socket, :search_term, search_term)
  end
end
