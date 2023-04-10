defmodule MagnetissimoWeb.Components.Containers do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import MagnetissimoWeb.Gettext

  attr(:class, :string, default: "")
  slot(:inner_block, required: true)

  def box(assigns) do
    ~H"""
    <div class={[
      "box",
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
