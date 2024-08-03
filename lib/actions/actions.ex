defmodule BulmaWidgets.Actions do
  require Logger
  alias BulmaWidgets.Event
  alias BulmaWidgets.Action

  @moduledoc """
  Example usage: `use BulmaWidgets.Actions, pubsub: MyApp.PubSub1`


  ## Examples

  ### Using with LiveViews

  #### Listening to BroadcastState updates

      defmodule LwControlWeb.WidgetExamplesLive do
        use LwControlWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok,
            socket
            |> mount_broadcast(topics: ["test-value-set"], into: shared)
        end

        ...

        def handle_info({:updates, assigns}, socket) do
          {:noreply, Actions.update(assigns, socket)}
        end
      end

  #### Listening to Broadcast and Cached Values

      defmodule LwControlWeb.WidgetExamplesLive do
        use LwControlWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok,
            socket
            |> mount_shared(topics: ["test-value-set"])
        end

        ...

        def handle_info({:updates, assigns}, socket) do
          {:noreply, Actions.update(assigns, socket)}
        end
      end

  ### Using with LiveComponents

  #### Listening to Broadcast and Cached Values

      defmodule LwControlWeb.WidgetExamplesLive do
        use LwControlWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok,
            socket
            |> mount_shared(topics: ["test-value-set"])
        end

        def update(assigns, socket) do
          {:ok, socket |> Actions.update(assigns, socket)}
        end

        ...

      end

  """

  defmacro __using__(opts) do
    pubsub = opts |> Keyword.fetch!(:pubsub)
    IO.puts("ACTIONS:USE: #{inspect(opts)}")

    quote do
      alias BulmaWidgets.Actions
      alias BulmaWidgets.Actions.Widgets

      import BulmaWidgets.Actions,
        only: [
          mount_cached: 2,
          assign_cached: 2,
          assign_sharing: 1,
          event_commands: 2,
          event_commands: 1
        ]

      @doc """
      Use in a component's `mount` to register the component to review
      updates for a given `topics`.
      """
      def mount_broadcast(socket, opts) do
        BulmaWidgets.Actions.mount_broadcast(
          socket,
          __MODULE__,
          opts ++ [pubsub: unquote(pubsub)]
        )
      end

      @doc """
      Sets up a components mount to use broadcast state and cached state
      actions. This includes registering for broadcast events and
      setting any currently cached topics.
      """
      def mount_shared(socket, opts) do
        topics = opts |> Keyword.fetch!(:topics)

        socket
        |> mount_broadcast(opts)
        |> mount_cached(opts)
      end
    end
  end

  @doc """
  Gets all actions defined in a components `standard_actions` or
  `extra_actions` attributes.
  Works with both sockets or assign maps.
  """
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

  @doc """
  Sets up the given LiveView/LiveComponent to handle default set
  of widget actions. Includes cached topics (`CacheState`), and
  broadcast shared topics (`BroadcastState`). It runs update hooks
  (`UpdateHooks`) action.

  By default this also merges assigns into the socket,
  but pass `no_merge: true` to skip this.
  """
  def update(assigns, socket, opts \\ []) do
    # {assigns, socket} = Action.UpdateFields.run(assigns, socket, opts)

    socket =
      unless true == opts |> Keyword.get(:no_merge) do
        socket |> Phoenix.Component.assign(assigns)
      else
        socket
      end

    socket =
      socket
      |> BulmaWidgets.Actions.assign_cached()
      |> BulmaWidgets.Actions.assign_sharing()

    {_assigns, socket} = Action.UpdateHooks.run_hooks(assigns, socket, opts)

    socket
  end

  defdelegate register_updates(assigns, socket, default \\ []), to: Action.BroadcastState

  def assign_cached(socket_or_assigns) do
    assign_cached(socket_or_assigns, [])
  end

  @spec assign_cached(map(), any()) :: any()
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
      iex> BulmaWidgets.Cache.put(BulmaWidgets.Action.CacheState, "test-topic", %{"a" => 1})
      iex> socket = %Phoenix.LiveView.Socket{}
      iex> BulmaWidgets.Actions.mount_cached(socket,
      ...>     into: :shared, topics: ["test-topic"]
      ...> ) |> Map.get(:assigns)
      %{shared: %{"a" => 1}, __changed__: %{shared: true}}

  """
  def mount_cached(socket = %Phoenix.LiveView.Socket{}, opts) do
    topics = opts |> Keyword.fetch!(:topics)
    name = opts |> Keyword.get(:into, :shared)
    # use single global cache for now to match broadcast
    view = BulmaWidgets.Action.CacheState

    Logger.debug("actions:mount_cached:socket:view: #{inspect(view)}")

    for topic <- topics, reduce: socket do
      socket ->
        cached = BulmaWidgets.Cache.get(view, topic, %{})
        Logger.debug("actions:mount_cached:cached: #{inspect(cached)}")
        socket |> Phoenix.Component.assign(name, cached)
    end
  end

  @doc """
  Creates an action which runs the closures given as a list in `cmds`.
  """
  def event_commands(cmds, modify \\ false) do
    [{Action.Commands, modify: modify, commands: cmds}]
  end

  @doc """
  Creates an action that directly merges `vals` into the
  widgets assigns after and action.
  """
  def event_set_values(vals) do
    [
      {Action.Commands,
       modify: true,
       commands: fn evt = %Event{data: {key, values}} ->
         %{evt | data: {key, values |> Map.merge(vals |> Map.new())}}
       end}
    ]
  end



  @doc """
  Use in a component's `mount` to register the component to review
  updates for a given `topics`. Must provide `module` of the component.
  """
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

  @doc """
  Use in a component's `mount` to register the component to review
  updates for a given `topics`. Must provide `module` of the component.
  """
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

  def handle_event(socket, name, {key, value}, default_actions) do
    actions = socket.assigns |> all_actions(default_actions)

    event_action =
      %Event{
        id: name,
        data: {key, value},
        assigns: socket.assigns,
        socket: socket
      }
      |> Event.apply(actions)

    event_action.socket
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
