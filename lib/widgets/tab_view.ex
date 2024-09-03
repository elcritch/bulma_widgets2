defmodule BulmaWidgets.Widgets.TabView do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  alias BulmaWidgets.Action.AssignField

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
    # Logger.info("tab_view:render: tab: #{inspect(tab, pretty: true)}")

    ~H"""
    <div id={@id}>
      <div class={["tabs", BulmaWidgets.classes(@rest)]}>
        <ul>
          <%= for tab <- @tab do %>
            <li id={"#{@id}-#{tab.key}"}
                class={tab.key == value(@data) && "is-active" || ""}
            >
              <a
                phx-click={
                  JS.push("menu-select-action", target: @rest.myself)
                }
                phx-value-id={@id}
                phx-value-value-hash={tab.key |> :erlang.phash2()}
                phx-target={@rest.myself}
              >
                <%= tab.name %>
              </a>
            </li>
          <% end %>
        </ul>
      </div>
      <%= for tab <- @tab do %>
        <div class={["blmw-view-tabs", tab.key, tab.key == value(@data) && "" || "is-hidden"]} >
          <%= render_slot(tab) %>
        </div>
      <% end %>
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
