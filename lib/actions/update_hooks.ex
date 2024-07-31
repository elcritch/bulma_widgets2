defmodule BulmaWidgets.Action.UpdateHooks do
  import Phoenix.LiveView
  alias BulmaWidgets.Action
  require Logger

  @moduledoc """
  """
  def call(%Action{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    Logger.debug("UpdateHooks:call:opts: #{inspect(opts, pretty: false)}")

    target = opts |> Keyword.get(:to, socket.assigns.id)
    hooks = opts |> Keyword.fetch!(:hooks) |> List.flatten()
    # values = opts |> Keyword.get(:values, values) # |> Map.take(set_fields)

    Logger.debug("UpdateHooks:call:target: #{inspect(target, pretty: false)}")
    msg = %{hooks: hooks, values: values}
    case target do
      %Phoenix.LiveComponent.CID{} = cid ->
        send_update(cid, %{__trigger_hooks__: msg})
      {module, target} ->
        send_update(module, %{id: target, __trigger_hooks__: msg})
    end

    %{evt | socket: socket}
  end


  def run_hooks(%{__trigger_hooks__: %{hooks: hooks, values: _vals}} = assigns, socket, opts) do
    assigns = assigns |> Map.delete(:__trigger_hooks__)

    # socket = module.handle_triggers(hooks, vals, assigns, socket)
    for hook <- hooks, reduce: socket do
      socket ->
        case hook do
          fun when is_function(fun, 2) ->
            fun.(assigns, socket)
          fun when is_function(fun, 0) ->
            fun.()
            socket
          {:start_async, name, fun} when is_function(fun, 0) ->
            socket
            |> Phoenix.LiveView.start_async(name, fun)
          hook ->
            Logger.error("invalid trigger hook callback: #{inspect(hook)}")
            socket
        end
    end

    {assigns, socket}
  end

  def run_hooks(assigns, socket, _opts) do
    {assigns, socket}
  end

end
