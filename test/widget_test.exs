defmodule BulmaWidgetsTest.Widgets do
  use BulmaWidgetsWeb.ConnCase

  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint BulmaWidgetsWeb.Endpoint


  test "disconnected and connected mount", %{conn: conn} do
    {:ok, view, html} = live(conn, "/examples/selection_menu")

    # IO.puts("view: #{inspect(view, pretty: true)}")
    IO.puts(html)

  end

end
