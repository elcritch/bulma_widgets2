defmodule BulmaWidgets.Widgets.SelectionMenu do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  use BulmaWidgets, :css_utilities

  require Logger

  @moduledoc """

  ## Examples

      <.live_component
        module={SelectionMenu}
        id="wiper_mode"
        is-fullwidth
        is-info
        label="Wiper Modes"
        values={[
          {"Regular", 1},
          {"Inverted", -1}
        ]}
      >
      </.live_component>
  """

  @standard_actions [
    {Action.AssignField, field: :data}
  ]

  def update(assigns, socket) do
    # Logger.debug("selection_menu:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:ok, Actions.update(assigns, socket)}
  end

  attr :id, :string, required: true
  attr :label, :string, default: ""
  attr :values, :list, required: true
  attr :data, :any, default: {nil, nil}
  attr :extra_actions, :list, default: []
  attr :standard_actions, :list, default: @standard_actions
  attr :rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs()

  slot :default_label
  def render(assigns) do
    # Logger.info("selection_menu:render: assigns: #{inspect(assigns, pretty: true)}")
    # Logger.info("selection_menu:render: assigns:data: #{inspect(assigns.data)}")

    ~H"""
    <aside class="menu">
      <p class="menu-label" >
        DATA: <%= @data |> inspect() %>
      </p>
      <p class="menu-label" :if={@label != ""}>
        <%= @label %>
      </p>
      <ul class="menu-list">
        <li :for={{key, value} <- @values}>
          <a href="#"
            class={[value == value(@data) && "is-active" || ""]}
            phx-click={
              JS.push("menu-select-action", target: @rest.myself)
              |> JS.remove_class("is-active", to: "##{@id}")
            }
            phx-value-id={@id}
            phx-value-key={key}
            phx-value-value={value}
            phx-target={@rest.myself}
          >
            <%= key %>
          </a>
        </li>
      </ul>
    </aside>
    """
  end

  def handle_event(
        "menu-select-action",
        %{"id" => menu_name, "key" => key, "value" => _value},
        socket
      ) do
    value = socket.assigns.values |> Map.new() |> Map.get(key)

    {:noreply,
     socket
     |> Actions.handle_event(menu_name, {key, value}, @standard_actions)}
  end

  def key({k, _v}), do: k
  def key(k), do: k
  def value({_k, v}), do: v
  def value(k), do: k
end
