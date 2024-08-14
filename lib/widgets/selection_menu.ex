defmodule BulmaWidgets.Widgets.SelectionMenu do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  use BulmaWidgets, :css_utilities
  alias BulmaWidgets.Action.AssignField

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
    {AssignField, field: :data}
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
    <aside class="menu" id={@id}>
      <p class="menu-label" :if={@label != ""}>
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
    """
  end

  def handle_event( "menu-select-action", data, socket) do
    %{"id" => menu_name, "value-hash" => hash} = data

    # lookup menu item based on selected value hash
    {hash_key, ""} = hash |> Integer.parse()
    {key, value} =
      socket.assigns.values
      |> Map.new(fn {k,v} -> {v |> :erlang.phash2(), {k,v}} end)
      |> Map.get(hash_key)

    # Logger.warning("menu-select-action: #{inspect({key, value}, pretty: true)}")
    {:noreply,
     socket
     |> Actions.handle_event(menu_name, {key, value}, @standard_actions)}
  end

  def key({k, _v}), do: k
  def key(k), do: k
  def value({_k, v}), do: v
  def value(k), do: k
end
