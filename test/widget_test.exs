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

  @wo_first_item "#wiper_options > ul:nth-child(2) > li:nth-child(1)"
  @wo_second_item "#wiper_options > ul:nth-child(2) > li:nth-child(2)"

  test "basic menu selection", %{conn: conn} do
    # {:ok, view, html} = live(conn, "/examples/selection_menu")
    {:ok, view, html} = live(conn, "/widgets.html")


    res =
      view
        |> element(@wo_second_item <> " > a:nth-child(1)")
        |> render_click()

    # IO.puts("\n\nRESULT: ")
    # IO.puts(res)

    refute has_element?(view, "#wiper_options > ul:nth-child(2) > li:nth-child(1) > a[class*=is-active]")
    assert has_element?(view, @wo_second_item <> " > a[class*=is-active]")

    # view |> prettyElement("element 2", @wo_second_item <> " > a[class*=is-active]")

  end

  test "test broadcast", %{conn: conn} do
    # set cache value
    BulmaWidgets.Cache.clear!()

    {:ok, view, html} = live(conn, "/widgets.html")
    # Load another view and verify it's updated
    {:ok, view2, html2} = live(conn, "/widgets.html")

    # view |> prettyElement("wiper_options", "#wiper_options " )
    refute has_element?(view, @wo_first_item <> " > a[class*=is-active]")
    refute has_element?(view, @wo_second_item <> " > a[class*=is-active]")
    refute has_element?(view2, @wo_first_item <> " > a[class*=is-active]")
    refute has_element?(view2, @wo_second_item <> " > a[class*=is-active]")

    # select menu on first view, should broadcast update to second view
    res =
      view
        |> element(@wo_first_item <> " > a:nth-child(1)")
        |> render_click()

    # view |> prettyElement("wiper_options", "#wiper_options " )
    assert has_element?(view, @wo_first_item <> " > a[class*=is-active]")
    refute has_element?(view, @wo_second_item <> " > a[class*=is-active]")

    # view2 |> prettyElement("wiper_options", "#wiper_options " )
    assert has_element?(view2, @wo_first_item <> " > a[class*=is-active]")
    refute has_element?(view2, @wo_second_item <> " > a[class*=is-active]")

  end

  test "manually set cache item", %{conn: conn} do
    # set cache value
    BulmaWidgets.Cache.clear!()
    key = "test-value-set"
    data = %{wiper_options: {"Inverted", -1}}
    BulmaWidgets.Cache.put(BulmaWidgets.Action.CacheState, key, data)

    {:ok, view, html} = live(conn, "/widgets.html")

    # view |> prettyElement("element 2", "#wiper_options " )
    refute has_element?(view, "#wiper_options > ul:nth-child(2) > li:nth-child(1) > a[class*=is-active]")
    assert has_element?(view, @wo_second_item <> " > a[class*=is-active]")

  end

  test "cache load on mount", %{conn: conn} do
    # set cache value
    BulmaWidgets.Cache.clear!()

    {:ok, view, html} = live(conn, "/widgets.html")

    # view |> prettyElement("wiper_options", "#wiper_options " )
    refute has_element?(view, @wo_first_item <> " > a[class*=is-active]")
    refute has_element?(view, @wo_second_item <> " > a[class*=is-active]")

    # select menu, should update cache
    res =
      view
        |> element(@wo_first_item <> " > a:nth-child(1)")
        |> render_click()

    # view |> prettyElement("wiper_options", "#wiper_options " )
    assert has_element?(view, @wo_first_item <> " > a[class*=is-active]")
    refute has_element?(view, @wo_second_item <> " > a[class*=is-active]")

    # Load another view and verify it's updated
    {:ok, view2, html2} = live(conn, "/widgets.html")

    # view2 |> prettyElement("wiper_options", "#wiper_options " )
    assert has_element?(view2, @wo_first_item <> " > a[class*=is-active]")
    refute has_element?(view2, @wo_second_item <> " > a[class*=is-active]")

  end

  @ws_label "#wiper_speed > div.dropdown-trigger > button > span:nth-child(1)"
  @ws_items "#wiper_speed > div.dropdown-menu > div "
  @ws_first_item "#wiper_speed > div.dropdown-menu > div > a:nth-child(1)"
  @ws_second_item "#wiper_speed > div.dropdown-menu > div > a:nth-child(2)"

  test "basic scroll_menu selection", %{conn: conn} do
    # {:ok, view, html} = live(conn, "/examples/selection_menu")
    {:ok, view, html} = live(conn, "/widgets.html")

    res = nil

    assert element(view, @ws_label) |> render() =~ "Test:"
    refute element(view, @ws_first_item) |> render() =~ "class=\"is-active\""
    refute element(view, @ws_second_item) |> render() =~ "class=\"is-active\""

    refute has_element?(view, "#wiper_speed a[class*=is-active]")

    # IO.puts("\n\nRESULT: ")
    # IO.puts(res)

    res =
      view
        |> element(@ws_first_item)
        |> render_click()

    assert has_element?(view, "#{@ws_items} .is-active:nth-child(1) ")
    refute has_element?(view, "#{@ws_items} .is-active:nth-child(2) ")

    res =
      view
        |> element(@ws_second_item)
        |> render_click()

    refute has_element?(view, "#{@ws_items} .is-active:nth-child(1) ")
    assert has_element?(view, "#{@ws_items} .is-active:nth-child(2) ")

  end

  @tab_label "#wiper_speed > div.dropdown-trigger > button > span:nth-child(1)"
  @tab_items "#example_tabs-tab1 > a:nth-child(1)"

  test "basic tab selection", %{conn: conn} do
    # {:ok, view, html} = live(conn, "/examples/selection_menu")
    {:ok, view, html} = live(conn, "/widgets.html")

    res = nil

    refute element(view, @ws_first_item) |> render() =~ "class=\"is-active\""
    refute element(view, @ws_second_item) |> render() =~ "class=\"is-active\""

    refute has_element?(view, "#wiper_speed a[class*=is-active]")

    # IO.puts("\n\nRESULT: ")
    # IO.puts(res)

    res =
      view
        |> element(@ws_first_item)
        |> render_click()

    assert has_element?(view, "#{@ws_items} .is-active:nth-child(1) ")
    refute has_element?(view, "#{@ws_items} .is-active:nth-child(2) ")

    res =
      view
        |> element(@ws_second_item)
        |> render_click()

    refute has_element?(view, "#{@ws_items} .is-active:nth-child(1) ")
    assert has_element?(view, "#{@ws_items} .is-active:nth-child(2) ")

  end

end
