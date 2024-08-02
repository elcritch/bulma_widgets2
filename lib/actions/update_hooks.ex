defmodule BulmaWidgets.Action.UpdateHooks do
  import Phoenix.LiveView
  alias BulmaWidgets.Action
  require Logger

  @moduledoc """

  ## Examples

      extra_actions={[
        {BulmaWidgets.Action.UpdateHooks,
          to: @myself,
          post: [
            fn ->
              Logger.warning("UpdateHooks:func: #{}")
            end,
            fn asg, sock ->
              Logger.warning("UpdateHooks:func: #{}")
              sock
            end,
            {:start_async, :check_run, @device,
              fn args ->
                Logger.warning("UpdateHooks:func: ")
                check_sensor(args)
              end}]}
      ]}
  """
  def call(%Action{data: {_key, values}, socket: socket} = evt, opts \\ []) do
    Logger.debug("UpdateHooks:call:opts: #{inspect(opts, pretty: false)}")

    target = opts |> Keyword.get(:to, socket.assigns.id)
    post = opts |> Keyword.fetch!(:post) |> List.flatten()
    values = opts |> Keyword.get(:values, values) # |> Map.take(set_fields)

    Logger.debug("UpdateHooks:call:target: #{inspect(target, pretty: false)}")
    msg = %{hooks: post, values: values}
    case target do
      %Phoenix.LiveComponent.CID{} = cid ->
        send_update(cid, %{__trigger_hooks__: msg})
      {module, target} ->
        send_update(module, %{id: target, __trigger_hooks__: msg})
    end

    %{evt | socket: socket}
  end

  def exec_hooks(hooks, _values, assigns, socket, _opts) do
    socket =
      for hook <- hooks, reduce: socket do
        socket ->
          case hook do
            fun when is_function(fun, 2) ->
              fun.(assigns, socket)
            fun when is_function(fun, 0) ->
              fun.()
              socket
            {:start_async, name, args, cb} when is_function(cb, 1) ->
              socket |> Phoenix.LiveView.start_async(name, fn ->
                cb.(args)
              end)
            hook ->
              Logger.error("invalid trigger hook callback: #{inspect(hook)}")
              socket
          end
      end

    socket
  end

  def run_post_hooks(%{__trigger_hooks__: %{hooks: hooks, values: values}} = assigns, socket, opts) do
    assigns = assigns |> Map.delete(:__trigger_hooks__)
    socket = exec_hooks(hooks, values, assigns, socket, opts)

    {assigns, socket}
  end

  def run_post_hooks(assigns, socket, _opts) do
    # no __trigger_hooks, nothing to do
    {assigns, socket}
  end

end
