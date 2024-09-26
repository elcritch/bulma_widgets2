defmodule BulmaWidgets.Widgets.DigitPicker do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers
  use BulmaWidgets, :css_utilities
  alias BulmaWidgets.Action.AssignField
  import BulmaWidgets.Components

  require Logger

  @moduledoc """

  ## Examples

      <.live_component
        module={DigitPicker}
        id="digit_test"
        value={514.14}
        digits={{4,3,true}}
        extra_actions={[
          Widgets.send_action_data("test-value-set", into: :switch_test)
        ]}
      >
      </.live_component>
  """

  @standard_actions [
    {AssignField, field: :data}
  ]

  @digit_values 0..9 |> Enum.to_list() |> Enum.map(fn n -> {n, n} end)
  @sign_values [{0, :+}, {1, :-}]

  def update(assigns, socket) do
    menu_id = assigns.id
    value = assigns.value
    # digits: {4, 3, true},
    digit_config = assigns.digits

    # unless is_integer(value),
    #   do: raise(%ArgumentError{message: "value must be an integer version of a float - got #{inspect(value)}"})

    keys =
      to_digit_indexes(digit_config)

    digit_values = number_to_digits(value, digit_config)

    # Logger.info("assign multi item: keys: #{inspect(keys)} ")
    # Logger.info("assign multi item: digits: #{inspect(digit_values)} ")

    subitems =
      for {data, key} <- Enum.zip(digit_values, keys), into: %{} do
        scrollitems = if key in [:sign], do: @sign_values, else: @digit_values
        subkey = subkey(menu_id, key)
        values = scrollitems |> Enum.to_list()
        # Logger.info("  item: data: #{inspect(data)} ")
        item = values |> Enum.find(fn {_,l} -> l == data end)

        {String.to_atom("#{key}"),
         %{
           id: subkey,
           key: key,
           data: item,
           values: values,
         }}
      end

    # Add layout opts
    # item = %{item | layout: struct(item.layout, opts)}

    # IO.inspect(item, label: :date_picker_values)
    # Logger.info("multi item: #{inspect(assigns, pretty: true)} ")
    # Logger.info("multi subitems: #{inspect(subitems)} ")

    # data = for sub_key <- digit_config
    socket =
      socket
      |> assign(:keys, keys |> Enum.map(fn x -> String.to_atom("#{x}") end))
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
  attr :value, :float, default: 0.0
  attr :digit_config, :any
  attr :extra_actions, :list, default: []
  attr :standard_actions, :list, default: @standard_actions
  attr :rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs()

  slot :default_label

  def render(assigns) do
    # Logger.info("selection_menu:render: assigns: #{inspect(assigns, pretty: true)}")
    # Logger.info("selection_menu:render: assigns:data: #{inspect(assigns.data)}")

    ~H"""
    <div class="blmw-digit-picker field is-grouped">
      <%= for item <- @rest.keys do %>
        <% digit = @rest.subitems[item] %>
        <div class={["control", digit.key]}>
          <.dropdown id={digit.id} values={digit.values} selected={Event.key(digit.data)}>
            <:label :let={sel}>
              <%= BulmaWidgets.Event.val(sel) %>
            </:label>

            <:items :let={%{id: id, label: label, key: menu_key, parent: _parent, selected: selected}}>
              <a
                class={["dropdown-item", (selected && "is-active") || ""]}
                phx-click={
                  JS.push("menu-select-action", target: @rest.myself)
                  |> JS.remove_class("is-active", to: "##{id}")
                }
                phx-value-id={id}
                phx-value-data-index={menu_key}
                phx-target={@rest.myself}
              >
                <%= label %>
              </a>
            </:items>
          </.dropdown>
        </div>
        <%= if index(@digit_config, digit.key) == 0 do %>
          <span
            class="icon has-text-centered is-size-2 has-text-white"
          >
            .
          </span>
        <% end %>
        <%= if rem(index(@digit_config, digit.key), 3) == 0 && index(@digit_config, digit.key) != 0 do %>
          <span
            class="icon has-text-centered is-size-2 has-text-white"
            style="padding-right: 0.2em; width: 0.2em;"
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
    Logger.warning("menu-select-action:subitems:keys: #{inspect(socket.assigns.subitems |> Map.keys(), pretty: true)}")
    %{"id" => menu_name, "data-index" => menu_index_raw} = data

    ## gross, really need to just redo this and change the {idx, label} stuff to structs

    {digit_index, ""} =
      menu_name
      |> String.replace_leading("#{socket.assigns.id}--", "")
      |> case do
        "sign" -> {:sign, ""}
        num -> Integer.parse(num)
      end

    subkey =
      digit_index
      |> to_string()
      |> String.to_atom()

    {menu_index, ""} = menu_index_raw |> Integer.parse()

    {dkey, dvalue} = socket.assigns.subitems[subkey].values |> Enum.at(menu_index)
    # Logger.warning("menu-select-action:subitems:pre: #{inspect(socket.assigns.subitems , pretty: true)}")
    subitems = put_in(socket.assigns.subitems, [subkey, :data], {dkey, dvalue} )
    socket = socket |> assign(:subitems, subitems)
    number! = set_digit(socket.assigns.value, dvalue, digit_index, socket.assigns.digit_config)

    # Logger.warning("menu-select-action:subitems: #{inspect(subitems , pretty: true)}")
    {:noreply,
     socket
     |> Actions.handle_event(menu_name, number!, @standard_actions)}
  end

  defp subkey(menu_id, sub_key), do: String.to_atom("#{menu_id}--#{sub_key}")

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
    digit_values =
      (abs(value) * :math.pow(10, decimals))
      |> round()
      |> Integer.to_string()
      |> String.pad_leading(digits, "0")
      |> :erlang.binary_to_list()
      |> Enum.map(fn x -> x - 48 end)
      |> case do
        val ->
          if length(val) > digits do
            Logger.warning("#{__MODULE__}: truncating value: #{inspect(val)} exceeds digits: #{digits}")
          end
          val
      end
      |> Enum.take(-digits)

    result =
      if sign do
        sdig = if value < 0, do: :-, else: :+
        digit_values |> List.insert_at(0, sdig)
      else
        digit_values
      end

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

  def set_digit(value, dval, index, {digits, decimals, do_sign}) do
    Logger.warning(
      "SET_DIGIT: #{inspect([value: value, dval: dval])} idx: #{inspect(index)} <- #{inspect({digits, decimals, do_sign})}"
    )

    numbers =
      value
      |> number_to_digits({digits, decimals, do_sign})

    numbers =
      if do_sign do
        if index == :sign do
          numbers |> List.replace_at(0, dval)
        else
          numbers |> List.replace_at(index + 1, dval)
        end
      else
        numbers |> List.replace_at(index, dval)
      end

    Logger.warning("SET_DIGIT: numbers: post: #{inspect(numbers)} ")

    result = numbers |> digits_to_number({digits, decimals, do_sign})
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
