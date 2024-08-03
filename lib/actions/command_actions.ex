defmodule BulmaWidgets.Action.Commands do
  require Logger
  alias BulmaWidgets.Event

  @moduledoc """
    Apply a function with event data, or a list of functions:

        extra_actions={[
          {Commands, commands: fn evt ->
              Logger.info("HI: \#{inspect evt}!!!")
              evt
            end}
        ]}
        extra_actions={[
          {Commands, commands: [
            fn -> Logger.info("HI!!!") end]},
            fn evt ->
              Logger.info("HI AGAIN: \#{inspect evt}!!!")
              evt
            end]}
        ]}
  """
  def call(%Event{} = evt, opts) do
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
          evt! =
            case cmd do
              fun when is_function(fun, 1) ->
                %Event{} = evt = fun.(evt)
                evt
              fun when is_function(fun, 0) ->
                fun.()
                evt
              hook ->
                Logger.error("invalid command hook: #{inspect(hook)}")
                evt
            end

          if modify? do evt! else evt
          end
      end

    evt!
  end
end

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

defmodule BulmaWidgets.Action.CastMenuEvent do
  require Logger
  alias BulmaWidgets.Event

  @moduledoc """
  """
  def call(%Event{socket: socket} = evt, opts \\ []) do
    event_name = opts |> Keyword.get(:event_name, :menu_event)
    Process.send(self(), {event_name, evt, opts}, [])

    %{evt | socket: socket}
  end
end
