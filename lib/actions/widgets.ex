defmodule BulmaWidgets.Actions.Widgets do
  require Logger
  alias BulmaWidgets.Action

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
      {Action.BroadcastState, topic: topic, values: values, pubsub: pubsub},
      {Action.CacheUpdate, topic: topic, values: values}
    ]
  end

  def set_action_data(opts) do
    name = opts |> Keyword.fetch!(:into)
    target = opts |> Keyword.fetch!(:to)
    [
      {Action.UpdateHooks,
        to: target,
        hooks: fn evt ->
          socket = evt.socket |> Phoenix.Component.assign(name, evt.data)
          %{evt | socket: socket }
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
      {Action.BroadcastState, topic: topic, values: vals, pubsub: pubsub}
    ]
  end
end
