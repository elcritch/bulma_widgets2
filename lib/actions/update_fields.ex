defmodule BulmaWidgets.Action.UpdateFields do
  import Phoenix.LiveView
  alias BulmaWidgets.Action
  require Logger

  @moduledoc """
  """
  def call(%Action{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    Logger.debug("UpdateFields:call:opts: #{inspect(opts, pretty: false)}")

    target = opts |> Keyword.get(:to, socket.assigns.id)
    trigger = opts |> Keyword.fetch!(:trigger)
    values = opts |> Keyword.get(:values, values) # |> Map.take(set_fields)

    Logger.debug("UpdateFields:call:target: #{inspect(target, pretty: false)}")
    msg = %{values: values}
    case target do
      %Phoenix.LiveComponent.CID{} = cid ->
        send_update(cid, %{__trigger_update__: {trigger, msg}})
      {module, target} ->
        send_update(module, %{id: target, __trigger_update__: {trigger, msg}})
    end

    %{evt | socket: socket}
  end


  def run(%{__trigger_update__: {trigger, vals}} = assigns, socket, _opts) do
    assigns = assigns |> Map.delete(:__trigger_update__)

    socket = module.handle_triggers(trigger, vals, assigns, socket)
    {assigns, socket}
  end

  def run(assigns, socket, _opts) do
    {assigns, socket}
  end

end
