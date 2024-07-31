
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
