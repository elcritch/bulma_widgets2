defmodule BulmaWidgetsWeb.WidgetExamplesLive do
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
     |> assign(:wiper_mode, nil)
     |> assign(:wiper_selection, nil)
     |> assign(:wiper_options, nil)
    #  |> mount_broadcast(topics: ["test-value-set"])
     |> mount_shared(topics: ["test-value-set"])
    }
  end

  def handle_info({:updates, assigns}, socket) do
    Logger.debug("WidgetExamplesLive:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:noreply, Actions.update(assigns, socket)}
  end

  def render(assigns) do

    ~H"""
    <.container>
      <.title notification={true} size={3}>Widget Examples</.title>
      <.button phx-click="test" is-fullwidth is-loading={false}>
        Click me
      </.button>

        <p> shared: <%= @shared |> inspect() %> </p>

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

      <.tagged is-link label="Wiper Modes:" value={prettify @wiper_mode}/>
      <br />

      <.live_component
        module={ScrollMenu}
        is-primary
        id="wiper_speed"
        values={[{"Slow", 1}, {"Fast", 2}]}
        extra_actions={[
          #{Event.Commands,
          #commands: fn evt ->
          #  Logger.info("Wiper:hi!!! #{inspect({evt.id, evt.data}, pretty: false)}")
          #  evt
          #end},
          Widgets.set_action_data(into: :wiper_mode, to: self())
        ]}
      >
        <:label :let={{k, _}}>
          Test: <%= k %>
        </:label>
      </.live_component>

      <.live_component
        module={ScrollMenu}
        id="value_set"
        values={[{"A", 1}, {"B", 2}]}
        extra_actions={[
          # broadcast value
          Widgets.send_action_data("test-value-set", into: :value_set),
          #Widgets.send_shared("test-value-set", loading: true),
        ]}
      >
        <:default_label> Example </:default_label>
      </.live_component>

      <.live_component
          id="test-start"
          module={ActionButton}
          is-primary
          extra_actions={
            [
              Widgets.send_shared("test-value-set",
                loading: true
              ),
          ]}
          >
        Start
      </.live_component>

      <.live_component
          id="test-stop"
          module={ActionButton}
          is-primary
          extra_actions={
            [
              Widgets.send_shared("test-value-set",
                loading: false
              ),
          ]}
          >
        Stop
      </.live_component>

      <br>

      <.live_component module={ActionButton} id="test-run" is-fullwidth extra_actions={[]}>
        Click me
      </.live_component>

      <br>
      <.tagged is-link label="Wiper Selection:" value={prettify @wiper_selection}/>

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
        extra_actions={[
          {UpdateHooks,
            to: self(),
            hooks: [
              fn evt ->
                Logger.warning("wiper_mode:selection:update: #{inspect(evt, pretty: true)} ")
                %{evt | socket: evt.socket |> assign(:wiper_selection, evt.data)}
              end
            ]
          }
        ]}
      >
      </.live_component>

      <br />

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
          Widgets.send_action_data("test-value-set", into: :wiper_options),
        ]}
      >
      </.live_component>

      <br />

      event_action_listeners:
      <pre>
      <%= inspect(assigns[:__event_action_listeners__], pretty: true) %>
      </pre>
    </.container>
    """
  end

  def handle_event("test", _params, socket) do
    Logger.info("test!")

    {:noreply,
     socket
     |> put_flash!(:info, "It worked!")}
  end
end
