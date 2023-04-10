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
      <p>asdasdasd</p>
      <%= if @current_user do %>
        <li class="text-[0.8125rem] leading-6 text-zinc-900">
          <%= @current_user.email %>
        </li>
        <li>
          <.link
            href={~p"/users/settings"}
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Settings
          </.link>
        </li>
        <li>
          <.link
            href={~p"/users/log_out"}
            method="delete"
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Log out
          </.link>
        </li>
      <% else %>
        <li>
          <.link
            href={~p"/users/register"}
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Register
          </.link>
        </li>
        <li>
          <.link
            href={~p"/users/log_in"}
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Log in
          </.link>
        </li>
      <% end %>
    </div>
    """
  end
end
