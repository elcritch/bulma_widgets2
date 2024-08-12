defmodule BulmaWidgetsWeb.MenuUtils do
  use BulmaWidgetsWeb, :html

  def menu_items() do
    [
      %{name: "Main", href: ~p"/", icon: ["fas", "fa-gauge"]},
      %{name: "Widgets", href: ~p"/widgets.html", icon: ["fas", "fa-gear"]}
    ]
  end
end
