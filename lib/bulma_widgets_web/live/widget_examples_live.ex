defmodule BulmaWidgetsWeb.WidgetExamplesLive do
  use BulmaWidgetsWeb, :live_view

  use BulmaWidgets.Actions, pubsub: BulmaWidgetsWeb.PubSub
  alias BulmaWidgets.Widgets.ScrollMenu
  alias BulmaWidgets.Widgets.ActionButton

  require Logger

  def render(assigns) do
    assigns = assigns |> assign_sharing()

    ~H"""
    <.button phx-click="test" is-fullwidth is-loading={false}>
      Click me
    </.button>

      <p>
        shared: <%= @shared |> inspect() %>
      </p>

    <.live_component
      module={ScrollMenu}
      id={:wiper_mode}
      is-fullwidth
      is-info
      values={[{"Regular", 1}, {"Inverted", -1}]}
    >
      <:label :let={{k, _}}>
        Test: <%= k %>
      </:label>
    </.live_component>

    <br />
    <.live_component
      module={ScrollMenu}
      is-primary
      id={:wiper_speed}
      values={[{"Slow", 1}, {"Fast", 2}]}
      extra_actions={[
        {Action.Commands,
         commands: fn evt ->
           Logger.info("HI: #{inspect(evt)}!!!")
           evt
         end}
      ]}
    >
      <:label :let={{k, _}}>
        Test: <%= k %>
      </:label>
    </.live_component>

    <.live_component
      module={ScrollMenu}
      id={:value_set}
      values={[{"A", 1}, {"B", 2}]}
      extra_actions={[
        Widgets.send_shared("test:#{:value_set}",
              loading: false
        )
      ]}
    >
      <:default_label>
        Example
      </:default_label>
    </.live_component>

    <.live_component module={ActionButton} id="test-run" is-fullwidth extra_actions={[]}>
      Click me
    </.live_component>

    <br />
    """
  end

  def mount(_params, _session, socket) do
    # Logger.debug("tab_check_sensor:comp:mount: #{inspect(socket, pretty: true)}")
    {:ok,
     socket
     |> assign(:page_title, "Widget Examples")
     |> assign(:menu_items, BulmaWidgetsWeb.MenuUtils.menu_items())
     |> mount_broadcast(topics: ["check-sensor-state"])}
  end

  def handle_event("test", _params, socket) do
    Logger.info("test!")

    {:noreply,
     socket
     |> put_flash!(:info, "It worked!")}
  end
end
