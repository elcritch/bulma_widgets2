defmodule BulmaWidgets.Layouts do
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


  @doc """
  A simple container to center your content horizontally

  The container is a simple utility element that allows you to center content on larger viewports. It can be used in any context, but mostly as a direct child of one of the following:

    navbar
    hero
    section
    footer

  ## Examples

      <.tag is-success></.tag>
  """
  attr(:"is-widescreen", :boolean, default: false)
  attr(:"is-fullhd", :boolean, default: false)
  attr(:"is-max-desktop", :boolean, default: false)
  attr(:"is-max-widescreen", :boolean, default: false)
  attr(:rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs())

  def container(assigns) do

    ~H"""
    <div class={["container", classes(@rest),
                assigns |> css_maybe(:"is-widescreen"),
                assigns |> css_maybe(:"is-fullhd"),
                assigns |> css_maybe(:"is-max-desktop"),
                assigns |> css_maybe(:"is-max-widescreen"),
                ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

end
