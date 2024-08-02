defmodule BulmaWidgets.Layouts do
  use BulmaWidgets, :css_utilities

  @moduledoc """
  Bulma Layouts
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
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
          {extra(@rest)} >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """

  ## Examples

      <.hero is-success></.hero>
  """
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  def hero(assigns) do

    ~H"""
    <section class={["hero", classes(@rest)]} {extra(@rest)}>
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

end
