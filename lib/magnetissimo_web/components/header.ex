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
    <header class="w-full px-6 mx-auto max-w-screen-2xl py-7">
      <div class="flex items-center justify-between">
        <.link class="inline-block mr-8" navigate={~p"/"}>
          <h1 class="text-4xl font-bold">Magnetissimo</h1>
        </.link>
        <.link navigate={~p"/"} class="inline-block mr-5">Home</.link>
        <.link navigate={~p"/"} class="inline-block mr-5">Feeds</.link>
        <.link
          href="https://github.com/sergiotapia/magnetissimo"
          target="_blank"
          class="inline-block mr-5"
        >
          Github
        </.link>

        <div class="flex">
          <%= if @current_user do %>
            <span class="inline-block mr-5">
              Welcome back, <%= @current_user.email %>!
            </span>
            <.link class="inline-block mr-5" href={~p"/users/settings"}>
              Settings
            </.link>
            <.link href={~p"/users/log_out"} method="delete">
              Log out
            </.link>
          <% else %>
            <.link class="inline-block mr-8" href={~p"/users/register"}>
              Register
            </.link>
            <.link href={~p"/users/log_in"}>
              Log in
            </.link>
          <% end %>
        </div>
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
