defmodule BulmaWidgets.Widgets.MultiPickMenu do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  use BulmaWidgets, :css_utilities
  alias BulmaWidgets.Action.AssignField

  require Logger

  @moduledoc """

  ## Examples

      <.live_component
        module={SelectionMenu}
        id="wiper_mode"
        is-fullwidth
        is-info
        label="Wiper Modes"
        values={[
          {"Regular", 1},
          {"Inverted", -1}
        ]}
      >
      </.live_component>
  """

  @standard_actions [
    {AssignField, field: :data}
  ]

  def update(assigns, socket) do
    # Logger.debug("selection_menu:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:ok, Actions.update(assigns, socket)}
  end

  attr :id, :string, required: true
  attr :label, :string, default: ""
  attr :values, :list, required: true
  attr :data, :any, default: {nil, nil}
  attr :extra_actions, :list, default: []
  attr :standard_actions, :list, default: @standard_actions
  attr :rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs()

  slot :default_label
  def render(assigns) do
    # Logger.info("selection_menu:render: assigns: #{inspect(assigns, pretty: true)}")
    # Logger.info("selection_menu:render: assigns:data: #{inspect(assigns.data)}")

    ~H"""
    <aside class="menu" id={@id}>
      <p class="menu-label" :if={@label != ""}>
        <%= @label %>
      </p>

      <ul class="menu-list">
        <%= for {key, value} <- @values do %>
          <li>
            <a href="#"
              phx-click={
                JS.push("menu-select-action", target: @rest.myself)
                |> JS.remove_class("is-active", to: "##{@id}")
              }
              phx-value-id={@id}
              phx-value-value-hash={value |> :erlang.phash2()}
              phx-target={@rest.myself}
            >
              <%= key %>
            </a>
          </li>
        <% end %>
      </ul>
    </aside>
    """
  end

  def handle_event( "menu-select-action", data, socket) do
    Logger.warninging("menu-select-action: #{inspect(data, pretty: true)}")
    %{"id" => menu_name, } = data

    data = [1,2,3]

    # Logger.warninging("menu-select-action: #{inspect({key, value}, pretty: true)}")
    {:noreply,
     socket
     |> Actions.handle_event(menu_name, data, @standard_actions)}
  end


  defp subid(menu_id, sub_key), do: String.to_atom("#{menu_id}/#{sub_key}")

  def to_digit_indexes({:{}, _meta, value}) do
    to_digit_indexes(value |> :erlang.list_to_tuple)
  end
  def to_digit_indexes({digits, _decimals, sign}) do
    digs = Enum.to_list(0..digits-1)

    if sign do
      # digs |> List.replace_at(0, "0")
      digs |> List.insert_at(0, :sign)
    else
      digs
    end
  end


  @digit_values (0..9 |> Enum.to_list() |> BulmaWidgets.Utils.Menu.convert())
  @sign_values ([:+, :-] |> BulmaWidgets.Utils.Menu.convert())

  def number_to_digits(value, {digits, decimals, sign}) do
    # Logger.warning("NUMBER_TO_DIGITS: #{inspect value} <- #{inspect {digits, decimals, sign}}")
    digit_values =
      (abs(value) * :math.pow(10, decimals))
      |> round()
      |> Integer.to_string()
      |> String.pad_leading(digits, "0")
      |> :erlang.binary_to_list()
      |> Enum.map(fn x -> x - 48 end)
      |> Enum.take(digits)

    Logger.warning("NUMBER_TO_DIGITS: dvs: #{inspect digit_values}")

    result =
      if sign do
        sdig = if value < 0, do: :-, else: :+
        digit_values |> List.insert_at(0, sdig)
      else
        digit_values
      end
    Logger.warning("NUMBER_TO_DIGITS: post: #{inspect result} ")
    result
  end

  def digits_to_number(numbers, {digits, decimals, sign}) do
    dsign = if sign, do: numbers |> List.pop_at(0) |> elem(0), else: :+
    numbers = if sign, do: numbers |> List.delete_at(0), else: numbers
    Logger.warning("DIGITS_TO_NUMBER: s: #{inspect dsign} num: #{inspect numbers} => #{inspect {digits, decimals, sign}}")

    {value, ""} =
      numbers
      |> Enum.map(fn x -> x |> to_string() end)
      |> Enum.join()
      |> Integer.parse()

    Logger.warning("DIGITS_TO_NUMBER: post: #{inspect value}")
    result = value * :math.pow(10, -decimals)
    Logger.warning("DIGITS_TO_NUMBER: result: #{inspect result}")
    result = if dsign == :-, do: result * -1.0, else: result
    Logger.warning("DIGITS_TO_NUMBER: result sign: #{inspect result}")
    result
  end

  def set_digit(value, dval, index, {digits, decimals, sign}) do
    Logger.warning("SET_DIGIT: #{inspect {value, dval}} idx: #{inspect index} <- #{inspect {digits, decimals, sign}}")
    numbers =
      value
      |> number_to_digits({digits, decimals, sign})

    Logger.warning("SET_DIGIT: numbers: #{inspect numbers} ")
    numbers =
      if sign do
        if index in [:+, :-] do
          numbers |> List.replace_at(0, index)
        else
          numbers |> List.replace_at(index+1, dval)
        end
      else
        numbers |> List.replace_at(index, dval)
      end
    Logger.warning("SET_DIGIT: numbers: post: #{inspect numbers} ")

    result = numbers |> digits_to_number({digits, decimals, sign})
    Logger.warning("SET_DIGIT: post: #{inspect result} ")
    result
  end


end
