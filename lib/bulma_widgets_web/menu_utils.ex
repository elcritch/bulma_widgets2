defmodule BulmaWidgetsWeb.MenuUtils do
  use BulmaWidgetsWeb, :html

  def menu_items() do
    [
      {"Main", %{href: ~p"/", icon: ["fas", "fa-gauge"]}},
      {"Widgets", %{href: ~p"/widgets.html", icon: ["fas", "fa-gear"]}}
    ]
  end
end
