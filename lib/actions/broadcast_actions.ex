
defmodule BulmaWidgets.Action.BroadcastEvent do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
  Broadcasts an :info event to all listeners
  """
  def call(%Action{socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.fetch!(:topic)
    with_id = opts |> Keyword.get(:id, false)
    topic = "#{topic}#{(with_id && socket.assigns.id) || ""}"
    pubsub = opts |> Keyword.fetch!(:pubsub)
    Phoenix.PubSub.broadcast(pubsub, topic, {topic, %{evt | socket: nil}})

    %{evt | socket: socket}
  end
end

defmodule BulmaWidgets.Action.BroadcastState do
  alias BulmaWidgets.Action
  alias BulmaWidgets.Actions
  require Logger
  import Phoenix.LiveView

  @broadcast_topic "widget_state"

  @moduledoc """
  Broadcasts state to listeners. Provides hooks for LiveView's
  to handle setting the updated state.
  """
  def call(%Action{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    Logger.debug("BroadcastState:call:opts: #{inspect(opts, pretty: false)}")

    id = socket.assigns.id
    topic = opts |> Keyword.fetch!(:topic)
    pubsub = opts |> Keyword.fetch!(:pubsub)
    fields = opts |> Keyword.get(:values, values) # |> Map.take(set_fields)

    Phoenix.PubSub.broadcast(
      pubsub,
      @broadcast_topic,
      {:broadcast_state,
        %{id: id, topic: topic, view: socket.view, fields: fields}}
    )

    %{evt | socket: socket}
  end

  def register_updates(assigns, socket, default \\ []) do
    opts = assigns |> Actions.all_actions(default) |> Keyword.get(Action.BroadcastState, [])
    id = assigns[:id] || assigns[:myself] || socket.id
    topics = opts |> Keyword.fetch!(:topics)
    module = opts |> Keyword.fetch!(:module)

    Logger.debug("BroadcastState:broadcast_register:register_updates: id:#{inspect id} topics:#{topics}")
    send(self(), {:broadcast_register, %{id: id, topics: topics, module: module, view: socket.view}})
  end

  def on_mount(name, _params, _session, socket) do
    Phoenix.PubSub.subscribe(name, @broadcast_topic)

    {:cont,
      socket |> attach_hook(:broadcast_widget_state, :handle_info, &maybe_receive_broadcast/2)}
  end

  defp maybe_receive_broadcast({:broadcast_register, args}, socket) do
    %{id: id, topics: topics, module: module, view: view} = args
    event_action_listeners = socket.assigns[:__event_action_listeners__] || %{}

    Logger.debug("BroadcastState:broadcast_register:id: #{inspect(args, pretty: false)}")
    # %{"check-sensor-run" => %{check_sensor: true}}
    event_action_listeners =
      event_action_listeners
      |> Map.merge(
      for topic <- topics, into: %{} do
        listeners = (event_action_listeners[topic] || %{})
        {topic, listeners |> Map.put(id, %{module: module, view: view})}
      end)

    Logger.debug("BroadcastState:broadcast_register!: #{inspect(event_action_listeners, pretty: false)}")

    {:halt,
      socket
      |> Phoenix.Component.assign(:__event_action_listeners__, event_action_listeners)}
  end

  defp maybe_receive_broadcast({:broadcast_state, %{view: evt_view}}, %{view: view} = socket)
        when evt_view != view do
    Logger.debug("BroadcastState:skip: #{inspect({evt_view, view}, pretty: false)}")

    {:cont, socket}
  end

  defp maybe_receive_broadcast(
          {:broadcast_state, vals},
          socket
        ) do
    %{id: id, topic: topic, fields: fields} = vals
    Logger.debug("BroadcastState:broadcast_state:update: id:#{id} socket:#{socket.id} vals:#{inspect(vals, pretty: false)}")
    fields = fields |> Action.fields_to_assigns()

    target_list =
      socket.assigns[:__event_action_listeners__]
      |> Map.get(topic, %{})

    # send updated values to all "listening" id's
    # Logger.debug("BroadcastState:broadcast_state:target_list: #{inspect(target_list, pretty: false)}")
    for {target, args} <- target_list do
      # Logger.debug("BroadcastState:broadcast_state:target: #{inspect([target: target, mod: args.module, fields: fields |> Map.put(:id, target)], pretty: false)}")

      case target do
        %Phoenix.LiveComponent.CID{} = cid ->
          send_update(cid, %{__shared_update__: {topic, fields} })
        target ->
          send_update(args.module, %{id: target, __shared_update__: {topic, fields} })
      end
      # send_update(args.module, fields |> Map.put(:id, "check_sensor"))
    end

    # send_update(module, fields |> Map.put(:id, id))
    {:halt, socket}
  end

  defp maybe_receive_broadcast(_, socket) do
    {:cont, socket}
  end
end
