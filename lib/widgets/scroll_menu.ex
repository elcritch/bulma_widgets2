defmodule BulmaWidgets.Widgets.ScrollMenu do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  alias BulmaWidgets.Action.AssignField

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
    <div id={@id} class={["dropdown", BulmaWidgets.classes(@rest, BulmaWidgets.attrs_atoms())]}
        phx-click={JS.add_class("is-active", to: "##{@id}")}
        phx-click-away={JS.remove_class("is-active", to: "##{@id}")}
    >
      <div class="dropdown-trigger ">
        <button class={["button", BulmaWidgets.classes(@rest, BulmaWidgets.colors_atoms())]} aria-haspopup="true" aria-controls="dropdown-menu">
          <span>
          <%= render_slot(@label, @data) ||
            (key(@data) == nil && render_slot(@default_label, @data)) ||
            key(@data) %>
          </span>
          <span class="icon is-small">
            <i class="fas fa-angle-down" aria-hidden="true"></i>
          </span>
        </button>
      </div>
      <div class="dropdown-menu" role="menu">
        <div class="dropdown-content">
          <%= for {key, value} <- @values do %>
            <a href="#"
              class={"dropdown-item #{key == key(@data) && "is-active" || ""}"}
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
          <% end %>
        </div>
      </div>
    </div>

    """
  end

  def handle_event(
        "menu-select-action",
        %{"id" => menu_name, "key" => key, "value" => _value},
        socket
      ) do
    value = socket.assigns.values |> Map.new() |> Map.get(key)

    socket =
      socket
      |> Actions.handle_event(menu_name, {key, value}, @standard_actions)

    # Logger.debug("scroll_menu:socket: #{inspect(socket, pretty: true)}")
    {:noreply, socket}
  end

  def key({k, _v}), do: k
  def key(k), do: k
  def value({_k, v}), do: v
  def value(k), do: k
end
