defmodule BulmaWidgetsWeb.ExampleSelectionMenuLive do
  use BulmaWidgetsWeb, :live_view

  use BulmaWidgets.Actions, pubsub: BulmaWidgetsWeb.PubSub
  alias BulmaWidgets.Widgets.SelectionMenu

  require Logger

  def mount(_params, _session, socket) do
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
    {:noreply, Actions.update(assigns, socket)}
  end

  def render(assigns) do

    ~H"""
    <div id="widget">
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
    </div>
    """
  end

end
