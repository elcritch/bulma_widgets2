defmodule BulmaWidgets.Widgets.VertTabView do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  alias BulmaWidgets.Action.AssignField
  alias BulmaWidgets.Widgets.SelectionMenu
  import BulmaWidgets.Layouts

  require Logger

  @moduledoc """

  ## Examples

      <.live_component
        module={TabView}
        id="example_tabs"
      >
        <:tab name="Tab 1" key="tab1">
          <.tab_one />
        </:tab>
        <:tab name="Tab 2" key="tab2">
          <.tab_two />
        </:tab>
      </.live_component>
  """

  @standard_actions [
    {AssignField, field: :data}
  ]

  def update(assigns, socket) do
    # Logger.debug("scroll_menu:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:ok, Actions.update(assigns, socket)}
  end

  attr(:id, :string, required: true)
  attr(:data, :any, default: {nil, nil})
  attr(:extra_actions, :list, default: [])
  attr(:standard_actions, :list, default: @standard_actions)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:label)
  slot(:tab) do
    attr(:name, :string, doc: "Display name of tag")
    attr(:key, :string, doc: "Index id of tab")
  end

  def render(assigns) do
    # Logger.info("tab_view:render: assigns: #{inspect(assigns, pretty: true)}")
    # Logger.info("scroll_menu:render: assigns:data: #{inspect(assigns.data)}")
    Logger.info("tab_view:render: tab: #{inspect(assigns.tab, pretty: true)}")
    values = assigns.tab |> Enum.map(fn t -> {t.name, t.key} end)
    assigns = assigns |> assign(:values, values)

    ~H"""
    <div id={@id}>
      <.smart_grid is-gap-0	>
        <:cell>
          <aside class="menu " id={@id}>
            <p class="menu-label" :if={@label != []}>
              <%= @label %>
            </p>

            <ul class="menu-list">
              <%= for {key, value} <- @values do %>
                <li>
                  <a href="#"
                    class={[value == value(@data) && "is-active" || ""]}
                    phx-click={
                      JS.push("menu-select-action", target: @rest.myself)
                      |> JS.remove_class("is-active", to: "##{@id}")
                    }
                    phx-value-id={@id}
                    phx-value-value-hash={value |> :erlang.phash2()}
                    phx-target={@rest.myself}
                  >
                    <%= key %>
                  </a>
                </li>
              <% end %>
            </ul>
          </aside>
        </:cell>
        <:cell>
          <%= for tab <- @tab do %>
            <div class={tab.key == value(@data) && "" || "is-hidden" } >
              <%= render_slot(tab) %>
            </div>
          <% end %>
        </:cell>
      </.smart_grid>
    </div>
    """
  end

  def handle_event("menu-select-action", data, socket) do
    Logger.info("tab_view:event: data: #{inspect(data, pretty: true)}")
    %{"id" => menu_name, "value-hash" => hash} = data

    # lookup menu item based on selected value hash
    {hash_key, ""} = hash |> Integer.parse()
    value =
      socket.assigns.tab
      |> Enum.map(fn t -> t.key end)
      |> Map.new(fn v -> {v |> :erlang.phash2(), v} end)
      |> Map.get(hash_key)

    Logger.debug("menu-select-action: #{inspect({value}, pretty: true)}")
    # Logger.debug("scroll_menu:socket: #{inspect(socket, pretty: true)}")
    {:noreply,
     socket
     |> Actions.handle_event(menu_name, {menu_name, value}, @standard_actions)}
  end

  def key({k, _v}), do: k
  def key(k), do: k
  def value({_k, v}), do: v
  def value(k), do: k
end
