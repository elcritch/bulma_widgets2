defmodule BulmaWidgets.Layouts do
  use BulmaWidgets, :css_utilities

  @moduledoc """
  Bulma Layouts
  """
  use Phoenix.Component

  require Logger


  @doc """
  A simple container to center your content horizontally

  The container is a simple utility element that allows you to center content on larger viewports. It can be used in any context, but mostly as a direct child of one of the following:

    navbar
    hero
    section
    footer

  """
  attr(:"is-widescreen", :boolean, default: false)
  attr(:"is-fullhd", :boolean, default: false)
  attr(:"is-max-desktop", :boolean, default: false)
  attr(:"is-max-widescreen", :boolean, default: false)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:title, doc: "the title")
  slot(:subttitle, doc: "the title")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def container(assigns) do

    ~H"""
    <div class={["container", classes(@rest),
                assigns |> css_maybe(:"is-widescreen"),
                assigns |> css_maybe(:"is-fullhd"),
                assigns |> css_maybe(:"is-max-desktop"),
                assigns |> css_maybe(:"is-max-widescreen"),
                ]}
          {extras(@rest)} >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  An imposing hero banner to showcase something

  ## Examples

      <.hero is-success>
        <:title>Hero Title</:title>
        <:subtitle>Hero Title</:subtitle>
      </.hero>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:title, doc: "hero title")
  slot(:subtitle, doc: "hero subtitle")

  def hero(assigns) do
    ~H"""
    <section class={["hero", classes(@rest)]} {extras(@rest)}>
      <div class="hero-body">
        <p class="title" :if={@title} >
          <%= render_slot(@title) %>
        </p>
        <p class="subtitle" :if={@subtitle}>
          <%= render_slot(@subtitle) %>
        </p>
      </div>
    </section>
    """
  end

  @doc """
  An imposing full height hero banner to showcase something

  ## Examples

      <.hero_fullheight is-success>
        <:head>
          ...
        </:head>
        <:title>Hero Title</:title>
        <:subtitle>Hero Title</:subtitle>
        <:foot>
          ...
        </:foot>

      </.hero_fullheight>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:head, doc: "hero header")
  slot(:title, doc: "hero title")
  slot(:subtitle, doc: "hero subtitle")
  slot(:foot, doc: "hero foot")

  def hero_fullheight(assigns) do
    ~H"""
    <section class={["hero", classes(@rest)]} {extras(@rest)}>
      <div class="hero-head">
        <%= render_slot(@head) %>
      </div>
      <div class="hero-body">
        <p class="title" :if={@title} >
          <%= render_slot(@title) %>
        </p>
        <p class="subtitle" :if={@subtitle}>
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="hero-foot">
        <%= render_slot(@foot) %>
      </div>
    </section>
    """
  end

  @doc """
  A simple container to divide your page into sections, like the one you’re currently reading

  The section components are simple layout elements with responsive padding. They are best used as direct children of body.

  ## Examples

      <.section>
        <:title>Section</:title>
        <:subtitle>
          Some longer text here
        </:subtitle>
      </.section>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())
  slot(:title, doc: "hero title")
  slot(:subtitle, doc: "hero subtitle")

  def section(assigns) do
    ~H"""
    <section class={["section", classes(@rest)]} {extras(@rest)}>
      <h1 class="title" :if={@title} >
        <%= render_slot(@title) %>
      </h1>
      <h2 class="subtitle" :if={@subtitle}>
        <%= render_slot(@subtitle) %>
      </h2>
    </section>
    """
  end

end
