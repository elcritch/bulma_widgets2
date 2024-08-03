
defmodule BulmaWidgets.Action.DefaultNumberParse do
  require Logger
  alias BulmaWidgets.Event

  @moduledoc """
  """
  def call(%Event{data: {key, value}} = evt, _opts) do
    value! = BulmaWidgets.Utils.NumberParse.number_parse(value)

    %{evt | data: {key, value!}}
  end
end

defmodule BulmaWidgets.Action.DefaultAtomParse do
  require Logger
  alias BulmaWidgets.Event

  @moduledoc """
  """
  def call(%Event{data: {key, value}} = evt, _opts) do
    value! = String.to_existing_atom(value)

    %{evt | data: {key, value!}}
  end
end

defmodule BulmaWidgets.Action.FloatNumberParse do
  require Logger
  alias BulmaWidgets.Event

  @moduledoc """
  """
  def call(%Event{data: {key, value}} = evt, _opts) do
    value! = BulmaWidgets.Utils.NumberParse.number_parse(value, :float)

    %{evt | data: {key, value!}}
  end
end

defmodule BulmaWidgets.Action.DefaultTimeParse do
  require Logger
  alias BulmaWidgets.Event

  @moduledoc """
  """

  def call(%Event{data: {key, value}} = evt, _opts) do
    value! = Time.from_iso8601!(value)

    %{evt | data: {key, value!}}
  end
end
