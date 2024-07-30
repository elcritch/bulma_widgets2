defmodule BulmaWidgets.Actions do
  require Logger
  alias BulmaWidgets.EventAction
  alias BulmaWidgets.EventAction.CacheState

  defmacro __using__(opts) do
    pubsub = opts |> Keyword.fetch!(:pubsub)
    IO.puts("ACTIONS:USE: #{inspect(opts)}")

    quote do
      alias BulmaWidgets.Actions

      import BulmaWidgets.Actions,
        only: [assign_cached_topics: 2, assign_cached: 2, assign_sharing: 1, send_topic: 3]

      def register_broadcast(socket, opts) do
        BulmaWidgets.Actions.register_broadcast(
          socket,
          __MODULE__,
          opts ++ [pubsub: unquote(pubsub)]
        )
      end

      def send_topic(socket, opts) do
        send_topic(socket, unquote(pubsub), opts)
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

  def target(assigns) do
    assigns[:target] || assigns[:id]
  end

  defdelegate register_updates(assigns, socket, default \\ []), to: EventAction.BroadcastState

  def assign_cached(socket_or_assigns) do
    assign_cached(socket_or_assigns, [])
  end

  def assign_cached_topics(socket = %Phoenix.LiveView.Socket{}, opts) do
    topics = opts |> Keyword.fetch!(:topics)
    name = opts |> Keyword.get(:into, :shared)
    # use single global cache for now to match broadcast
    view = CacheState

    for topic <- topics, reduce: socket do
      socket ->
        cached = BulmaWidgets.Cache.get(view, topic, %{})
        Logger.debug("action_utils:socket:cached: #{inspect(cached)}")
        socket |> Phoenix.Component.assign(name, cached)
    end
  end

  def assign_cached(assigns, _opts) do
    # Logger.debug("action_utils:cached:assigns: #{inspect(assigns)}")
    # Logger.debug(":action_utils:cached:opts: #{inspect(opts)}")
    actions = assigns |> all_actions([])
    cached_actions = actions |> Keyword.get_values(EventAction.CacheState)
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

  def menu_commands(cmds) do
    [{EventAction.MenuCommands, commands: cmds}]
  end

  def set_values(vals) do
    [
      {EventAction.MenuCommands,
       modify: true,
       commands: fn evt = %EventAction{data: {key, values}} ->
         %{evt | data: {key, values |> Map.merge(vals |> Map.new())}}
       end}
    ]
  end

  def send_topic(topic, pubsub, vals) do
    [
      {EventAction.BroadcastState, topic: topic, values: vals, pubsub: pubsub},
      {EventAction.CacheUpdate, topic: topic, values: vals}
    ]
  end

  def update_shared(topic, pubsub, vals) do
    [
      {EventAction.BroadcastState, topic: topic, values: vals, pubsub: pubsub}
    ]
  end

  def register_broadcast(socket, module, opts) do
    Logger.debug("register_broadcast:socket: #{inspect(socket)}")
    topics = opts |> Keyword.fetch!(:topics)
    pubsub = opts |> Keyword.fetch!(:pubsub)

    standard_actions = [
      {
        EventAction.BroadcastState,
        topics: topics, module: module, pubsub: pubsub
      }
    ]

    EventAction.BroadcastState.register_updates(socket.assigns, socket, standard_actions)
    socket
  end

  def assign_sharing(socket, opts \\ []) do
    name = opts |> Keyword.get(:into, :shared)
    socket = socket |> Phoenix.Component.assign_new(name, fn -> %{} end)
    shared_update = socket |> get_field(:__shared_update__)
    shared = socket |> get_field(name)

    socket =
      case shared_update do
        {_topic, vals} ->
          socket |> Phoenix.Component.assign(name, shared |> Map.merge(vals))

        _ ->
          socket |> Phoenix.Component.assign_new(name, fn -> %{} end)
      end

    socket
  end

  defp get_field(item, name) do
    case item do
      %Phoenix.LiveView.Socket{} = socket ->
          socket.assigns[name]
      assigns ->
          assigns[name]
    end
  end
end
