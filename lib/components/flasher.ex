defmodule BulmaWidgets.Flash do
  import Phoenix.LiveView

  def put_flash!(socket, type, message) do
    put_flash!(self(), socket, type, message)
  end
  def put_flash!(pid, socket, type, message) do
    send(pid, {:put_flash, type, message})
    Process.send_after(pid, {:clear_flash, type, message}, 7_000)
    socket
  end

  def on_mount(_name, _params, _session, socket) do
    {:cont, socket |> attach_hook(:flash, :handle_info, &maybe_receive_flash/2)}
  end

  require Logger
  defp maybe_receive_flash({:put_flash, type, message}, socket) do
    {:halt, put_flash(socket, type, message)}
  end
  defp maybe_receive_flash({:clear_flash, type, _message}, socket) do
    {:halt, clear_flash(socket, type)}
  end

  defp maybe_receive_flash(_, socket), do: {:cont, socket}

  # And the previous `put_flash!/3` definition
end
