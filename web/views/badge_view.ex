defmodule Krihelinator.BadgeView do
  use Krihelinator.Web, :view

  @doc """
  Returns the Vue.js template for presenting the badge. It is used most
  of the time. The render function replaces the Vue tags with the correct
  value manually.
  """
  def template() do
    """
    <svg xmlns="http://www.w3.org/2000/svg" width="120" height="20">
      <linearGradient id="a" x2="0" y2="100%">
        <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
        <stop offset="1" stop-opacity=".1"/>
      </linearGradient>
      <rect rx="3" width="120" height="20" fill="#555"/>
      <rect rx="3" x="80" width="40" height="20" fill="#4CC71E"/>
      <rect x="80" width="10" height="20" fill="#4CC71E"/>
      <rect rx="3" width="120" height="20" fill="url(#a)"/>
      <g fill="#fff" text-anchor="left" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
        <text x="4" y="15" fill="#010101" fill-opacity=".3">Krihelimeter</text>
        <text x="4" y="14">Krihelimeter</text>
      </g>
      <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
        <text x="100" y="15" fill="#010101" fill-opacity=".3">{{ repo.krihelimeter }}</text>
        <text x="100" y="14">{{ repo.krihelimeter }}</text>
      </g>
    </svg>
    """
  end

  def render("badge.svg", %{repo: repo}) do
    krihelimeter_str =
      repo
      |> Krihelinator.Krihelimeter.calculate()
      |> Integer.to_string()
    String.replace(template, "{{ repo.krihelimeter }}", krihelimeter_str)
  end

  def render("error.json", _opts) do
    %{"error": "Failed to process badge"}
  end
end
