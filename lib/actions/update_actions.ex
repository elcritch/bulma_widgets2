defmodule BulmaWidgets.Action.TriggerUpdates do
  import Phoenix.LiveView
  alias BulmaWidgets.Action
  require Logger

  @moduledoc """
  """
  def call(%Action{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    Logger.debug("BroadcastState:call:opts: #{inspect(opts, pretty: false)}")

    target = opts |> Keyword.get(:id, socket.assigns.id)
    topic = opts |> Keyword.fetch!(:topic)
    fields = opts |> Keyword.get(:values, values) # |> Map.take(set_fields)

    case target do
      %Phoenix.LiveComponent.CID{} = cid ->
        send_update(cid, %{__trigger_update__: {topic, fields} })
      {module, target} ->
        send_update(module, %{id: target, __trigger_update__: {topic, fields} })
    end

    %{evt | socket: socket}
  end

end
