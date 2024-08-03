defmodule BulmaWidgetsTest.Widgets do
  use BulmaWidgetsWeb.ConnCase

  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint BulmaWidgetsWeb.Endpoint


  test "disconnected and connected mount", %{conn: conn} do
    {:ok, view, html} = live(conn, "/widgets.html")

    # IO.puts("view: #{inspect(view, pretty: true)}")
    IO.puts("html: #{inspect(html, pretty: true)}")

  end

end
