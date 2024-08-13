defmodule BulmaWidgets.Main do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  require Logger

  import Phoenix.Controller, only: [get_csrf_token: 0]

  def burger(assigns) do
    ~H"""
        <a
          role="button"
          class="navbar-burger burger"
          aria-label="menu"
          aria-expanded="false"
          phx-click={JS.toggle_class("is-active", to: [".navbar-burger", "#navMenuMain"])}
          phx-click-away={JS.remove_class("is-active", to: [".navbar-burger", "#navMenuMain"])}
          data-target="navMenuMain"
          aria-label="menu"
          aria-expanded="false"
        >
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
    """
  end

  attr(:dark_text, :string, default: "Switch Light")
  attr(:light_text, :string, default: "Switch Dark")
  def toggle_theme(assigns) do
    ~H"""
    <style>
      html.theme-light .bulma-widgets-theme-dark {
        display: none;
      }
      html.theme-dark .bulma-widgets-theme-light {
        display: none;
      }
    </style>
    <a class={["navbar-item", "is-unselectable" ]}>
      <span class="tag bulma-widgets-theme-dark"
          phx-click={
            JS.dispatch("bulma-widgets:set-theme", detail: %{theme: "light"}, to: ["html"])
          }
      >
        <%= @dark_text %>
      </span>
      <span class="tag bulma-widgets-theme-light"
          phx-click={
            JS.dispatch("bulma-widgets:set-theme", detail: %{theme: "dark"}, to: ["html"])
          }
      >
        <%= @light_text %>
      </span>
    </a>
    """
  end

  def item_span(assigns) do
    ~H"""
      <span class="icon" :if={:item in @item}>
        <i class={@item[:icon]} />
      </span>
      <span>
        <%= @item.name %>
      </span>
    """
  end

  attr(:'is-right', :boolean, default: false, doc: "the data structure for the form")
  attr(:'is-hoverable', :boolean, default: true, doc: "the data structure for the form")
  attr(:title, :any, default: "Menu", doc: "the menu")
  attr(:items, :any, required: true, doc: "the data structure for the form")
  slot(:menu, doc: "navbar start") do
    attr(:classes, :list, doc: "extra css classes")
  end
  def navbar_dropdown(assigns) do
    ~H"""
          <div class={["navbar-item", "has-dropdown", BulmaWidgets.classes(assigns, [:"is-hoverable"])]}>
            <a class="navbar-link">
              <%= @title %>
            </a>

            <div class={["navbar-dropdown", BulmaWidgets.classes(assigns, [:"is-right"])]}>
              <!-- navbar items -->
              <%= for menu <- @menu |> Enum.take(1) do %>
                <%= for item <- @items do %>
                  <a class={["navbar-item", menu[:classes] || "" ]} href={item.href}>
                    <%= if menu[:inner_block] == nil do %>
                      <.item_span item={item}/>
                    <% else %>
                      <%= render_slot(menu, item) %>
                    <% end %>
                  </a>
                <% end %>
              <% end %>
            </div>
          </div>
    """
  end

  attr(:page_title, :any, required: true, doc: "the page title")
  attr(:menu_items, :any, required: true, doc: "the data structure for the form")
  attr(:burger, :boolean, default: true, doc: "include mobile burger menu")
  attr(:fixed, :string, required: true, doc: "where to fix: top, bottom, none")

  slot(:logo, doc: "place logo here") do
    attr(:classes, :list, doc: "extra css classes")
  end
  slot(:navbar_start, doc: "navbar start")
  slot(:navbar_end, doc: "navbar end")
  slot(:body, doc: "content body")

  def navbar(assigns) do
    icons =
      assigns.menu_items
      |> Enum.map(fn v -> {v[:name],v[:icon]} end)
      |> Map.new()

    assigns =
      assigns
      |> assign(:icons, icons)
      |> assign(:title_icon, icons[assigns.page_title])

    ~H"""
    <!-- START NAV -->
    <nav class={"navbar is-info is-fixed-#{@fixed}"} role="navigation" aria-label="dropdown navigation">
      <div class="navbar-brand">
        <%= for logo <- @logo do %>
          <a class={["navbar-item", logo.classes]} href="/">
            <%= render_slot(logo) %>
          </a>
        <% end %>

        <.burger :if={@burger == true}></.burger>
      </div>

      <div id="navMenuMain" class="navbar-menu ">
        <div class="navbar-start">
          <%= render_slot(@navbar_start, @menu_items) %>
        </div>

        <div class="navbar-end">
          <%= render_slot(@navbar_end, @menu_items) %>
        </div>
      </div>
    </nav>
    """
  end

  attr(:navbar_fixed, :string, default: nil, doc: "navbar fixed")
  attr(:theme, :string, default: "light", doc: "theme")
  slot(:menu, required: false, doc: "navbar")
  slot(:body, required: true, doc: "content")

  def body(assigns) do
    assigns =
      assigns
      |> assign(:navbar_class, assigns.navbar_fixed && "has-navbar-fixed-#{assigns.navbar_fixed}" || "")
      |> assign(:theme_class, assigns.theme && "theme-#{assigns.theme}" || "")

    ~H"""
      <body class={[@navbar_class, @theme_class]}>
        <%= render_slot(@menu, %{fixed: @navbar_fixed}) %>
        <%= render_slot(@body) %>
      </body>
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
