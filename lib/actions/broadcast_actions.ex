defmodule BulmaWidgets.Action.BroadcastState do
  import Phoenix.LiveView
  require Logger

  alias BulmaWidgets.Event
  alias BulmaWidgets.Actions
  alias BulmaWidgets.Actions.FieldAssigns

  @broadcast_topic "widget_state"

  @moduledoc """
  Broadcasts state to listeners. Provides hooks for LiveView's
  to handle setting the updated state.
  """
  def call(%Event{data: values, socket: socket} = evt, opts \\ []) do
    Logger.debug("BroadcastState:call:opts: #{inspect(opts, pretty: false)}")

    id = socket.assigns.id
    topic = opts |> Keyword.fetch!(:topic)
    pubsub = opts |> Keyword.fetch!(:pubsub)
    data = opts |> Keyword.get(:values, values)
    Logger.warning("menu-select-action:BroadcastState: #{inspect(values, pretty: true)}")

    if not is_struct(data, FieldAssigns) do
      raise "BroadcastState action expect a map of fields => values to be set! Got: #{inspect(data)}"
    end

    Phoenix.PubSub.broadcast(
      pubsub,
      @broadcast_topic,
      {:broadcast_state, %{id: id, topic: topic, view: socket.view, data: data}}
    )

    %{evt | socket: socket}
  end

  def register_updates(assigns, socket, default \\ []) do
    opts =
      assigns
      |> Actions.all_actions(default)
      |> Keyword.get(BulmaWidgets.Action.BroadcastState, [])

    id = assigns[:id] || assigns[:myself] || self()
    topics = opts |> Keyword.fetch!(:topics)
    module = opts |> Keyword.fetch!(:module)

    send(
      self(),
      {:broadcast_register, %{id: id, topics: topics, module: module, view: socket.view}}
    )
  end

  def on_mount(name, _params, _session, socket) do
    Logger.debug(
      "BroadcastState:on_mount: #{inspect(name)} socket: #{inspect({socket.id, socket.view})}"
    )

    Phoenix.PubSub.subscribe(name, @broadcast_topic)

    {:cont,
     socket |> attach_hook(:widget_state_broadcast, :handle_info, &maybe_receive_broadcast/2)}
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
          listeners = event_action_listeners[topic] || %{}
          {topic, listeners |> Map.put(id, %{module: module, view: view})}
        end
      )

    Logger.debug(
      "BroadcastState:broadcast_register!: #{inspect(event_action_listeners, pretty: false)}"
    )

    {:halt,
     socket
     |> Phoenix.Component.assign(:__event_action_listeners__, event_action_listeners)}
  end

  defp maybe_receive_broadcast(
         {:broadcast_state, vals},
         socket
       ) do
    %{id: id, topic: topic, data: data, view: event_view} = vals

    socket =
      unless event_view != socket.view do
        Logger.debug(
          "BroadcastState:broadcast_state:update: id:#{id} socket:#{socket.id} data:#{inspect(data, pretty: false)}"
        )

        # data = data |> Event.fields_to_assigns()

        target_list =
          (socket.assigns[:__event_action_listeners__] || %{})
          |> Map.get(topic, %{})

        # send updated values to all "listening" id's
        # Logger.debug("BroadcastState:broadcast_state:target_list: #{inspect(target_list, pretty: false)}")
        for {target, args} <- target_list, reduce: socket do
          socket ->
            Logger.debug(
              "BroadcastState:broadcast_state:target: #{inspect([target: target, mod: args.module, data: data |> Map.put(:id, target)], pretty: false)}"
            )

            case target do
              %Phoenix.LiveComponent.CID{} = cid ->
                send_update(cid, %{__shared_update__: {topic, data}})
                socket

              target when is_binary(target) or is_atom(target) ->
                send_update(args.module, %{id: target, __shared_update__: {topic, data}})
                socket

              pid when is_pid(pid) ->
                # send a message `handle_info` to update liveview, to better match components setup
                send(pid, {:updates, %{__shared_update__: {topic, data}}})
                socket

              other ->
                Logger.error("BroadcastState:broadcast_state: unhandle target: #{inspect(other)}")
                socket
            end

            # send_update(args.module, data |> Map.put(:id, "check_sensor"))
        end
      else
        socket
      end

    {:halt, socket}
  end

  defp maybe_receive_broadcast(_other, socket) do
    # Logger.debug("BroadcastState:broadcast_state:skip: other#{inspect(other)} socket:#{socket.id} view:#{socket.view}")
    {:cont, socket}
  end
end
