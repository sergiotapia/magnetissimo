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
            <div>
              <h2 class="text-white font-bold underline underline-offset-4 mb-4">Account</h2>

              <%= if @current_user do %>
                Welcome back, <%= @current_user.email %>
                <.link href={~p"/users/settings"}>
                  Settings
                </.link>
                <.link href={~p"/users/log_out"} method="delete">
                  Log out
                </.link>
              <% else %>
                <.link href={~p"/users/register"}>
                  Register
                </.link>
                <.link href={~p"/users/log_in"}>
                  Log in
                </.link>

                <p class="text-sm italic">
                  <span class="font-bold">Why do I need an account?</span>
                  You don't. Only create an account if you want to manage feeds.
                </p>
              <% end %>
            </div>
          </div>
        </div>

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
