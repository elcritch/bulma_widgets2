
defmodule EventAction.DefaultNumberParse do
  require Logger
  alias BulmaWidgets.EventAction

  @moduledoc """
  """
  def call(%EventAction{data: {key, value}} = evt, _opts) do
    value! = BulmaWidgets.Utils.NumberParse.number_parse(value)

    %{evt | data: {key, value!}}
  end
end

defmodule EventAction.DefaultAtomParse do
  require Logger
  alias BulmaWidgets.EventAction

  @moduledoc """
  """
  def call(%EventAction{data: {key, value}} = evt, _opts) do
    value! = String.to_existing_atom(value)

    %{evt | data: {key, value!}}
  end
end

defmodule EventAction.EventAction.FloatNumberParse do
  require Logger
  alias BulmaWidgets.EventAction

  @moduledoc """
  """
  def call(%EventAction{data: {key, value}} = evt, _opts) do
    value! = BulmaWidgets.Utils.NumberParse.number_parse(value, :float)

    %{evt | data: {key, value!}}
  end
end

defmodule EventAction.DefaultTimeParse do
  require Logger
  alias BulmaWidgets.EventAction

  @moduledoc """
  """

  def call(%EventAction{data: {key, value}} = evt, _opts) do
    value! = Time.from_iso8601!(value)

    %{evt | data: {key, value!}}
  end
end
