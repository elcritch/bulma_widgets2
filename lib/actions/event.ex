defmodule BulmaWidgets.Event do
  require Logger

  @moduledoc """
  """

  defstruct id: :name,
            data: {nil, nil},
            assigns: nil,
            socket: nil

  @type t :: %__MODULE__{
          id: binary(),
          data: {binary(), binary()},
          assigns: map(),
          socket: Phoenix.LiveView.Socket.t()
        }

  def apply(event_action, actions) do
    actions = actions |> List.flatten()

    for action <- actions, reduce: event_action do
      evt ->
        evt! =
          case action do
            {mod, opts} ->
              mod.call(evt, opts)

            mod ->
              mod.call(evt, [])
          end

        # Logger.debug("Action:APPLY: evt!: #{inspect(evt!.id)} #{inspect(evt!.data)} ")
        evt!
    end
  end



  def fields_to_assigns(fields) do
        for {k, v} <- fields, into: %{} do
          if is_atom(k) do
            {k, v}
          else
            {k |> String.to_atom(), v}
          end
        end
  end

  def key(data, default \\ ""), do: dokey(data, default)
  def dokey({k, _v}, _default), do: k
  def dokey(k, default), do: k || default

  def val(data, default \\ ""), do: doval(data, default)
  def doval({_k, v}, _default), do: v
  def doval(d, default), do: d || default

end

defimpl String.Chars, for: BulmaWidgets.Event do
  def to_string(evt) do

    sock = case evt.socket do
      nil -> "nil"
      sock -> "Socket<id: #{sock.id}, view: #{sock.view}, ...>"
    end

    "BulmaWidgets.Event<id: #{inspect(evt.id)}, data: #{inspect(evt.data)}, socket: #{sock}>"
  end
end
