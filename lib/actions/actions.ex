defmodule BulmaWidgets.Actions do
  require Logger
  alias BulmaWidgets.Action

  defmacro __using__(opts) do
    pubsub = opts |> Keyword.fetch!(:pubsub)
    IO.puts("ACTIONS:USE: #{inspect(opts)}")

    quote do
      alias BulmaWidgets.Actions

      import BulmaWidgets.Actions,
        only: [
          assign_cached_topics: 2,
          assign_cached: 2,
          assign_sharing: 1,
          event_send: 3,
          event_commands: 2,
          event_commands: 1
        ]

      def mount_broadcast(socket, opts) do
        BulmaWidgets.Actions.mount_broadcast(
          socket,
          __MODULE__,
          opts ++ [pubsub: unquote(pubsub)]
        )
      end

      def event_send(socket, opts) do
        event_send(socket, unquote(pubsub), opts)
      end

      def mount_shared(socket, opts) do
        topics = opts |> Keyword.fetch!(:topics)

        socket
        |> mount_broadcast(opts)
        |> assign_cached_topics(opts)
      end
    end
  end

  def all_actions(assigns, defaults \\ []) do
    assigns =
      case assigns do
        %Phoenix.LiveView.Socket{} = socket ->
          socket.assigns

        assigns ->
          assigns
      end

    standard = assigns |> Map.get(:standard_actions, defaults)
    extra = assigns |> Map.get(:extra_actions, [])
    List.flatten(standard ++ extra)
  end

  defdelegate register_updates(assigns, socket, default \\ []), to: Action.BroadcastState

  def assign_cached(socket_or_assigns) do
    assign_cached(socket_or_assigns, [])
  end

  def assign_cached(assigns, _opts) do
    # Logger.debug("action_utils:cached:assigns: #{inspect(assigns)}")
    # Logger.debug(":action_utils:cached:opts: #{inspect(opts)}")
    actions = assigns |> all_actions([])
    cached_actions = actions |> Keyword.get_values(Action.CacheState)
    # Logger.debug("action_utils:cached:cached_actions: #{inspect(cached_actions)}")

    for cache_action <- cached_actions, reduce: assigns do
      assigns ->
        topic = cache_action |> Keyword.fetch!(:topic)
        name = cache_action |> Keyword.get(:into, :shared)
        cached = BulmaWidgets.Cache.get(assigns.rest.socket.view, topic, %{})

        Logger.debug(
          "action_utils: id: #{assigns.id} cache: #{inspect(cache_action)} name: #{name} cached: #{inspect(cached)}"
        )

        assigns |> Phoenix.Component.assign(name, cached)
    end
  end

  @doc """
  Assigns cached items into a give name.

  ## Examples

      iex> BulmaWidgets.Cache.start_link([])
      iex> socket = %Phoenix.LiveView.Socket{}
      iex> BulmaWidgets.Actions.assign_cached_topics(socket, into: :shared, topics: ["topic"])
      ...> |> Map.get(:assigns)
      %{shared: %{}, __changed__: %{shared: true}}

  """
  def assign_cached_topics(socket = %Phoenix.LiveView.Socket{}, opts) do
    topics = opts |> Keyword.fetch!(:topics)
    name = opts |> Keyword.get(:into, :shared)
    # use single global cache for now to match broadcast
    view = Action.CacheState

    for topic <- topics, reduce: socket do
      socket ->
        cached = BulmaWidgets.Cache.get(view, topic, %{})
        Logger.debug("action_utils:socket:cached: #{inspect(cached)}")
        socket |> Phoenix.Component.assign(name, cached)
    end
  end

  @doc """
  Sets up the given LiveView/LiveComponent to handle default set
  of widget actions. Includes cached topics (`CacheState`), and
  broadcast shared topics (`BroadcastState`). It runs update hooks
  (`UpdateHooks`) action.
  """
  def updates(assigns, socket, _module, opts \\ []) do

    # {assigns, socket} = Action.TriggerUpdates.run_triggers(assigns, socket, module, opts)

    socket =
      socket
      |> Phoenix.Component.assign(assigns)
      |> BulmaWidgets.Actions.assign_cached()
      |> BulmaWidgets.Actions.assign_sharing()

    {_assigns, socket} = Action.UpdateHooks.run_hooks(assigns, socket, opts)

    socket
  end


  def event_commands(cmds, modify \\ false) do
    [{Action.Commands, modify: modify, commands: cmds}]
  end

  def set_values(vals) do
    [
      {Action.Commands,
       modify: true,
       commands: fn evt = %Action{data: {key, values}} ->
         %{evt | data: {key, values |> Map.merge(vals |> Map.new())}}
       end}
    ]
  end

  def event_send(topic, pubsub, vals) do
    [
      {Action.BroadcastState, topic: topic, values: vals, pubsub: pubsub},
      {Action.CacheUpdate, topic: topic, values: vals}
    ]
  end

  def event_broadcast_state(topic, pubsub, vals) do
    [
      {Action.BroadcastState, topic: topic, values: vals, pubsub: pubsub}
    ]
  end

  def mount_broadcast(socket, module, opts) do
    Logger.debug("mount_broadcast:socket: #{inspect(socket)}")
    topics = opts |> Keyword.fetch!(:topics)
    pubsub = opts |> Keyword.fetch!(:pubsub)

    standard_actions = [
      {
        Action.BroadcastState,
        topics: topics, module: module, pubsub: pubsub
      }
    ]

    Action.BroadcastState.register_updates(socket.assigns, socket, standard_actions)
    socket
  end

  def assign_sharing(socket, opts \\ []) do
    name = opts |> Keyword.get(:into, :shared)
    socket = socket |> Phoenix.Component.assign_new(name, fn -> %{} end)
    shared_update = socket |> get_assigned(:__shared_update__)
    shared_values = socket |> get_assigned(name)

    socket =
      case shared_update do
        {_topic, vals} ->
          socket |> Phoenix.Component.assign(name, shared_values |> Map.merge(vals))

        _ ->
          socket |> Phoenix.Component.assign_new(name, fn -> %{} end)
      end

    socket
  end

  defp get_assigned(item, name) do
    case item do
      %Phoenix.LiveView.Socket{} = socket ->
        socket.assigns[name]

      assigns ->
        assigns[name]
    end
  end
end
