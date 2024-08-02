defmodule BulmaWidgets.Action.Commands do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
    Apply a function with event data, or a list of functions:

        extra_actions={[
          {Action.Commands, commands: fn x -> Logger.info("HI: \#{inspect x}!!!") end}
        ]}
        extra_actions={[
          {Action.Commands, commands: [fn x -> Logger.info("HI: \#{inspect x}!!!") end]}
        ]}
  """
  def call(%Action{} = evt, opts) do
    modify? = opts |> Keyword.get(:modify, false)

    commands =
      case opts |> Keyword.get(:commands, []) do
        f when is_function(f, 1) -> [f]
        l when is_list(l) -> l
        _ -> []
      end

    # Logger.debug("Action:Commands: opts: #{inspect(opts)} ")
    # Logger.debug("Action:Commands: state: #{inspect(commands)} ")
    evt! =
      for cmd <- commands, reduce: evt do
        evt ->
          res = cmd.(evt)

          if modify? do
            res
          else
            evt
          end
      end

    evt!
  end
end

defmodule BulmaWidgets.Action.AssignField do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
    Assigns the `phx-data-*` values directly using the name
    given by the argument `field`.

    ## Examples

        {Action.AssignField, field: :data}
  """
  def call(%Action{data: data, socket: socket} = evt, opts) do
    field = opts |> Keyword.fetch!(:field)
    %{evt | socket: Phoenix.LiveView.Utils.assign(socket, field, data)}
  end
end

defmodule BulmaWidgets.Action.CastMenuEvent do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
  """
  def call(%Action{socket: socket} = evt, opts \\ []) do
    event_name = opts |> Keyword.get(:event_name, :menu_event)
    Process.send(self(), {event_name, evt, opts}, [])

    %{evt | socket: socket}
  end
end
