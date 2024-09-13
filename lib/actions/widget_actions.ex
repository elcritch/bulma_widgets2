defmodule BulmaWidgets.WidgetActions do
  require Logger
  alias BulmaWidgets.Action.BroadcastState
  alias BulmaWidgets.Action.CacheUpdate
  alias BulmaWidgets.Action.Commands
  alias BulmaWidgets.Action.UpdateHooks
  alias BulmaWidgets.Actions.FieldAssigns

  @doc """
  Creates actions which broadcast and then cache the `vals` to the `topic`.
  Must pass `pubsub` module to use.
  """

  def send_shared(topic, values) do
    pubsub = Application.get_all_env(:bulma_widgets) |> Keyword.fetch!(:pubsub)
    send_shared(topic, pubsub, values)
  end

  def send_shared(topic, pubsub, values) do
    [
      {BroadcastState, topic: topic, values: values, pubsub: pubsub},
      {CacheUpdate, topic: topic, values: values}
    ]
  end

  def send_action_data(topic, opts \\ []) do
    pubsub = Application.get_all_env(:bulma_widgets) |> Keyword.fetch!(:pubsub)
    send_action_data(topic, pubsub, opts)
  end

  @doc """
  Send data from an events's data using broadcast and cached.

  This first sets up fields from the given event data.

  ## Examples

  Set data into field:

      Widgets.send_action_data("test-value-set", into: :value_set)

  Or:

      Widgets.send_action_data("test-value-set", command: fn e ->
        %{e | data: %FieldAssigns{into: "some_name", fields: %{"some_name" => 1}}}
      end)

  """
  def send_action_data(topic, pubsub, opts) do
    broadcast? = opts |> Keyword.get(:broadcast, true)
    cached? = opts |> Keyword.get(:cached, true)

    cmd =
      if opts |> Keyword.get(:command, false) do
        # Logger.debug("send_action_data: command: #{inspect(opts |> Keyword.get(:command, false))} ")
        opts |> Keyword.fetch!(:command)
      else
        name = opts |> Keyword.fetch!(:into)
        # Logger.debug("send_action_data: into: #{inspect name} ")

        fn evt ->
          data = evt.data
          # Logger.debug("send_action_data: run: name: #{inspect(name)} data:#{inspect(data)}")
          %{evt | data: %FieldAssigns{into: name, fields: %{name => data}}}
        end
      end

    [
      {Commands, modify: true, commands: cmd},
      broadcast? && {BroadcastState, topic: topic, pubsub: pubsub} || [],
      cached? && {CacheUpdate, topic: topic} || []
    ]
  end

  @doc """
  Creates an action which runs the given callback command
  """
  def command(cmd) when is_function(cmd) do
    [{Commands, modify: false, commands: [cmd]}]
  end

  @doc """
  Creates an action which runs the given callback command and modifies the return event
  """
  def command!(cmd) when is_function(cmd) do
    [{Commands, modify: true, commands: [cmd]}]
  end

  @doc """
  Assigns data from a `BulmaWidgets.Action` event into the
  given field for the target. The target can be a component
  or liveview.

  By default BulmaWidgets use a `{key, value}` common data
  on menu or widget actions.

  ## Examples

      <.live_component module={ScrollMenu}
        id="wiper_speed"
        values={[{"Slow", 1}, {"Fast", 2}]}
        extra_actions={[
          Widgets.set_action_data(into: :motor_mode, to: self())
        ]}
      >
        <:label :let={{k, _}}>
          Test: <%= k %>
        </:label>
      </.live_component>

  """
  def set_action_data(opts) do
    name = opts |> Keyword.fetch!(:into)
    target = opts |> Keyword.fetch!(:to)

    [
      {UpdateHooks,
       to: target,
       hooks: fn evt ->
         socket = evt.socket |> Phoenix.Component.assign(name, evt.data)
         %{evt | socket: socket}
       end}
    ]
  end

  @doc """
  Creates an action which broadcasts state for the given `topic` to
  an widgets listening (views or components).
  """
  def broadcast_state(topic, vals) do
    pubsub = Application.get_all_env(:bulma_widgets) |> Keyword.fetch!(:pubsub)
    broadcast_state(topic, pubsub, vals)
  end

  def broadcast_state(topic, pubsub, vals) do
    [
      {BroadcastState, topic: topic, values: vals, pubsub: pubsub}
    ]
  end
end
