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
  require Logger

  def gettext(text) do
    text
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
  attr(:show, :boolean, default: false)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:header, required: false)
  slot(:body, required: false)

  def message(assigns) do
    ~H"""
    <article
      class={["message", classes(@rest)]}
      {extras(@rest)}
    >
      <div class="message-header" :for={header <- @header}>
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
  attr(:show, :boolean, default: false)
  attr(:position, :string, default: nil)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:background, required: false)
  slot(:content, required: true)

  def modal(assigns) do

      # phx-mounted={@show && show_modal(@id)}
      # phx-remove={hide_modal(@id)}
      # data-cancel={JS.exec(@on_cancel, "phx-remove")}

    ~H"""
    <div
      class={["modal", "modal-fx-newsPaper", classes(@rest)]}
      {extras(@rest)}
    >
      <div class="modal-background" :for={_background <- @background}>
      </div>
      <div class="modal-content" style={modal_position(@position)}>
        <%= render_slot(@content) %>
      </div>
      <button class="modal-close is-large" aria-label="close">
      </button>
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
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={_msg = Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[]}
      {extras(@rest)}
    >
      <div class="width-full py-1 px-3 position-absolute bottom-0 right-0 anim-fade-in fast">
        <%!-- <.alert state={"#{@kind}"}>
          <%= msg %>
          <.button class="flash-close">
            <.octicon name="x-16" />
          </.button>
        </.alert> --%>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")

  def flash_group(assigns) do
    ~H"""
    <div class="box" id={@id}>
      <.flash kind={:info} title={gettext("Info!")} flash={@flash} />
      <%!-- <.flash kind={:success} title={gettext("Success!")} flash={@flash} /> --%>
      <%!-- <.flash kind={:error} title={gettext("Error!")} flash={@flash} /> --%>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        <%= gettext("Hang in there while we get back on track") %>
      </.flash>
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

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(BulmaWidgets.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BulmaWidgets.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
