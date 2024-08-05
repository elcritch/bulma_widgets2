
defmodule BulmaWidgets.Action.CacheState do
  alias BulmaWidgets.Event
  require Logger

  def call(%Event{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, values) |> Event.fields_to_assigns()

    # view = socket.view
    view = BulmaWidgets.Action.CacheState # use single global cache for now to match broadcast

    # BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end

defmodule BulmaWidgets.Action.CacheUpdate do
  alias BulmaWidgets.Event
  require Logger
  alias BulmaWidgets.Actions.FieldAssigns

  def call(%Event{id: id, data: values, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, values) # |> Event.fields_to_assigns()
    view = BulmaWidgets.Action.CacheState # use single global cache for now to match broadcast

    if not is_struct(values, FieldAssigns) do
      raise "BroadcastState action expects a FieldAssigns struct, Id:#{inspect(id)} Options: #{inspect(opts)} Data: #{inspect(values)}"
    end

    %{fields: values} = values

    BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end
