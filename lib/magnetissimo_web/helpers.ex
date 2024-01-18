defmodule MagnetissimoWeb.Helpers do
  def format_size(nil), do: nil
  def format_size(""), do: ""

  def format_size(size_in_bytes) do
    Size.humanize!(size_in_bytes)
  end

  def format_date(nil), do: nil
  def format_date(""), do: ""

  def format_date(date) when is_struct(date, DateTime) do
    Calendar.strftime(date, "%B %-d, %Y - %I:%M:%S %p %Z")
  end
end
