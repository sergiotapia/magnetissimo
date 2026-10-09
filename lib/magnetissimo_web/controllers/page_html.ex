defmodule MagnetissimoWeb.PageHTML do
  @moduledoc """
  Renders the pages served by `MagnetissimoWeb.PageController` from the
  templates in `page_html/`.
  """
  use MagnetissimoWeb, :html

  embed_templates "page_html/*"
end
