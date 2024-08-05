
defmodule BulmaWidgets.Action.AssignField do
  require Logger
  alias BulmaWidgets.Event

  @moduledoc """
    Assigns the `phx-data-*` values directly using the name
    given by the argument `field`.

    ## Examples

        {AssignField, field: :data}

  """
  def call(%Event{data: data, socket: socket} = evt, opts) do
    field = opts |> Keyword.fetch!(:field)
    %{evt | socket: Phoenix.LiveView.Utils.assign(socket, field, data)}
  end
end
