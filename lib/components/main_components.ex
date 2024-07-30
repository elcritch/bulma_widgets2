defmodule BulmaWidgets.MainComponents do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  require Logger

  import Phoenix.Controller,
    only: [get_csrf_token: 0, view_module: 1, view_template: 1]

  attr(:page_title, :any, required: true, doc: "the page title")
  attr(:menu_items, :any, required: true, doc: "the data structure for the form")

  slot(:logo, doc: "place logo here")

  def topbard(assigns) do
    icons = assigns.menu_items |> Enum.map(fn {k,v} -> {k,v[:icon]} end) |> Map.new()

    assigns =
      assigns
      |> assign(:icons, icons)
      |> assign(:title_icon, icons[assigns.page_title])

    ~H"""
    <!-- START NAV -->
    <nav class="navbar is-info is-fixed-top" role="navigation" aria-label="main navigation">
      <div class="navbar-brand">
        <a class="is-size-4 navbar-item brand-text has-text-black" href="/">
          <%= render_slot(@logo) %>
        </a>
        <a class="navbar-item px-4 is-italic m-0 p-0 ">
          <button class="button is-link is-soft is-outlined">
            <%= if @page_title do %>
              <span class="icon">
                <i class={@title_icon}></i>
              </span>
            <% end %>
            <span> <%= @page_title || "" %> </span>
          </button>
        </a>

        <a
          role="button"
          class="navbar-burger burger"
          aria-label="menu"
          aria-expanded="false"
          phx-click={JS.toggle_class("is-active", to: [".navbar-burger", "#navMenu"])}
          phx-click-away={JS.remove_class("is-active", to: [".navbar-burger", "#navMenu"])}
          data-target="navMenu"
          aria-label="menu"
          aria-expanded="false"
        >
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
      </div>

      <div id="navMenu" class="navbar-menu ">
        <div class="navbar-start"></div>
        <div class="navbar-end">
          <!-- navbar items -->
          <%= for {name, item} <- @menu_items do %>
            <a class="navbar-item button is-size-5 " href={item.href}>
              <span class="icon">
                <i class={item[:icon]} />
              </span>
              <span>
                <%= name %>
              </span>
            </a>
          <% end %>

        </div>
      </div>
    </nav>
    """
  end

  attr(:page_title, :any, required: true, doc: "the page title")
  attr(:menu_items, :any, required: true, doc: "the data structure for the form")

  slot(:title, doc: "place title here")
  def root_example(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="has-navbar-fixed-top theme-dark">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />

        <%= render_slot(@title) %>
        <link phx-track-static rel="stylesheet" href="/bulma/assets/bulma_widgets.css" />
        <link phx-track-static rel="stylesheet" href="/assets/app.css" />

        <!-- font awesome -->
        <link phx-track-static rel="stylesheet" href="/bulma/fonts/fontawesome6/css/fontawesome.min.css" />
        <link phx-track-static rel="stylesheet" href="/bulma/fonts/fontawesome6/css/solid.min.css" />

        <script defer phx-track-static type="text/javascript" src="/assets/app.js">
        </script>
      </head>
      <body>
        <BulmaWidgets.MainComponents.topbard page_title={@page_title} menu_items={@menu_items} />

        <section class="hero is-dark is-fullheight-with-navbar">
            <%= @inner_content %>
        </section>
      </body>
    </html>

    """
  end
end
