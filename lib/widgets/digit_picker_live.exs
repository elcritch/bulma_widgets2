defmodule BulmaLive.Widgets.DigitPickerLive.LayoutOptions do
  # csswidths: %{month: "4.5em", day: "4.5em", year: "5.5em" },
  defstruct fa_icon: 'fa fa-angle-down',
            kind: :span,
            left_icon: '',
            right_icon: true
end

defmodule BulmaLive.Widgets.DigitPickerLive do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  require Logger
  alias __MODULE__
  alias BulmaLive.EventAction
  alias BulmaLive.Widgets.ScrollMenuLive

  defstruct id: nil,
            #  evt_name: nil,
            values: %{},
            scrollitems: %{},
            digit_config: %{},
            keys: %{},
            layout: %__MODULE__.LayoutOptions{},
            data: nil

  defdelegate fetch(obj, key), to: Map
  defdelegate get_and_update(obj, key, func), to: Map

  def convert(vals) do
    for val <- vals, into: [] do
      case val do
        {k, v} -> {k, v}
        [k, v] -> {k, v}
        val -> {val, val}
      end
    end
  end

  def standard_actions() do
    [
      BulmaLive.EventAction.DefaultNumberParse,
      BulmaLive.EventAction.ToggleMenu,
      BulmaLive.EventAction.MenuCommands,
      BulmaLive.EventAction.WidgetStateUpdate,
      BulmaLive.EventAction.DigitPickerUpdateAction
    ]
  end

  @doc false
  defmacro __using__(mopts) do
    IO.inspect(mopts, label: DbSchemaStore.OPTS)

    {:ok, mid} = Access.fetch(mopts, :id)

    unless is_atom(mid) do
      raise %ArgumentError{message: "menu_id must be an atom - got #{inspect mid}"}
    end

    # menu_name = Atom.to_string(mid)

    # value_parse = opts[:value_handler] || &BulmaLive.Utils.NumberParse.menu_action_parse_number/2
    actions = mopts[:actions] || standard_actions() ++ Keyword.get(mopts, :extra_actions, [])

    action_options = mopts[:action_options] || []
    digit_config  = mopts[:digits] || {:{}, [], [6, 2, false]}
    digit_indexes = digit_config |> to_digit_indexes()

    quote do
      alias BulmaLive.Widgets.DigitPickerLive

      def assign_menu(socket, unquote(mid) = menu_id, value, opts) do
        DigitPickerLive.assign_menu(socket, menu_id, unquote(digit_config), value, opts)
      end

      # def live_date_picker_render(unquote(mid), assigns, layout_opts \\ unquote(mopts[:layout])) do
      def live_widget_render(unquote(mid), assigns, layout_opts) do
        dlayouts = unquote(mopts[:layout] || [])
        DigitPickerLive.live_render(assigns, [id: unquote(mid)] ++ layout_opts)
      end

      def handle_event(
            "menu-click",
            %{"id" => unquote("#{mid}/") <> _subid = mname} = data,
            socket
          ) do
        menu_id = String.to_existing_atom(mname)
        item = socket.assigns[menu_id]
        item! = %{item | active: !item.active}

        {:noreply, assign(socket, [{menu_id, item!}])}
      end

      def handle_event(
            "menu-select",
            %{"id" => unquote("#{mid}/") <> _subid = mname, "key" => key, "value" => value} =
              data,
            socket
          ) do
        menu_id = String.to_existing_atom(mname)
        # Logger.warn("menu-select: #{inspect mname} => #{inspect key} #{inspect value} ")

        event_action =
          %EventAction{
            id: menu_id,
            data: {key, value},
            state: socket.assigns[menu_id],
            socket: socket
          }
          |> BulmaLive.EventAction.apply(unquote(actions), unquote(action_options))

        {:noreply, event_action.socket}
      end
    end
  end

  defp subid(menu_id, sub_key), do: String.to_atom("#{menu_id}/#{sub_key}")

  def to_digit_indexes({:{}, _meta, value}) do
    to_digit_indexes(value |> :erlang.list_to_tuple)
  end
  def to_digit_indexes({digits, decimals, sign}) do
    digs = Enum.to_list(0..digits-1)

    if sign do
      # digs |> List.replace_at(0, "0")
      digs |> List.insert_at(0, :sign)
    else
      digs
    end
  end

  @digit_values (0..9 |> Enum.to_list() |> ScrollMenuLive.convert())
  @sign_values ([:+, :-] |> ScrollMenuLive.convert())
  @layout %ScrollMenuLive.LayoutOptions{csswidth: '3.0em', right_css: 'has-text-grey-lighter '}

  def number_to_digits(value, {digits, decimals, sign}) do
    # Logger.warn("NUMBER_TO_DIGITS: #{inspect value} <- #{inspect {digits, decimals, sign}}")
    digit_values =
      (abs(value) * :math.pow(10, decimals))
      |> round()
      |> Integer.to_string()
      |> String.pad_leading(digits, "0")
      |> :erlang.binary_to_list()
      |> Enum.map(fn x -> x - 48 end)
      |> Enum.take(digits)

    # Logger.warn("NUMBER_TO_DIGITS: dvs: #{inspect digit_values}")

    result =
      if sign do
        sdig = if value < 0, do: :-, else: :+
        digit_values |> List.insert_at(0, sdig)
      else
        digit_values
      end
    # Logger.warn("NUMBER_TO_DIGITS: post: #{inspect result} ")
    result
  end

  def digits_to_number(numbers, {digits, decimals, sign}) do
    dsign = if sign, do: numbers |> List.pop_at(0) |> elem(0), else: :+
    numbers = if sign, do: numbers |> List.delete_at(0), else: numbers
    # Logger.warn("DIGITS_TO_NUMBER: s: #{inspect dsign} num: #{inspect numbers} => #{inspect {digits, decimals, sign}}")

    {value, ""} =
      numbers
      |> Enum.map(fn x -> x |> to_string() end)
      |> Enum.join()
      |> Integer.parse()

    # Logger.warn("DIGITS_TO_NUMBER: post: #{inspect value}")
    result = value * :math.pow(10, -decimals)
    # Logger.warn("DIGITS_TO_NUMBER: result: #{inspect result}")
    result = if dsign == :-, do: result * -1.0, else: result
    # Logger.warn("DIGITS_TO_NUMBER: result sign: #{inspect result}")
    result
  end

  def set_digit(value, dval, index, {digits, decimals, sign}) do
    # Logger.warn("SET_DIGIT: #{inspect {value, dval}} idx: #{inspect index} <- #{inspect {digits, decimals, sign}}")
    numbers =
      value
      |> number_to_digits({digits, decimals, sign})

    # Logger.warn("SET_DIGIT: numbers: #{inspect numbers} ")
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
    # Logger.warn("SET_DIGIT: numbers: post: #{inspect numbers} ")

    result = numbers |> digits_to_number({digits, decimals, sign})
    # Logger.warn("SET_DIGIT: post: #{inspect result} ")
    result
  end

  def assign_menu(
        socket,
        menu_id,
        digit_config,
        value,
        opts
      ) do
    unless is_float(value),
      do: raise(%ArgumentError{message: "value must be an integer - got #{inspect value}"})
    keys = to_digit_indexes(digit_config)
    item = socket.assigns[menu_id] || %DigitPickerLive{digit_config: digit_config, keys: keys}

    digit_values = number_to_digits(value, digit_config)

    # Logger.info("assign multi item: #{inspect digit_values} ")

    subitems =
      for {data, sub_key} <- Enum.zip(digit_values, keys), into: [] do
        scrollitems = if is_atom(sub_key), do: @sign_values, else: @digit_values
        sub_item = struct(ScrollMenuLive, [])
        sub_id = subid(menu_id, sub_key)
        values = scrollitems |> Enum.to_list()

        {sub_id, %{sub_item | id: sub_id, data: {to_string(data), data}, values: values, layout: @layout}}
      end

    # Add layout opts
    item = %{item | layout: struct(item.layout, opts)}

    # IO.inspect(item, label: :date_picker_values)
    # Logger.info("multi item: #{inspect item} ")
    # Logger.info("multi subitems: #{inspect subitems} ")

    # data = for sub_key <- digit_config
    socket! =
      socket
      |> assign([{menu_id, %{item | data: value}}])
      |> assign(subitems)

    # IO.inspect(socket!.assigns, label: :date_picker_assigns, pretty: true)
    # IO.inspect(socket!.changed, label: :date_picker_sockets, pretty: true)
    socket!
  end

  def live_render(socket_assigns, opts) do
    {:ok, menu_id} = Access.fetch(opts, :id)

    unless is_atom(menu_id),
      do: raise(%ArgumentError{message: "menu_id must be an atom - got #{inspect menu_id}"})

    menu_item =
      case Access.fetch(socket_assigns, menu_id) do
        {:ok, %DigitPickerLive{} = menu_item} ->
          menu_item

        _other ->
          raise %ArgumentError{
            message:
              "`#{__MODULE__}` requires it's struct to be stored in `assigns` under key: #{
                inspect menu_id
              }"
          }
      end

    assigns =
      menu_item
      |> Map.from_struct()

    # |> Map.put(:name, menu_id |> Atom.to_string())

    ~L"""
      <div class="date-picker-field field is-grouped" >
        <%= for key <- @keys do %>
          <%= get_in(opts, [:"#{key}", :pre]) %>
          <div class="control <%= key %> ">
            <%= ScrollMenuLive.live_render(socket_assigns, id: subid(menu_id, key)) %>
          </div>
          <%= if index(@digit_config, key) == 0 do %>
            <span class="icon has-text-centered is-size-1 has-text-white"
                  style="padding-right: 0.5em; width: 0.5em;">
                .
            </span>
          <% end %>
          <%= if rem(index(@digit_config, key), 3) == 0 && index(@digit_config, key) != 0 do %>
            <span class="icon has-text-centered is-size-1 has-text-white"
                  style="padding-right: 0.5em; width: 0.5em;">
                ,
            </span>
          <% end %>
          <%= get_in(opts, [:"#{key}", :post]) %>
        <% end %>
      </div>
    """
  end

  def index(digit_config, key) when is_atom(key) do
    -1
  end
  def index(digit_config, key) do
    elem(digit_config, 0) - elem(digit_config, 1) - key - 1
  end

end
