defmodule BulmaWidgets.Action.TriggerUpdates do
  import Phoenix.LiveView
  alias BulmaWidgets.Action
  alias BulmaWidgets.Actions
  require Logger

  @moduledoc """
  """
  def call(%Action{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    Logger.debug("TriggerUpdates:call:opts: #{inspect(opts, pretty: false)}")

    target = opts |> Keyword.get(:to, socket.assigns.id)
    topic = opts |> Keyword.fetch!(:topic)
    trigger = opts |> Keyword.fetch!(:trigger)
    values = opts |> Keyword.get(:values, values) # |> Map.take(set_fields)

    Logger.debug("TriggerUpdates:call:target: #{inspect(target, pretty: false)}")
    msg = %{topic: topic, values: values}
    case target do
      %Phoenix.LiveComponent.CID{} = cid ->
        send_update(cid, %{__trigger_update__: {trigger, msg}})
      {module, target} ->
        send_update(module, %{id: target, __trigger_update__: {trigger, msg}})
    end

    %{evt | socket: socket}
  end

  def handle_triggers(trigger, values, assigns, socket) do
    Logger.debug("TriggerUpdates:handle_triggers:trigger #{inspect(trigger)}")
    Logger.debug("TriggerUpdates:handle_triggers:values #{inspect(values)}")
    socket
  end

  def run_triggers(%{__trigger_update__: {trigger, vals}} = assigns, socket, module, opts) do
    Logger.warning("TriggerUpdates:run_triggers:trigger: #{inspect(trigger, pretty: true)}")
    Logger.debug("TriggerUpdates:run_triggers:assigns: #{inspect(assigns, pretty: true)}")
    Logger.debug("TriggerUpdates:run_triggers:socket: #{inspect(socket, pretty: true)}")
    assigns = assigns |> Map.delete(:__trigger_update__)

    socket = module.handle_triggers(trigger, vals, assigns, socket)
    Logger.debug("TriggerUpdates:run_triggers:socket!: #{inspect(socket, pretty: true)}")
    {assigns, socket}
  end

  def run_triggers(assigns, socket, _module, _opts) do
    {assigns, socket}
  end

end
