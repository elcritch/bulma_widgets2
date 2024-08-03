defmodule BulmaWidgetsWeb.ExampleSelectionMenuLive do
  use BulmaWidgetsWeb, :live_view

  use BulmaWidgets.Actions, pubsub: BulmaWidgetsWeb.PubSub
  alias BulmaWidgets.Widgets.ScrollMenu
  alias BulmaWidgets.Widgets.SelectionMenu
  alias BulmaWidgets.Widgets.ActionButton
  alias BulmaWidgets.Action.UpdateHooks

  require Logger

  def mount(_params, _session, socket) do
    # Logger.debug("tab_check_sensor:comp:mount: #{inspect(socket, pretty: true)}")
    {:ok,
     socket
     |> assign(:shared, %{})
     |> assign(:page_title, "Widget Examples")
     |> assign(:menu_items, BulmaWidgetsWeb.MenuUtils.menu_items())
     |> assign(:wiper_options, nil)
    #  |> mount_broadcast(topics: ["test-value-set"])
     |> mount_shared(topics: ["test-value-set"])
    }
  end

  def handle_info({:updates, assigns}, socket) do
    # Logger.debug("WidgetExamplesLive:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:noreply, Actions.update(assigns, socket)}
  end

  def render(assigns) do

    ~H"""
      <.tagged is-link label="Wiper Options:" value={Event.key(@shared[:wiper_options]) }/>

      <.live_component
        module={SelectionMenu}
        id="wiper_options"
        is-fullwidth
        is-info
        label="Wiper Modes"
        data={@shared[:wiper_options]}
        values={[
          {"Regular", 1},
          {"Inverted", -1}
        ]}
        extra_actions={[
          Widgets.send_action_data(
            "test-value-set",
            into: :wiper_options),
        ]}
      >
      </.live_component>

    """
  end

  def handle_event("test", _params, socket) do
    Logger.info("test!")

    {:noreply,
     socket
     |> put_flash!(:info, "It worked!")}
  end
end
