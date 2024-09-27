defmodule BulmaWidgets do
  require Logger

  @base_colors ~w(
    is-primary
    is-link
    is-info
    is-warning
    is-danger
    is-success
    is-light
  )

  @sizes ~w(
    is-small
    is-medium
    is-large
  )

  @attrs ~w(
    classes
    disabled
    is-active
    is-fullwidth
    is-hoverable
    is-loading
    is-outlined
    is-toggle
    is-boxed
    is-overlay
    is-rounded
    is-horizontal

    has-text-centered
    delete
    column
    columns

    is-four-fifths
    is-three-fifths
    is-two-fifths
    is-one-fifth

    is-three-quarters
    is-two-thirds
    is-half
    is-one-third
    is-one-quarter
    is-full

  )

  @spacing ~w(
    m-0	m-1	m-2	m-3	m-4	m-5	m-6	m-auto
    mt-0	mt-1	mt-2	mt-3	mt-4	mt-5	mt-6	mt-auto
    mr-0	mr-1	mr-2	mr-3	mr-4	mr-5	mr-6	mr-auto
    mb-0	mb-1	mb-2	mb-3	mb-4	mb-5	mb-6	mb-auto
    ml-0	ml-1	ml-2	ml-3	ml-4	ml-5	ml-6	ml-auto

    mx	mx-0	mx-1	mx-2	mx-3	mx-4	mx-5	mx-6	mx-auto

    my-0	my-1	my-2	my-3	my-4	my-5	my-6	my-auto

    p-0	p-1	p-2	p-3	p-4	p-5	p-6	p-auto

    pt-0	pt-1	pt-2	pt-3	pt-4	pt-5	pt-6	pt-auto
    pr-0	pr-1	pr-2	pr-3	pr-4	pr-5	pr-6	pr-auto
    pb-0	pb-1	pb-2	pb-3	pb-4	pb-5	pb-6	pb-auto
    pl-0	pl-1	pl-2	pl-3	pl-4	pl-5	pl-6	pl-auto

    px-0	px-1	px-2	px-3	px-4	px-5	px-6	px-auto
    py-0	py-1	py-2	py-3	py-4	py-5	py-6	py-auto
  )

  @text_colors ~w(
    has-text-primary
    has-text-link
    has-text-info
    has-text-success
    has-text-warning
    has-text-danger

    has-text-white
    has-text-black
    has-text-light
    has-text-dark

    has-text-black-bis
    has-text-black-ter
    has-text-grey-darker
    has-text-grey-dark
    has-text-grey
    has-text-grey-light
    has-text-grey-lighter
    has-text-white-ter
    has-text-white-bis
  )

  @extended_colors ~w(
    has-background-white
    has-background-black
    has-background-light
    has-background-dark
    has-background-primary
    has-background-link
    has-background-info
    has-background-success
    has-background-warning
    has-background-danger
    has-background-black-bis

    has-background-black-ter
    has-background-grey-darker
    has-background-grey-dark
    has-background-grey
    has-background-grey-light
    has-background-grey-lighter
    has-background-white-ter
    has-background-white-bis

    has-background-primary-light
    has-background-link-light
    has-background-info-light
    has-background-success-light
    has-background-warning-light
    has-background-danger-light
    has-background-primary-dark
    has-background-link-dark
    has-background-info-dark
    has-background-success-dark
    has-background-warning-dark
    has-background-danger-dark

    has-background-current
    has-background-inherit
  )

  @extended_grid_spacings ~w(
    is-col-min-1 is-col-min-2 is-col-min-3 is-col-min-4
    is-col-min-5 is-col-min-6 is-col-min-7 is-col-min-8
    is-col-min-9 is-col-min-10 is-col-min-11 is-col-min-12
    is-col-min-13 is-col-min-14 is-col-min-15 is-col-min-16
    is-col-min-17 is-col-min-18 is-col-min-19 is-col-min-20
    is-col-min-21 is-col-min-22 is-col-min-23 is-col-min-24
    is-col-min-25 is-col-min-26 is-col-min-27 is-col-min-28
    is-col-min-29 is-col-min-30 is-col-min-31 is-col-min-32

    is-gap-0	is-column-gap-0	is-row-gap-0
    is-gap-1	is-column-gap-1	is-row-gap-1
    is-gap-2	is-column-gap-2	is-row-gap-2
    is-gap-3	is-column-gap-3	is-row-gap-3
    is-gap-4	is-column-gap-4	is-row-gap-4
    is-gap-5	is-column-gap-5	is-row-gap-5
    is-gap-6	is-column-gap-6	is-row-gap-6
    is-gap-7	is-column-gap-7	is-row-gap-7
    is-gap-8	is-column-gap-8	is-row-gap-8
  )

  @modal_fxs ~w(
    modal-fx-normal
    modal-fx-fadeInScale
    modal-fx-slideRight
    modal-fx-slideLeft
    modal-fx-slideTop
    modal-fx-slideBottom
    modal-fx-fall
    modal-fx-slideFall
    modal-fx-newsPaper
    modal-fx-3dFlipVertical
    modal-fx-3dFlipHorizontal
    modal-fx-3dSign
    modal-fx-3dSignDown
    modal-fx-superScaled
    modal-fx-3dSlit
    modal-fx-3dRotateFromBottom
    modal-fx-3dRotateFromLeft
  )

  @colors @base_colors ++ @extended_colors
  @colors_atoms Enum.map(@colors, &String.to_atom/1)
  @attrs_atoms Enum.map(@attrs, &String.to_atom/1)
  @sizes_atoms Enum.map(@sizes, &String.to_atom/1)
  @spacing_atoms Enum.map(@spacing, &String.to_atom/1)
  @text_colors_atoms Enum.map(@text_colors, &String.to_atom/1)
  @extended_grid_spacings_atoms Enum.map(@extended_grid_spacings, &String.to_atom/1)
  @modal_fxs_atoms  Enum.map(@modal_fxs, &String.to_atom/1)

  @global_atoms (@colors_atoms ++ @attrs_atoms ++
                @sizes_atoms ++ @spacing_atoms ++
                @text_colors_atoms ++
                @modal_fxs_atoms ++
                @extended_grid_spacings_atoms )

  def colors(), do: @colors
  def text_colors(), do: @text_colors
  def spacing(), do: @spacing
  def attrs(), do: @attrs ++ @sizes
  def sizes(), do: @sizes
  def extended_grid_spacings(), do: @extended_grid_spacings
  def modal_fxs(), do: @modal_fxs

  def global_atoms(), do: @global_atoms
  def colors_atoms(), do: @colors_atoms
  def attrs_atoms(), do: @attrs_atoms ++ @sizes_atoms
  def sizes_atoms(), do: @sizes_atoms
  def spacing_atoms(), do: @spacing_atoms
  def text_colors_atoms(), do: @text_colors_atoms
  def extended_grid_spacings_atoms(), do: @extended_grid_spacings_atoms
  def modal_fxs_atoms(), do: @modal_fxs_atoms

  @doc """
  gets css class for common BulmaWidgets attributes -- there's gotta be better way to handle this, but eh
  """
  def classes(attrs, names \\ @global_atoms) do
    # Logger.info("CLASSES: #{inspect names}")
    attrs
    |> Map.take(names)
    |> Map.drop([:classes])
    |> Enum.filter(fn {_,v} -> v end) # has a "truthy" value
    |> Enum.map(fn {k,_} -> k end) # take names
    |> Kernel.++(attrs[:classes] || [])
  end

  @doc """
  gets css class for common BulmaWidgets attributes -- there's gotta be better way to handle this, but eh
  """
  defmacro css_maybe(assigns, class) do
    # IO.puts("class: #{inspect(class)}")
    name = Atom.to_string(class)
    quote do
      unquote(assigns)[unquote(class)] && unquote(name) || []
    end
  end

  def assign_extras(assigns) do
    extras =
      assigns.rest
      |> Map.reject(fn {_,v} -> is_map(v) end)
      |> Phoenix.Component.assigns_to_attributes([:socket, :myself, :flash])

    assigns |> Phoenix.Component.assign(:extras, extras)
  end

  def extras(rest) do
    rest
    |> Map.drop(@global_atoms)
    |> Map.reject(fn {_,v} -> is_map(v) && !(is_struct(v, Phoenix.LiveView.JS)) end)
    |> Phoenix.Component.assigns_to_attributes([:socket, :myself, :flash])
  end

  def html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import BulmaWidgets.Elements
      alias BulmaWidgets.Bulma
      alias BulmaWidgets.Actions
      alias BulmaWidgets.Event

      import BulmaWidgets.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS
    end
  end

  def css_utilities do
    quote do
      require BulmaWidgets
      import BulmaWidgets
    end
  end
  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end


end
