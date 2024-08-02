defmodule BulmaWidgets.Action.UpdateHooks do
  import Phoenix.LiveView
  alias BulmaWidgets.Action
  require Logger

  @moduledoc """

  ## Examples

      extra_actions={[
        {BulmaWidgets.Action.UpdateHooks,
          to: @myself,
          hooks: [
            fn ->
              Logger.warning("UpdateHooks:func: ")
            end,
            fn asg, sock ->
              Logger.warning("UpdateHooks:func:args: ")
              sock
            end,
            {:start_async, :check_run, @device,
              fn args ->
                Logger.warning("UpdateHooks:func: ")
                check_sensor(args)
              end}]}
      ]}
  """
  def call(%Action{id: id, data: {key, values}, socket: socket} = evt, opts \\ []) do
    Logger.debug("UpdateHooks:call:opts: #{inspect(opts, pretty: false)}")
    Logger.debug("UpdateHooks:call:values: #{inspect(values, pretty: false)}")

    target = opts |> Keyword.get(:to, socket.assigns.id)
    hooks = [opts |> Keyword.fetch!(:hooks)] |> List.flatten()
    # |> Map.take(set_fields)
    values = opts |> Keyword.get(:values, values)
    id = opts |> Keyword.get(:id, id)

    Logger.debug("UpdateHooks:call:target: #{inspect(target, pretty: false)}")
    msg = %{hooks: hooks, id: id, data: {key, values}}

    case target do
      %Phoenix.LiveComponent.CID{} = cid ->
        send_update(cid, %{__trigger_hooks__: msg})

      {module, target} ->
        send_update(module, %{id: target, __trigger_hooks__: msg})

      pid when is_pid(pid) ->
        Logger.warning("TODO PID!")
        send(pid, {:update_state, %{__trigger_hooks__: msg}})
    end

    %{evt | socket: socket}
  end

  def exec_hooks(hooks, id, data, assigns, socket, _opts) do
    {key, values} = data

    evt = %Action{
      id: id,
      data: {key, values},
      state: assigns,
      socket: socket
    }

    evt! =
      for hook <- hooks, reduce: evt do
        evt ->
          case hook do
            fun when is_function(fun, 1) ->
              %Action{} = evt = fun.(evt)
              evt

            fun when is_function(fun, 0) ->
              fun.()
              evt

            {:start_async, name, _args, cb} when is_function(cb, 1) ->
              socket
              |> Phoenix.LiveView.start_async(name, fn ->
                cb.(evt)
              end)

            hook ->
              Logger.error("invalid update hook: #{inspect(hook)}")
              evt
          end
      end

    evt!
  end

  def run_hooks(%{__trigger_hooks__: msg} = assigns, socket, opts) do
    %{id: id, hooks: hooks, data: data} = msg
    assigns = assigns |> Map.delete(:__trigger_hooks__)
    evt = exec_hooks(hooks, id, data, assigns, socket, opts)

    {assigns, evt.socket}
  end

  def run_hooks(assigns, socket, _opts) do
    # no __trigger_hooks, nothing to do
    {assigns, socket}
  end

  def on_mount(_name, _params, _session, socket) do
    {:cont,
     socket |> attach_hook(:widget_state_update_hooks, :handle_info, &maybe_receive_update/2)}
  end

  defp maybe_receive_update({:update_state, %{__trigger_hooks__: msg}}, socket) do
    %{id: id, hooks: hooks, data: data} = msg
    Logger.debug("UpdateHooks:update_state:update: #{inspect(msg, pretty: true)} ")

    evt = exec_hooks(hooks, id, data, socket.assigns, socket, [])

    {:halt, evt.socket}
  end

  defp maybe_receive_update(_, socket) do
    {:cont, socket}
  end
end
