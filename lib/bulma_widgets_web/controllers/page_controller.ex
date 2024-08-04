defmodule BulmaWidgetsWeb.PageController do
  use BulmaWidgetsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    conn =
      conn
      |> assign(:page_title, "Main")
      |> assign(:menu_items, BulmaWidgetsWeb.MenuUtils.menu_items())

    render(conn, :home, layout: false)
  end
end
