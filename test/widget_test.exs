defmodule BulmaWidgetsTest.Widgets do
  use BulmaWidgetsWeb.ConnCase

  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint BulmaWidgetsWeb.Endpoint

  def prettyElement(view, name, selector) do
    # elem2 = view |> element("#wiper_options > ul:nth-child(2) > li:nth-child(2) ") |> render()
    elem = view |> element(selector) |> render()
    IO.puts("\n\n=== Element: #{name} ===")
    IO.puts("selector: #{selector}")
    IO.puts(elem |> Floki.parse_fragment!() |> Floki.raw_html(pretty: true))
  end


  test "basic menu selection", %{conn: conn} do
    # {:ok, view, html} = live(conn, "/examples/selection_menu")
    {:ok, view, html} = live(conn, "/widgets.html")

    first_item = "#wiper_options > ul:nth-child(1) > li:nth-child(2)"
    second_item = "#wiper_options > ul:nth-child(2) > li:nth-child(2)"

    res =
      view
        |> element(second_item <> " > a:nth-child(1)")
        |> render_click()

    # IO.puts("\n\nRESULT: ")
    # IO.puts(res)

    refute has_element?(view, "#wiper_options > ul:nth-child(2) > li:nth-child(1) > a[class*=is-active]")
    assert has_element?(view, second_item <> " > a[class*=is-active]")

    view |> prettyElement("element 2", second_item <> " > a[class*=is-active]")

  end

  test "cache test test", %{conn: conn} do
    # set cache value
    key = "test-value-set"
    data = %{wiper_options: {"Inverted", -1}}
    BulmaWidgets.Cache.put(BulmaWidgets.Action.CacheState, key, data)

    # {:ok, view, html} = live(conn, "/examples/selection_menu")
    {:ok, view, html} = live(conn, "/widgets.html")

    first_item = "#wiper_options > ul:nth-child(1) > li:nth-child(2)"
    second_item = "#wiper_options > ul:nth-child(2) > li:nth-child(2)"

    # view |> prettyElement("element 2", "#wiper_options " )
    refute has_element?(view, "#wiper_options > ul:nth-child(2) > li:nth-child(1) > a[class*=is-active]")
    assert has_element?(view, second_item <> " > a[class*=is-active]")

  end

  test "cache test item 1", %{conn: conn} do
    # set cache value
    key = "test-value-set"
    data = %{wiper_options: {"Regular", 1}}
    BulmaWidgets.Cache.put(BulmaWidgets.Action.CacheState, key, data)

    # {:ok, view, html} = live(conn, "/examples/selection_menu")
    {:ok, view, html} = live(conn, "/widgets.html")

    first_item = "#wiper_options > ul:nth-child(1) > li:nth-child(2)"
    second_item = "#wiper_options > ul:nth-child(2) > li:nth-child(2)"

    # view |> prettyElement("element 2", "#wiper_options " )
    refute has_element?(view, "#wiper_options > ul:nth-child(1) > li:nth-child(1) > a[class*=is-active]")
    assert has_element?(view, first_item <> " > a[class*=is-active]")

  end

end
