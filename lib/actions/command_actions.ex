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
