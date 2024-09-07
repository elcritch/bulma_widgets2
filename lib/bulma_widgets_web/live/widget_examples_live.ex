defmodule BulmaWidgetsWeb.WidgetExamplesLive do
  alias Phoenix.Component
  use BulmaWidgetsWeb, :live_view

  use BulmaWidgets.Actions, pubsub: BulmaWidgetsWeb.PubSub
  alias BulmaWidgets.Widgets.ScrollMenu
  alias BulmaWidgets.Widgets.SelectionMenu
  alias BulmaWidgets.Widgets.ActionButton
  alias BulmaWidgets.Widgets.TabView
  alias BulmaWidgets.Widgets.VertTabView
  alias BulmaWidgets.Widgets.Switch
  alias BulmaWidgets.Widgets.DigitPicker
  alias BulmaWidgets.Action.UpdateHooks

  require Logger

  def mount(_params, _session, socket) do
    # Logger.debug("tab_check_sensor:comp:mount: #{inspect(socket, pretty: true)}")
    # Logger.debug("WidgetExamplesLive:mount:params: #{inspect(get_connect_params(socket), pretty: true)}")
    params = get_connect_params(socket)
    theme = params["bulma_theme"] || "light"
    Logger.warning("widget:setting bulma theme: #{inspect(theme)}")

    {:ok,
     socket
     |> assign(:shared, %{})
     |> assign(:page_title, "Widget Examples")
     |> assign(:menu_items, BulmaWidgetsWeb.MenuUtils.menu_items())
     |> assign(:wiper_mode, nil)
     |> assign(:wiper_selection, nil)
     |> assign(:wiper_options, nil)
     #  |> mount_broadcast(topics: ["test-value-set"])
     |> mount_shared(topics: ["test-value-set"])}
  end

  def handle_info({:updates, assigns}, socket) do
    Logger.debug("WidgetExamplesLive:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:noreply, Actions.update(assigns, socket)}
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <.container>
      <.title notification={true} size={3}>Widget Examples</.title>

      <.title size={5} dashed>Digit Picker</.title>
      <.live_component
        module={DigitPicker}
        id="digit_test"
        value={51414}
        digits={{4,3,true}}
        extra_actions={[
          WidgetActions.send_action_data("test-value-set", into: :switch_test)
        ]}
      >
      </.live_component>

      <.title size={5} dashed>Examples of using buttons</.title>

      <.button
        phx-click={
          JS.add_class("is-active", to: "#my-modal")
          # |> JS.remove_class("is-active", transition: "testing", time: 2_000, to: "#my-modal")
        }
        is-fullwidth
        is-loading={false}
      >
        Modal Test
      </.button>

      <.button phx-click="test" is-fullwidth is-loading={false}>
        Flash Test
      </.button>
      <.button phx-click="test-break" is-fullwidth is-loading={false}>
        Test Break
      </.button>

      <p>shared: <%= @shared |> inspect() %></p>

      <.title size={4} dashed>Switch Examples</.title>

      <p>One way binding:</p>
      <.switch checked={@shared[:switch_test]} />
      <br />

      <p>Two way binding:</p>
      <.live_component
        module={Switch}
        id="switch_test"
        extra_actions={[
          WidgetActions.send_action_data("test-value-set", into: :switch_test)
        ]}
      >
        <:label when={true}>On</:label>
        <:label when={false}>Off</:label>
      </.live_component>

      <.live_component
        module={ScrollMenu}
        id="wiper_mode_test"
        is-fullwidth
        is-info
        values={[{1, "Regular"}, {-1, "Inverted"}]}
      >
        <:label :let={sel}>
          Test: <%= Event.val(sel) %>
        </:label>
      </.live_component>

      <br />

      <.tagged is-link label="Wiper Modes:" value={prettify(@wiper_mode)} />
      <br />

      <.live_component
        module={ScrollMenu}
        is-primary
        id="wiper_speed"
        values={[{1, "Slow"}, {2, "Fast"}]}
        extra_actions={
          [
            # {Event.Commands,
            # commands: fn evt ->
            #  Logger.info("Wiper:hi!!! #{inspect({evt.id, evt.data}, pretty: false)}")
            #  evt
            # end},
            WidgetActions.set_action_data(into: :wiper_mode, to: self())
          ]
        }
      >
        <:label :let={sel}>
          Test: <%= Event.val(sel) %>
        </:label>
      </.live_component>

      <.live_component
        module={ScrollMenu}
        id="value_set"
        values={[{:a, "A"}, {:b, "B"}]}
        data={@shared[:value_set]}
        extra_actions={
          [
            # broadcast value
            WidgetActions.send_action_data("test-value-set", into: :value_set)
            # Widgets.send_shared("test-value-set", loading: true),
          ]
        }
      >
        <:default_label>Example</:default_label>
        <:label :let={sel}>
          <%= Event.val(sel, "Example") %>
        </:label>
      </.live_component>

      <.live_component
        id="test-start"
        module={ActionButton}
        is-primary
        extra_actions={[
          WidgetActions.send_shared("test-value-set",
            loading: true
          )
        ]}
      >
        Start
      </.live_component>

      <.live_component
        id="test-stop"
        module={ActionButton}
        is-primary
        extra_actions={[
          WidgetActions.send_shared("test-value-set",
            loading: false
          )
        ]}
      >
        Stop
      </.live_component>

      <br />

      <.live_component module={ActionButton} id="test-run" is-fullwidth extra_actions={[]}>
        Click me
      </.live_component>

      <br />
      <.title size={4}>Dropdown Component Test</.title>
      <.dropdown id="dropdown-test-1">
        <:label :let={sel}><%= Event.val(sel, "Dropdown") %></:label>
        <:label_icon base="fas" name="fa-angle-down" />

        <:value key={:a}>Option A</:value>
        <:value key={:b}>Option B</:value>
      </.dropdown>

      <.dropdown id="dropdown-test-2" selected={:a}>
        <:label :let={sel}><%= Event.val(sel, "Dropdown") %></:label>
        <:label_icon base="fas" name="fa-angle-down" />

        <:value key={:a}>Option A</:value>
        <:value key={:b}>Option B</:value>
      </.dropdown>

      <.dropdown id="dropdown-test-3" selected={1} values={[{1, "A"}, {2, "B"}]} selected={2}>
        <:label :let={sel}>Option <%= Event.val(sel, "Dropdown") %></:label>
        <:label_icon base="fas" name="fa-angle-down" />

        <:items :let={%{key: key, label: label, selected: selected}}>
          <a class={["dropdown-item", (selected && "is-active") || ""]} phx-value-id={key}>
            Custom: <%= label %>
          </a>
        </:items>
      </.dropdown>

      <br />
      <.title size={4}>Non-shared local only Dropdown</.title>
      <.tagged is-link label="Wiper Selection:" value={prettify(@wiper_selection)} />

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
           ]}
        ]}
      >
      </.live_component>

      <br />

      <.title size={4}>Shared and Cached Dropdown</.title>
      <.tagged is-link label="Wiper Options:" value={Event.key(@shared[:wiper_options])} />

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
          WidgetActions.send_action_data("test-value-set", into: :wiper_options)
        ]}
      >
      </.live_component>

      <br />

      <.title size={4}>Example Tabs</.title>
      <br />

      <.live_component module={TabView} id="example_tabs" default_tab="tab1" is-boxed>
        <:tab name="Tab 1" key="tab1">
          <.tab_one />
        </:tab>
        <:tab name="Tab 2" key="tab2">
          <.tab_two />
        </:tab>
      </.live_component>

      <br />
      <.live_component
        module={VertTabView}
        id="example_vert_tabs"
        default_tab="tab2"
        is-boxed
        min_menu_width="7em"
        min_menu_height="20em"
      >
        <:tab name="Tab 1" key="tab1">
          <.tab_one />
        </:tab>
        <:tab name="Tab 2" key="tab2">
          <.tab_two />
        </:tab>
        <:tab name="Tab 3" key="tab3">
          <.tab_three />
        </:tab>
      </.live_component>

      <.message is-warning>
        <:header>
          <p>Hello World</p>
          <button
            class="delete"
            phx-click={JS.remove_class("is-active", to: "#my-modal")}
            aria-label="delete"
          >
          </button>
        </:header>
        <:body>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. <strong>Pellentesque risus mi</strong>, tempus quis placerat ut, porta nec
        </:body>
      </.message>

      <.modal id="my-modal" modal-fx-fadeInScale position="bottom">
        <%!-- <:background /> --%>
        <:content>
          <.message is-warning>
            <:header>
              <p>Hello World</p>
              <button
                class="delete"
                phx-click={JS.remove_class("is-active", to: "#my-modal")}
                aria-label="delete"
              >
              </button>
            </:header>
            <:body>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. <strong>Pellentesque risus mi</strong>, tempus quis placerat ut, porta nec
            </:body>
          </.message>
          <br />
        </:content>
      </.modal>

      <br /><br /><br />
    </.container>
    """
  end

  def handle_event("test", params, socket) do
    Logger.info("test! params: #{inspect(params)}")

    {:noreply,
     socket
     |> put_flash(:info, "It worked!")
     |> put_flash(:info, "It really worked!")
     |> put_flash(:danger, "It broke!")}
  end

  def handle_event("test-break", params, socket) do
    Logger.info("test! params: #{{1, 2, 3}}")

    {:noreply,
     socket
     |> put_flash(:info, "It worked!")
     |> put_flash(:danger, "It broke!")}
  end

  def tab_one(assigns) do
    ~H"""
    <.box>
      <p>First view</p>
    </.box>
    """
  end

  def tab_two(assigns) do
    ~H"""
    <.box>
      <p>Second view</p>
    </.box>
    """
  end

  def tab_three(assigns) do
    ~H"""
    <.box>
      <p>Third view</p>
      <br />
      <br />
      <br />
      <br />
    </.box>
    """
  end
end
