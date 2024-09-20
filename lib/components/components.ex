defmodule BulmaWidgets.Components do
  use BulmaWidgets, :css_utilities

  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias BulmaWidgets.Event
  import BulmaWidgets.Elements
  require Logger
  alias BulmaWidgets.Event

  @doc """
  Switch controls for Bulma CSS Framework — Pure HTML & CSS/SCSS.

  Thanks to [Justboil](https://justboil.github.io/bulma-switch-control/)

  ## Examples

      <.switch id="confirm-modal" is-rounded >
      </.switch>

  """
  attr(:checked, :boolean, default: false)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:label, default: false)

  def switch(assigns) do
    ~H"""
    <label class={["switch", classes(@rest)]}>
      <input type="checkbox" checked={@checked} {extras(@rest)} />
      <span class="check"></span>
      <span class="control-label">
        <%= render_slot(@label) %>
      </span>
    </label>
    """
  end

  @doc """
  Switch controls for Bulma CSS Framework — Pure HTML & CSS/SCSS.

  Thanks to [Justboil](https://justboil.github.io/bulma-switch-control/)

  ## Examples

  Items can be passed statically using `value` slots:

      <.dropdown id="confirm-modal" selected={:a}>
        <:label :let={sel}>
          <%= BulmaWidgets.Event.val(sel, "Dropdown") %>
        </:label>
        <:label_icon base="fas" name="fa-angle-down"/>

        <:value key={:a}> Item A </:value>
        <:value key={:b}> Item B </:value>

      </.dropdown>

  Or menu items can be passed using `values` attribute:

      <.dropdown id="confirm-modal" values={ [{1, "A"}, {2,"B"}] }>
        <:label :let={{k,l}}> <%= k %> </:label>
        <:label_icon base="fas" name="fa-angle-down"/>

        <:items :let={%{id: id, label: label, key: key, parent: parent, selected: selected}}>
          <a href="#" class={["dropdown-item", selected && "is-active" || ""]}
             phx-value-id={key} >
            Custom: <%= label %>
          </a>
        </:items>
      </.dropdown>

  """
  attr(:id, :string, required: true)
  attr(:selected, :any, default: nil)
  attr(:values, :any, default: nil, doc: "optional list of `{key, lable}` items to be used for the menu")
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:label)
  slot(:label_icon) do
    attr(:base, :string)
    attr(:name, :string)
  end
  slot(:value) do
    attr(:key, :any, required: true)
  end
  slot(:items)

  def dropdown(assigns) do

    values =
      case assigns[:values] do
        nil ->
          assigns.value |> Enum.map(fn v ->
            {v.key, ~H"<%= render_slot(v) %>"}
          end)
        values ->
          values
      end

    assigns =
      assigns
      |> assign(:values, values)

    # Logger.info("DROPDOWN: #{inspect(assigns.values, pretty: true)} SELECTED: #{inspect(assigns.selected)}")
    # Logger.info("DROPDOWN:selected: #{inspect(assigns.values |> Map.new |> Map.get(assigns.selected), pretty: true)} ")

    ~H"""
    <div
      id={@id}
      class={["dropdown", classes(@rest, attrs_atoms())]}
      phx-click={JS.toggle_class("is-active", to: "##{@id}")}
      phx-click-away={JS.remove_class("is-active", to: "##{@id}")}
    >
      <div class="dropdown-trigger">
        <button
          class={["button", classes(@rest, colors_atoms())]}
          aria-haspopup="true"
          aria-controls="dropdown-menu"
        >
          <span>
            <%= render_slot(@label, Map.new(@values) |> Map.get(@selected |> Event.key())) %>
          </span>
          <.icon base={icon.base} name={icon.name} :for={icon <- @label_icon} />
        </button>
      </div>
      <div class="dropdown-menu" role="menu">
        <div class="dropdown-content">
          <%= for {key, label} <- @values do %>
            <%= if @items == [] do %>
              <a phx-value-key={key}
                 class={["dropdown-item", key == Event.key(@selected) && "is-active" || ""]}
              >
                <%= label %>
              </a>
            <% else %>
              <%= render_slot(@items, %{
                id: @id,
                key: key,
                label: label,
                parent: @id,
                selected: key == Event.key(@selected)
              }) %>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:label)
  slot(:label_icon) do
    attr(:base, :string)
    attr(:name, :string)
  end
  slot(:value) do
    attr(:key, :any, required: true)
  end
  slot(:items, required: true)

  def dropdown_item(assigns) do
  end

  @doc """
  Colored message blocks, to emphasize part of your page

  ## Examples

      <.message id="confirm-modal" is-warning is-medium>
        <:header>
          This is a modal.
        </:header>
        <:content>
          Some message
        </:content>
      </.modal>

  """
  attr(:kind, :atom, default: nil)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:header, required: false)
  slot(:body, required: false)

  def message(assigns) do
    ~H"""
    <article class={["message", classes(@rest), (@kind && "is-#{@kind}") || ""]} {extras(@rest)}>
      <div :for={header <- @header} class="message-header">
        <%= render_slot(header) %>
      </div>
      <div class="message-body">
        <%= render_slot(@body) %>
      </div>
    </article>
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        <:background />
        <:content>
          <.message>
            <:header>
              This is a modal message
              <button class="delete"
                      aria-label="delete">
              </button>
            </:header>
            <:content>
              Some helpful message.
            </:content>
          </.message>
        </.content>
      </.modal>


  """
  attr(:id, :any, required: true)
  attr(:show, :boolean, default: false)
  attr(:position, :string, default: nil)
  attr(:rest, :global, include: colors() ++ attrs() ++ modal_fxs())

  slot(:background, required: false)
  slot(:content, required: true)

  def modal(assigns) do
    # phx-mounted={@show && show_modal(@id)}
    # phx-remove={hide_modal(@id)}
    # data-cancel={JS.exec(@on_cancel, "phx-remove")}

    ~H"""
    <div id={@id} class={["modal", classes(@rest)]} {extras(@rest)}>
      <div :for={_background <- @background} class="modal-background"></div>
      <div class="modal-content" style={@position}>
        <%= render_slot(@content) %>
      </div>
      <button class="modal-close is-large" aria-label="close"></button>
    </div>
    """
  end

  defp modal_position(position) do
    case position do
      "bottom" ->
        "position: absolute; bottom: 0px; "

      "top" ->
        "position: absolute; top: 0px; "

      _other ->
        ""
    end
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr(:id, :string, doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)

  attr(:kind, :atom,
    values: [:info, :success, :warning, :danger],
    doc: "used for styling and flash lookup"
  )

  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <nav class="level" :if={msg = Phoenix.Flash.get(@flash, @kind)} >
      <div class="level-item has-text-centered">
        <div
          id={@id}
          role="alert"
          class={["blmw-flash-item"]}
          phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
          {extras(@rest)}
        >
          <.message kind={@kind}>
            <:header>
              <p><%= "#{@kind}" |> String.capitalize() %></p>
              <button
                class="delete"
                phx-click={
                  JS.push("lv:clear-flash", value: %{key: @kind})
                  |> hide("##{@id}")
                }
                aria-label="delete"
              >
              </button>
            </:header>
            <:body>
              <%= msg %>
              <%= render_slot(@inner_block) %>
            </:body>
          </.message>
        </div>
      </div>
    </nav>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:position, :string, values: ["top", "bottom", nil], default: nil)
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  def flash_group(assigns) do
    ~H"""

    <div class={[
                 "blmw-flash-group",
                 "blmw-flash-#{@position}", classes(@rest)]}
                 id={@id}
    >
      <div class="block">
        <.flash id="success" kind={:success} title={gettext("Success!")} flash={@flash} />
        <.flash id="info" kind={:info} title={gettext("Info!")} flash={@flash} />
        <.flash id="warning" kind={:warning} title={gettext("Error!")} flash={@flash} />
        <.flash id="error" kind={:danger} title={gettext("Error!")} flash={@flash} />
        <.flash
          id="server-error"
          kind={:danger}
          title={gettext("Something went wrong!")}
          phx-disconnected={show(".phx-server-error #server-error")}
          phx-connected={hide("#server-error")}
        >
          <%= gettext("Hang in there while we get back on track") %>
        </.flash>
      </div>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr(:for, :any, required: true, doc: "the data structure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {extras(@rest)}>
      <div class="mt-10 space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end
