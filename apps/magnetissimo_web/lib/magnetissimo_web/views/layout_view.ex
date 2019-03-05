defmodule MagnetissimoWeb.LayoutView do
  use MagnetissimoWeb, :view

  def active_menu_class(menu_name, selected_menu) do
    IO.inspect(menu_name)
    IO.inspect(selected_menu)

    if menu_name == selected_menu do
      "panel-block is-active"
    else
      "panel-block"
    end
  end
end
