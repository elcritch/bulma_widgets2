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

end
