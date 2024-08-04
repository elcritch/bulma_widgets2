defmodule BulmaWidgetsTest.Widgets do
  use BulmaWidgetsWeb.ConnCase

  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint BulmaWidgetsWeb.Endpoint


  test "disconnected and connected mount", %{conn: conn} do
    {:ok, view, html} = live(conn, "/examples/selection_menu")
    # {:ok, view, html} = live(conn, "/widgets.html")

    first_item = "#wiper_options > ul:nth-child(2) > li:nth-child(2) > a:nth-child(1)"
    second_item = "#wiper_options > ul:nth-child(2) > li:nth-child(2) > a:nth-child(1)"

    res =
      view
        |> element(second_item)
        |> render_click()


    IO.puts("\n\nRESULT: ")
    IO.puts(res)

  end

end
