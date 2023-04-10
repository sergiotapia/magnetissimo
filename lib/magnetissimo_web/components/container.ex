defmodule MagnetissimoWeb.Components.Containers do
  use Phoenix.Component

  attr(:class, :string, default: "")
  attr(:id, :string)
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
