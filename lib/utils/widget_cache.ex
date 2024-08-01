defmodule BulmaWidgets.Cache do

  # BulmaWidgets.Cache.get_all!
  require Logger
  use GenServer

  def put(mod, key, val) do
    GenServer.call(__MODULE__, {:put_key, mod, key |> to_string(), val, nil})
  end

  def put_all(mod, key, values = %{}) do
    GenServer.call(__MODULE__, {:put_key_all, mod, key, values, nil})
  end

  def get(mod, key, default \\ nil) do
    res = GenServer.call(__MODULE__, {:get_key, mod, key |> to_string(), nil})
    case res do
      :notfound -> default
      {:ok, res} -> res
    end
  end

  def get_all(mod) do
    GenServer.call(__MODULE__, {:get_key_all, mod, nil})
    |> Map.new()
  end

  def get_all!() do
    GenServer.call(__MODULE__, {:get_all, nil})
  end

  def delete_all(mod) do
    GenServer.call(__MODULE__, {:delete_all, mod, nil})
  end

  def clear!() do
    GenServer.call(__MODULE__, {:clear_all, nil})
  end


  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def init(opts) do
    # Setup ETS
    name = opts |> Keyword.get(:name, __MODULE__)

    {:ok, %{name: name, tables: %{}}}
  end

  defp table(state, mod) do
    if state.tables |> Map.has_key?(mod) do
      {state, state.tables |> Map.get(mod)}
    else
      ets = :ets.new(mod, [:set, :protected, :named_table])
      tables = state.tables |> Map.put(mod, ets)
      {%{state | tables: tables}, ets}
    end
  end

  def handle_call({:delete_all, mod, _opts}, _from, state) do
    {state, ets} = state |> table(mod)
    res = ets |> :ets.delete_all_objects()
    {:reply, res, state}
  end

  def handle_call({:clear_all, _opts}, _from, state) do
    for {_name, ets} <- state.tables do
      ets |> :ets.delete_all_objects()
      ets |> :ets.delete()
    end
    {:reply, :ok, %{state | tables: %{}}}
  end

  def handle_call({:put_key, mod, key, val, _opts}, _from, state) do
    {state, ets} = state |> table(mod)
    ets |> :ets.insert({key, val})
    {:reply, :ok, state}
  end

  def handle_call({:put_key_all, mod, key, vals, _opts}, _from, state) do
    {state, ets} = state |> table(mod)
    {:ok, curr} = ets |> ets_get_key(key, {:ok, %{}})
    ets |> :ets.insert({key, Map.merge(curr, vals)})
    {:reply, :ok, state}
  end

  def handle_call({:get_key, mod, key, _opts}, _from, state) do
    {state, ets} = state |> table(mod)
    res = ets |> ets_get_key(key)
    Logger.debug("BulmaWidgets.Cache:get: #{inspect res}")
    {:reply, res, state}
  end

  def handle_call({:get_key_all, mod, _opts}, _from, state) do
    {state, ets} = state |> table(mod)
    res = ets |> :ets.tab2list()
    {:reply, res, state}
  end

  def handle_call({:get_all, _opts}, _from, state) do
    res =
      for {name, ets} <- state.tables do
        {name, ets |> :ets.tab2list()}
      end
    {:reply, res, state}
  end

  defp ets_get_key(name, key, default \\ :notfound) do
    case :ets.lookup(name, key) do
      [{^key, vals}] ->
        {:ok, vals}

      [] ->
        default
    end
  end
end
