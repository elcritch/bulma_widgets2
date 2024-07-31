defmodule BulmaWidgets.Widgets.ActionButton do
  use Phoenix.LiveComponent
  use BulmaWidgets, :html_helpers

  require Logger

  def mount(socket) do
    # Logger.debug("action_button:comp:mount: #{inspect(socket, pretty: true)}")
    {:ok, socket}
  end

  def update(assigns, socket) do
    # Logger.debug("action_button:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!
    # assigns = assigns |> Actions.handle_triggers()

    {:ok,
     socket
     |> assign(assigns)
     |> Actions.assign_cached()}
  end

  attr :id, :string, required: true
  attr :loading, :boolean, default: false
  attr :extra_actions, :list, default: []
  attr :rest, :global, include: BulmaWidgets.colors() ++ BulmaWidgets.attrs()

  def render(assigns) do
    # Logger.debug("#{__MODULE__}:render: assigns:rest: #{inspect(assigns.rest |> Map.keys(), pretty: true)}")

    assigns =
      assigns
      |> BulmaWidgets.assign_extras()

    # Logger.warning("#{__MODULE__}:ACTION_BUTTON: assigns: #{inspect(assigns |> Map.delete(:rest) |> Map.keys(), pretty: true, limit: :infinity)}")
    # Logger.warning("#{__MODULE__}:ACTION_BUTTON: loading: #{inspect(assigns |> Map.take(["loading", :loading]), pretty: true, limit: :infinity)}")
    # Logger.warning("#{__MODULE__}:ACTION_BUTTON: rest: #{inspect(assigns.rest |> Map.delete(:socket) |> Map.delete(:extra_actions), pretty: true, limit: :infinity)}")
    # Logger.warning("#{__MODULE__}:ACTION_BUTTON: cached: #{inspect(assigns.cached, pretty: true, limit: :infinity)}")

    ~H"""
    <button
      id={@id}
      class={["button", (@loading && "is-loading") || "", BulmaWidgets.classes(@rest)]}
      phx-click={JS.push("button-action", target: @rest.myself)}
      phx-value-name={@id}
      phx-target={@rest.myself}
      {@extras}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def handle_event(
        "button-action",
        %{"name" => name} = values,
        socket
      ) do
    # Logger.info("button-action:click!: target: #{name} values: #{inspect values}")
    actions = socket.assigns |> Actions.all_actions()

    event_action =
      %Action{
        id: name,
        data: {name, values |> Map.delete("name")},
        state: socket.assigns,
        socket: socket
      }
      |> Action.apply(actions)

    {:noreply, event_action.socket}
  end

  def key({k, _v}), do: k
  def key(k), do: k
  def value({_k, v}), do: v
  def value(k), do: k
end
