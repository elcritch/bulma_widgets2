
defmodule BulmaWidgets.Action.CacheState do
  alias BulmaWidgets.Action
  require Logger

  def call(%Action{data: {key, values}, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, values) |> Action.fields_to_assigns()

    # view = socket.view
    view = BulmaWidgets.Action.CacheState # use single global cache for now to match broadcast

    BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end

defmodule BulmaWidgets.Action.CacheUpdate do
  alias BulmaWidgets.Action
  require Logger

  def call(%Action{data: {key, values}, socket: socket} = evt, opts \\ []) do
    topic = opts |> Keyword.get(:topic, [])
    values = opts |> Keyword.get(:values, %{key => values}) |> Action.fields_to_assigns()
    view = BulmaWidgets.Action.CacheState # use single global cache for now to match broadcast

    BulmaWidgets.Cache.put_all(view, topic, values)

    %{evt | socket: socket}
  end
end
