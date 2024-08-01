defmodule BulmaWidgets do

  @colors [
    "is-primary",
    "is-link",
    "is-info",
    "is-warning",
    "is-danger",
  ]

  @attrs [
    "is-fullwidth",
    "is-loading",
  ]

  @colors_atoms Enum.map(@colors, &String.to_atom/1)
  @attrs_atoms Enum.map(@attrs, &String.to_atom/1)

  @global_atoms @colors_atoms ++ @attrs_atoms

  def colors(), do: @colors
  def attrs(), do: @attrs
  def colors_atoms(), do: @colors_atoms
  def attrs_atoms(), do: @attrs_atoms

  @doc """
  gets css class for common BulmaWidgets attributes -- there's gotta be better way to handle this, but eh
  """
  def classes(attrs, names \\ @global_atoms) do
    attrs |> Map.take(names) |> Enum.filter(fn {_,v} -> v end) |> Enum.map(fn {k,_} -> k end)
  end

  def assign_extras(assigns) do
    extras =
      assigns.rest
      |> Map.reject(fn {_,v} -> is_map(v) end)
      |> Phoenix.Component.assigns_to_attributes([:socket, :myself, :flash])

    assigns |> Phoenix.Component.assign(:extras, extras)
  end

  def html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import BulmaWidgets.CoreComponents
      alias BulmaWidgets.Bulma
      alias BulmaWidgets.Actions
      alias BulmaWidgets.Action

      import BulmaWidgets.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

end
