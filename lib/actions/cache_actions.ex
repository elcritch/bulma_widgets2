
defmodule BulmaWidgets.Action.CacheState do
  alias BulmaWidgets.Event
  require Logger

  def call(%Event{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, values) |> Event.fields_to_assigns()

    # view = socket.view
    view = BulmaWidgets.Action.CacheState # use single global cache for now to match broadcast

    BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end

defmodule BulmaWidgets.Action.CacheUpdate do
  alias BulmaWidgets.Event
  require Logger

  def call(%Event{data: {key, values}, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, %{key => values}) |> Event.fields_to_assigns()
    view = BulmaWidgets.Action.CacheState # use single global cache for now to match broadcast

    BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end
