
defmodule BulmaWidgets.Action.Commands do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
    Apply a function with event data, or a list of functions:

        extra_actions={[
          {Action.Commands, commands: fn x -> Logger.info("HI: \#{inspect x}!!!") end}
        ]}
        extra_actions={[
          {Action.Commands, commands: [fn x -> Logger.info("HI: \#{inspect x}!!!") end]}
        ]}
  """
  def call(%Action{} = evt, opts) do
    modify? = opts |> Keyword.get(:modify, false)

    commands =
      case opts |> Keyword.get(:commands, []) do
        f when is_function(f, 1) -> [f]
        l when is_list(l) -> l
        _ -> []
      end

    # Logger.debug("Action:Commands: opts: #{inspect(opts)} ")
    # Logger.debug("Action:Commands: state: #{inspect(commands)} ")
    evt! =
      for cmd <- commands, reduce: evt do
        evt ->
          res = cmd.(evt)

          if modify? do
            res
          else
            evt
          end
      end
    evt!
  end
end

defmodule BulmaWidgets.Action.AssignField do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
    Updates the widgets state,
    note: circumvents the normal event pattern. Still turns out pretty handy.
  """
  def call(%Action{data: data, socket: socket} = evt, opts) do
    field = opts |> Keyword.fetch!(:field)
    %{evt | socket: Phoenix.LiveView.Utils.assign(socket, field, data)}
  end
end

defmodule BulmaWidgets.Action.CastMenuEvent do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
  """
  def call(%Action{socket: socket} = evt, opts \\ []) do
    event_name = opts |> Keyword.get(:event_name, :menu_event)
    Process.send(self(), {event_name, evt, opts}, [])

    %{evt | socket: socket}
  end
end

defmodule BulmaWidgets.Action.BroadcastEvent do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
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

    # Logger.debug("BroadcastState:broadcast_register:socket: #{inspect(socket)}")
    # Logger.debug("BroadcastState:broadcast_register:assigns: #{inspect(assigns)}")
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

defmodule BulmaWidgets.Action.CacheState do
  alias BulmaWidgets.Action
  require Logger

  def call(%Action{data: {_target, values}, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, values) |> Action.fields_to_assigns()
    # view = socket.view
    view = CacheState # use single global cache for now to match broadcast

    BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end

defmodule BulmaWidgets.Action.CacheUpdate do
  alias BulmaWidgets.Action
  require Logger

  def call(%Action{data: {_target, values}, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, values) |> Action.fields_to_assigns()
    view = CacheState # use single global cache for now to match broadcast

    BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end
