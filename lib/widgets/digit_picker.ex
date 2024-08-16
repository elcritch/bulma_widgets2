defmodule BulmaWidgets.Widgets.DigitPickMenu do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  use BulmaWidgets, :css_utilities
  alias BulmaWidgets.Action.AssignField
  import BulmaWidgets.Components

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

  @digit_values 0..9 |> Enum.to_list() |> BulmaWidgets.Utils.Menu.convert()
  @sign_values [:+, :-] |> BulmaWidgets.Utils.Menu.convert()

  def update(assigns, socket) do
    menu_id = assigns.id
    value = assigns.value
    # digits: {4, 3, true},
    digit_config = assigns.digits

    unless is_float(value),
      do: raise(%ArgumentError{message: "value must be an integer - got #{inspect(value)}"})

    keys = to_digit_indexes(digit_config)

    digit_values = number_to_digits(value, digit_config)

    Logger.info("assign multi item: keys: #{inspect(keys)} ")
    Logger.info("assign multi item: digits: #{inspect(digit_values)} ")

    subitems =
      for {data, sub_key} <- Enum.zip(digit_values, keys), into: %{} do
        scrollitems = if is_atom(sub_key), do: @sign_values, else: @digit_values
        # sub_item = struct(ScrollMenuLive, [])
        sub_id = subid(menu_id, sub_key)
        values = scrollitems |> Enum.to_list()

        {sub_key,
         %{
           id: sub_id,
           key: sub_key,
           data: {to_string(data), data},
           values: values,
         }}
      end

    # Add layout opts
    # item = %{item | layout: struct(item.layout, opts)}

    # IO.inspect(item, label: :date_picker_values)
    Logger.info("multi item: #{inspect(assigns, pretty: true)} ")
    Logger.info("multi subitems: #{inspect(subitems)} ")

    # data = for sub_key <- digit_config
    socket =
      socket
      |> assign(:keys, keys)
      |> assign(:digit_config, digit_config)
      |> assign(:data, value)
      |> assign(:subitems, subitems)

    # IO.inspect(socket!.assigns, label: :date_picker_assigns, pretty: true)
    # IO.inspect(socket!.changed, label: :date_picker_sockets, pretty: true)

    # Logger.debug("selection_menu:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:ok, Actions.update(assigns, socket)}
  end

  attr :id, :string, required: true
  attr :label, :string, default: ""
  attr :values, :list, required: true
  attr :data, :any, default: {nil, nil}
  attr :keys, :list
  attr :subitems, :list
  attr :digit_config, :any
  attr :extra_actions, :list, default: []
  attr :standard_actions, :list, default: @standard_actions
  attr :rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs()

  slot :default_label

  def render(assigns) do
    Logger.info("selection_menu:render: assigns: #{inspect(assigns, pretty: true)}")
    # Logger.info("selection_menu:render: assigns:data: #{inspect(assigns.data)}")

    ~H"""
    <div class="date-picker-field field is-grouped">
      <%= for item <- @keys do %>
        <% digit = @subitems[item] %>
        <% Logger.warning("ITEM: #{inspect(item)}") %>
        <% Logger.warning("DIGIT: #{inspect(digit)}") %>
        <div class={["control", digit.key]}>
          <.dropdown id={digit.id} values={digit.values} selected={Event.key(digit.data)}>
            <:label :let={sel}>
              <%= BulmaWidgets.Event.val(sel, "Dropdown") %>
            </:label>

            <:items :let={%{id: id, label: label, key: key, parent: _parent, selected: selected}}>
              <a
                class={["dropdown-item", (selected && "is-active") || ""]}
                phx-click={
                  JS.push("menu-select-action", target: @rest.myself)
                  |> JS.remove_class("is-active", to: "##{id}")
                }
                phx-value-id={id}
                phx-value-digit={key}
                phx-value-value-hash={key |> :erlang.phash2()}
                phx-target={@rest.myself}
              >
                <%= label %>
              </a>
            </:items>
          </.dropdown>
        </div>
        <%= if index(@digit_config, digit.key) == 0 do %>
          <span
            class="icon has-text-centered is-size-1 has-text-white"
          >
            .
          </span>
        <% end %>
        <%= if rem(index(@digit_config, digit.key), 3) == 0 && index(@digit_config, digit.key) != 0 do %>
          <span
            class="icon has-text-centered is-size-1 has-text-white"
            style="padding-right: 0.5em; width: 0.5em;"
          >
            ,
          </span>
        <% end %>
        <%!-- <%= get_in(opts, [:"#{key}", :post]) %> --%>
      <% end %>
    </div>
    """
  end

  def handle_event("menu-select-action", data, socket) do
    Logger.warning("menu-select-action: #{inspect(data, pretty: true)}")
    %{"id" => menu_name} = data

    data = [1, 2, 3]

    subitems = socket.assigns.subitems
    # put_in()

    Logger.warning("menu-select-action:subitems: #{inspect(subitems , pretty: true)}")
    {:noreply,
     socket
     |> Actions.handle_event(menu_name, data, @standard_actions)}
  end

  defp subid(menu_id, sub_key), do: String.to_atom("#{menu_id}--#{sub_key}")

  def to_digit_indexes({:{}, _meta, value}) do
    to_digit_indexes(value |> :erlang.list_to_tuple())
  end

  def to_digit_indexes({digits, _decimals, sign}) do
    digs = Enum.to_list(0..(digits - 1))

    if sign do
      # digs |> List.replace_at(0, "0")
      digs |> List.insert_at(0, :sign)
    else
      digs
    end
  end

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

    Logger.warning("NUMBER_TO_DIGITS: dvs: #{inspect(digit_values)}")

    result =
      if sign do
        sdig = if value < 0, do: :-, else: :+
        digit_values |> List.insert_at(0, sdig)
      else
        digit_values
      end

    Logger.warning("NUMBER_TO_DIGITS: post: #{inspect(result)} ")
    result
  end

  def digits_to_number(numbers, {digits, decimals, sign}) do
    dsign = if sign, do: numbers |> List.pop_at(0) |> elem(0), else: :+
    numbers = if sign, do: numbers |> List.delete_at(0), else: numbers

    Logger.warning(
      "DIGITS_TO_NUMBER: s: #{inspect(dsign)} num: #{inspect(numbers)} => #{inspect({digits, decimals, sign})}"
    )

    {value, ""} =
      numbers
      |> Enum.map(fn x -> x |> to_string() end)
      |> Enum.join()
      |> Integer.parse()

    Logger.warning("DIGITS_TO_NUMBER: post: #{inspect(value)}")
    result = value * :math.pow(10, -decimals)
    Logger.warning("DIGITS_TO_NUMBER: result: #{inspect(result)}")
    result = if dsign == :-, do: result * -1.0, else: result
    Logger.warning("DIGITS_TO_NUMBER: result sign: #{inspect(result)}")
    result
  end

  def set_digit(value, dval, index, {digits, decimals, sign}) do
    Logger.warning(
      "SET_DIGIT: #{inspect({value, dval})} idx: #{inspect(index)} <- #{inspect({digits, decimals, sign})}"
    )

    numbers =
      value
      |> number_to_digits({digits, decimals, sign})

    Logger.warning("SET_DIGIT: numbers: #{inspect(numbers)} ")

    numbers =
      if sign do
        if index in [:+, :-] do
          numbers |> List.replace_at(0, index)
        else
          numbers |> List.replace_at(index + 1, dval)
        end
      else
        numbers |> List.replace_at(index, dval)
      end

    Logger.warning("SET_DIGIT: numbers: post: #{inspect(numbers)} ")

    result = numbers |> digits_to_number({digits, decimals, sign})
    Logger.warning("SET_DIGIT: post: #{inspect(result)} ")
    result
  end

  def index(digit_config, key) when is_atom(key) do
    -1
  end

  def index(digit_config, key) do
    elem(digit_config, 0) - elem(digit_config, 1) - key - 1
  end
end
