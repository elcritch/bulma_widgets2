
defmodule Action.DefaultNumberParse do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
  """
  def call(%Action{data: {key, value}} = evt, _opts) do
    value! = BulmaWidgets.Utils.NumberParse.number_parse(value)

    %{evt | data: {key, value!}}
  end
end

defmodule Action.DefaultAtomParse do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
  """
  def call(%Action{data: {key, value}} = evt, _opts) do
    value! = String.to_existing_atom(value)

    %{evt | data: {key, value!}}
  end
end

defmodule Action.Action.FloatNumberParse do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
  """
  def call(%Action{data: {key, value}} = evt, _opts) do
    value! = BulmaWidgets.Utils.NumberParse.number_parse(value, :float)

    %{evt | data: {key, value!}}
  end
end

defmodule Action.DefaultTimeParse do
  require Logger
  alias BulmaWidgets.Action

  @moduledoc """
  """

  def call(%Action{data: {key, value}} = evt, _opts) do
    value! = Time.from_iso8601!(value)

    %{evt | data: {key, value!}}
  end
end
