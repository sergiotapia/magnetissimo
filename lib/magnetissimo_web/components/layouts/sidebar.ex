defmodule MagnetissimoWeb.Layouts.Sidebar do
  # use Phoenix.Component
  use MagnetissimoWeb, :html
  alias Magnetissimo.Torrents

  def index_statistics(assigns) do
    crawler_statistics = Torrents.get_crawler_statistics()
    assigns = assign(assigns, :crawler_statistics, crawler_statistics)

    ~H"""
    <h2 class="text-white font-bold underline underline-offset-4 mb-4">Indexing Statistics</h2>
    <ul class="list-disc text-white">
      <li
        :for={{crawler, torrent_count} <- @crawler_statistics}
        class="flex justify-between items-center"
      >
        <span class="font-bold"><%= crawler %></span>
        <span><%= torrent_count %></span>
      </li>
    </ul>
    """
  end

  def auth(assigns) do
    ~H"""
    <div>
      <h2 class="text-white font-bold underline underline-offset-4 mb-4">Account</h2>

      <%= if @current_user do %>
        Welcome back, <%= @current_user.email %>
        <.link href={~p"/users/settings"} class="block text-white hover:text-zinc-700">
          Settings
        </.link>
        <.link href={~p"/users/log_out"} method="delete" class="block text-white hover:text-zinc-700">
          Log out
        </.link>
      <% else %>
        <.link href={~p"/users/register"} class="block text-white hover:text-zinc-700">
          Register
        </.link>
        <.link href={~p"/users/log_in"} class="block text-white hover:text-zinc-700">
          Log in
        </.link>

        <p class="text-sm italic">
          <span class="font-bold">Why do I need an account?</span>
          You don't. Only create an account if you want to manage feeds.
        </p>
      <% end %>
    </div>
    """
  end
end
