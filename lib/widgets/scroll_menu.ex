defmodule BulmaWidgets.Widgets.ScrollMenu do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  alias BulmaWidgets.Action.AssignField
  import BulmaWidgets.Components

  require Logger

  @moduledoc """

  ## Examples

      <.live_component
        module={ScrollMenu}
        id="wiper_mode"
        is-fullwidth
        is-info
        values={[
          {"Regular", 1},
          {"Inverted", -1}
        ]}
      >
        <:label :let={{k, _}}>
          Test: <%= k %>
        </:label>
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
  attr(:values, :list, required: true)
  attr(:data, :any, default: {nil, nil})
  attr(:extra_actions, :list, default: [])
  attr(:standard_actions, :list, default: @standard_actions)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:label)
  slot(:default_label)

  def render(assigns) do
    # Logger.info("scroll_menu:render: assigns: #{inspect(assigns, pretty: true)}")
    # Logger.info("scroll_menu:render: assigns:data: #{inspect(assigns.data)}")

    ~H"""
    <div>
      <.dropdown id={@id} values={@values} selected={@data}>
        <:label :let={sel}>
          <%= render_slot(@label, sel) %>
        </:label>
        <:label_icon base="fas" name="fa-angle-down" />

        <:items :let={%{id: id, label: label, key: key, parent: _parent, selected: selected}}>
          <a
            class={["dropdown-item", (selected && "is-active") || ""]}
            phx-click={
              JS.push("menu-select-action", target: @rest.myself)
              |> JS.remove_class("is-active", to: "##{@id}")
            }
            phx-value-id={id}
            phx-value-value-hash={key |> :erlang.phash2()}
            phx-target={@rest.myself}
          >
            <%= label %>
          </a>
        </:items>
      </.dropdown>
    </div>

    """
  end

  def handle_event("menu-select-action", data, socket) do
    %{"id" => menu_name, "value-hash" => hash} = data

    # lookup menu item based on selected value hash
    {hash_key, ""} = hash |> Integer.parse()

    {key, value} =
      socket.assigns.values
      |> Map.new(fn {k, v} -> {k |> :erlang.phash2(), {k, v}} end)
      |> Map.get(hash_key)

    Logger.debug("menu-select-action: #{inspect({key, value}, pretty: true)}")
    # Logger.debug("scroll_menu:socket: #{inspect(socket, pretty: true)}")
    {:noreply,
     socket
     |> Actions.handle_event(menu_name, {key, value}, @standard_actions)}
  end

  def key({k, _v}), do: k
  def key(k), do: k
  def value({_k, v}), do: v
  def value(k), do: k
end
