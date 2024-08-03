defmodule BulmaWidgets.Elements do
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

  require Logger

  def gettext(text) do
    text
  end

  def prettify(value, prettify \\ true) do
    if value == nil do
      ""
    else
      value |> inspect(pretty: prettify)
    end
  end

  @doc """
  The block element is a simple spacer tool. It allows sibling HTML elements to have a consistent margin between them.

  ## Examples

      <.block>
        This text is within a Bulma block
      </.block>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)

  def block(assigns) do

    ~H"""
    <div class={["block", classes(@rest)]} {extras(@rest)}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """

  ## Examples

      <.tagged label="Test:" value={@value}/>
  """
  attr(:label, :string, required: true)
  attr(:value, :string, required: true)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  def tagged(assigns) do
    size = classes(assigns.rest, [:'is-small', :'is-medium', :'is-large'])
    assigns =
      assigns
      |> assign(:size, (size == [] && :'is-medium' || size))

    ~H"""
    <div class={["tags has-addons"]} >
      <span class={["tag", @size, classes(@rest)]} >
        <%= @label %>
      </span>
      <span class={["tag", @size]}>
        <%= @value %>
      </span>
    </div>
    """
  end

  @doc """
  Wrapper for header object of size 1-6 using Bulma CSS.
  Pass `notification={true}` to create a simple centered title type.
  Has an extra CSS class `notification-title` for styling.
  """
  attr(:size, :integer, required: true)
  attr(:notification, :boolean, default: false)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)
  def title(assigns) do
    ~H"""
    <%= if @notification do %>
      <div class={["notification notification-title has-text-centered", classes(@rest)]} {extras(@rest)}>
        <h3 class={["title", "is-#{@size}", classes(@rest)]} {extras(@rest)}>
          <%= render_slot(@inner_block) %>
        </h3>
      </div>
    <% else %>
      <h3 class={["title", "is-#{@size}", classes(@rest)]} {extras(@rest)}>
        <%= render_slot(@inner_block) %>
      </h3>
    <% end %>
    """
  end

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)
  def h1(assigns) do
    ~H"""
    <h1 class={["title is-1", classes(@rest)]} {extras(@rest)}> <%= render_slot(@inner_block) %> </h1>
    """
  end

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)
  def h2(assigns) do
    ~H"""
    <h2 class={["title is-2", classes(@rest)]} {extras(@rest)}> <%= render_slot(@inner_block) %> </h2>
    """
  end

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)
  def h3(assigns) do
    ~H"""
    <h3 class={["title is-3", classes(@rest)]} {extras(@rest)}> <%= render_slot(@inner_block) %> </h3>
    """
  end

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)
  def h4(assigns) do
    ~H"""
    <h4 class={["title is-4", classes(@rest)]} {extras(@rest)}> <%= render_slot(@inner_block) %> </h4>
    """
  end

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)
  def h5(assigns) do
    ~H"""
    <h5 class={["title is-5", classes(@rest)]} {extras(@rest)}> <%= render_slot(@inner_block) %> </h5>
    """
  end

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)
  def h6(assigns) do
    ~H"""
    <h6 class={["title is-6", classes(@rest)]} {extras(@rest)}> <%= render_slot(@inner_block) %> </h6>
    """
  end

  @doc """
  The box element is a simple container with a white background, some padding, and a box shadow.
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)

  def box(assigns) do

    ~H"""
    <div class={["box", classes(@rest)]} {extras(@rest)}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  A single class to handle WYSIWYG generated content, where only HTML tags are available.

  When you can't use the CSS classes you want, or when you just want to directly use HTML tags, use content as container. It can handle almost any HTML tag.

  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: false)

  def content(assigns) do

    ~H"""
    <div class={["content", classes(@rest)]} {extras(@rest)} >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:inner_block, required: true)

  def button(assigns) do

    ~H"""
    <button class={["button", classes(@rest)]} {extras(@rest)}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  The delete element is a stand-alone element that can be used in different contexts.

  ## Examples

      <.delete is-medium></.delete>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  def delete(assigns) do

    ~H"""
    <button class={["delete", classes(@rest)]} {extras(@rest)} >
    </button>
    """
  end

  @doc """
  The delete element is a stand-alone element that can be used in different contexts.

  ## Examples

      <.delete is-medium></.delete>
  """
  attr(:base, :string, default: "fas")
  attr(:name, :string, required: true)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot(:text, required: false)

  def icon(assigns) do

    ~H"""
    <%= if @text do %>
      <span class="icon-text">
        <span class={["icon", classes(@rest)]} {extras(@rest)}>
          <i class={[@base, @name]}></i>
        </span>
      </span>
    <% else %>
      <span class="icon-text">
        <span class={["icon", classes(@rest)]} {extras(@rest)}>
          <i class={[@base, @name]}></i>
        </span>
        <span>
          <%= render_slot(@text) %>
        </span>
      </span>
    <% end %>
    """
  end

  @doc """
  Bold notification blocks, to alert your users of something

  The notification is a simple colored block meant to draw the attention to the user about something. As such, it can be used as a pinned notification in the corner of the viewport. That's why it supports the use of the delete element.

  ## Examples

      <.notification is-danger>
        Example notification!
      </.notification>
  """
  attr(:delete, :boolean, default: true)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  def notification(assigns) do

    ~H"""
    <div class={["notification", classes(@rest)]} {extras(@rest)}>
      <button class="delete" :if={@delete}></button>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  The Bulma progress bar is a simple CSS class that styles the native <progress> HTML element.

  ## Examples

      <.progress is-medium value="15" max="100"></.progress>
  """
  attr(:min, :float, default: nil)
  attr(:max, :float, default: nil)
  attr(:value, :float, required: true)

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  def progress(assigns) do

    ~H"""
    <progress class={["progress", classes(@rest), @min, @max, @value]} {extras(@rest)}>
    </progress>
    """
  end

  @doc """
  The Bulma progress bar is a simple CSS class that styles the native <progress> HTML element.

  ## Examples

      <.progress is-medium value="15" max="100"></.progress>
  """
  attr(:min, :float, default: nil)
  attr(:max, :float, default: nil)

  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  def progress_indeterminate(assigns) do

    ~H"""
    <progress class={["progress", classes(@rest)]} min={@min} max={@max} {extras(@rest)}>
      <%= render_slot(@inner_block) %>
    </progress>
    """
  end

  @doc """
  Small tag labels to insert anywhere

  The Bulma tag is a small but versatile element. It's very useful as a way to attach information to a block or other component. Its size makes it also easy to display in numbers, making it appropriate for long lists of items.

  ## Examples

      <.tag is-success>Example</.tag>
      <.tag is-success>Remove <.button delete></.button></.tag>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  attr(:delete_size, :string, default: "")
  slot(:inner_block, required: false)

  def tag(assigns) do
    ~H"""
    <span class={["tag", classes(@rest)]} {extras(@rest)}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  @doc """
  Small tag labels to insert anywhere

  The Bulma tag is a small but versatile element. It's very useful as a way to attach information to a block or other component. Its size makes it also easy to display in numbers, making it appropriate for long lists of items.

  ## Examples

      <.tags is-info>
        <:tag>
        </:tag>
      </.tags>
  """
  attr(:"has-addons", :boolean, default: false)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  slot :tag, doc: "tags" do
    attr :other, :any, doc: "class"
  end


  def tags(assigns) do
    IO.puts("tags:assigns: #{inspect(assigns, pretty: true)}")

    ~H"""
    <div class={["tags", classes(@rest), assigns |> css_maybe(:"has-addons")]}
      {extras(@rest)} >
      <span class={["tag", classes(t)]} :for={t <- @tag} >
        <%= render_slot(t) %>
      </span>
    </div>
    """
  end


  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  ## JS Commands


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
