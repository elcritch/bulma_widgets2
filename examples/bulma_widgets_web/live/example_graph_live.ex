defmodule BulmaWidgetsWeb.ExampleGraphLive do
  use BulmaWidgetsWeb, :live_view

  use BulmaWidgets.Actions, pubsub: BulmaWidgetsWeb.PubSub
  alias BulmaWidgets.Widgets.SelectionMenu
  alias Plotex.Output.Options

  require Logger

  def mount(_params, _session, socket) do
     socket =
      socket
      |> assign(:shared, %{})
      |> assign(:page_title, "Widget Examples")
      |> assign(:menu_items, BulmaWidgetsWeb.MenuUtils.menu_items())
      |> assign(:wiper_options, nil)
      |> assign(:moving_count, 5)
      |> assign(:key_selection, "qinv")
      |> assign(:kalman, Kalman.new(
            a: 1.0,  # No process innovation
            c: 1.0,  # Measurement
            b: 0.0,  # No control input
            q: 0.01,  # Process covariance
            r: 1.0,  # Measurement covariance
            x: 20.0,  # Initial estimate
            p: 1.0  # Initial covariance
      ))
      |> generate_data()
      |> update_estimates()
      |> put_graph()

    {:ok, socket}
  end

  def handle_info({:updates, assigns}, socket) do
    {:noreply, Actions.update(assigns, socket)}
  end

  def generate_data(socket) do
    xdata = 1..200 |> Enum.map(&(1.0*&1))
    random_data_init = 1..100 |> Enum.map(fn _ -> :rand.normal(20.0, 0.03) end)
    random_data_then = 1..100 |> Enum.map(fn _ -> :rand.normal(22.0, 0.03) end)
    random_data = random_data_init ++ random_data_then

    random_data =
      random_data
      |> List.replace_at(40, 23.55)

    socket
    |> assign(xdata: xdata)
    |> assign(random_data: random_data)
  end

  def update_estimates(socket) do
    %{xdata: xdata, random_data: random_data,
      kalman: kalman, moving_count: moving_count} = socket.assigns

    moving_est = random_data |> box_average(moving_count)

    {_, kalman_est} =
      for yy <- random_data, reduce: {kalman, []} do
        {k, prev} ->
          # IO.puts("YY: #{inspect yy}")
          k! = Kalman.step(0.0, yy, k)
          {k!, [Kalman.estimate(k!) | prev ]}
      end

    kalman_est = kalman_est |> Enum.reverse()

    socket
    |> assign(kalman_est: kalman_est)
    |> assign(moving_est: moving_est)
  end


  def put_graph(socket) do
    %{xdata: xdata, random_data: random_data,
      kalman_est: kalman_est, moving_est: moving_est} = socket.assigns

    plt =
      Plotex.plot(
        [
          {xdata, random_data},
          {xdata, kalman_est},
          {xdata, moving_est},
        ],
        xaxis: [
          ticks: 5,
          padding: 0.05
        ]
      )
    opts = %Options{
      xaxis: %Options.Axis{label: %Options.Item{rotate: 35, offset: 5.0}},
      yaxis: %Options.Axis{label: %Options.Item{offset: 5.0}}
    }

    socket
    |> assign(names: ["Random", "Kalman", "Moving"])
    |> assign(plot: plt)
    |> assign(plot_opts: opts)
  end

  def render(assigns) do

    ~H"""
    <div id="widget">
      <style>
        :root {
          --graph-color0: rgba(217, 0, 0, 0.7);
          --graph-color1: rgba(0, 0, 0, 0.7);
          --graph-color2: rgba(0, 217, 11, 0.7);
          --graph-color3: rgba(217, 94, 0, 0.7);
        }

        <%= raw Plotex.Output.Svg.default_css() %>

        .plx-data .plx-data-line { stroke-width: 0.3; }

        // graph 0
        g.plx-data > g.plx-dataset-0 > polyline { display: none; }
        .plx-data .plx-dataset-0 .plx-data-line { stroke: rgba(0,0,0,0.0); }
        #marker-0 > .plx-data-point { stroke: var(--graph-color0); fill: var(--graph-color0); }

        // graph 1
        g.plx-data > g.plx-dataset-1 > polyline { stroke: var(--graph-color1); }
        g.plx-data > g.plx-dataset-1 > polyline { stroke: var(--graph-color1); }
        #marker-1 > .plx-data-point { stroke: var(--graph-color1); fill: var(--graph-color1); }

        // graph 2
        g.plx-data > g.plx-dataset-2 > polyline { stroke: var(--graph-color2); }
        g.plx-data > g.plx-dataset-2 > polyline { stroke: var(--graph-color2); }
        #marker-2 > .plx-data-point { stroke: var(--graph-color2); fill: var(--graph-color2); }

        .plx-graph {
          height: 500px;
          width: 1200px;
          stroke-width: 0.1;
        }


      </style>
      <.tagged is-link label="Wiper Options:" value={Event.key(@shared[:wiper_options]) }/>

      <.live_component
        id="dashboard-graph-svg"
        module={Plotex.Output.Svg}
        class="plx-graph"
        plot={@plot}
        opts={@plot_opts} >
        <:custom_svg>
          <%!-- <text class="plx-key-title" fill="lightgrey" x="130" y="-7"
                  font-size="4" dominant-baseline="middle" >
            Time
          </text>
          <%= for {name, idx} <- Enum.with_index(@names) do %>
            <% cx = 24*idx+24 %>
            <circle class={"plx-key-#{idx}"} cx={cx} cy="-95" r="1.5" />
            <text class={"plx-key-#{idx}"} x={cx+3} y="-95" dominant-baseline="middle" >
              <%= name %>
            </text>
          <% end %> --%>
        </:custom_svg>
      </.live_component>

      <.box is-fullwidth
            phx-window-keydown="slide-key"
            style="width: 50%;">
        <.tagged label="Q'"
                  is-info={@key_selection == "qinv"}
                  phx-click="key_select"
                  phx-value-item="qinv"
                  is-fullwidth>
          <span style="width: 3em;"
          >
            <%= (1.0/@kalman.q) |> round() %>
          </span>
          <input class="slider is-info is-large" type="range"
                step="0.1" min="1" max="200" value={1.0/@kalman.q}
                phx-click="slide-q-inv"
                style="width: 40em;"
          >
        </.tagged>

        <.tagged label="Moving Average"
                  is-info={@key_selection == "moving"}
                  phx-click="key_select"
                  phx-value-item="moving"
                  is-fullwidth>
          <span style="width: 3em;">
            <%= (@moving_count) |> round() %>
          </span>
          <input class="slider is-info is-large" type="range"
                step="0.1" min="1" max="100" value={@moving_count}
                phx-click="slide-moving"
                style="width: 40em;"
          >
        </.tagged>
      </.box>
    </div>
    """
  end

  def handle_event("key_select", params, socket) do
    Logger.warning("key_select: #{inspect(params)}")
    %{"item" => item} = params

    socket =
      socket
      |> assign(key_selection: item)
    {:noreply, socket}
  end

  def handle_event("slide-q-inv", params, socket) do
    %{"value" => value} = params
    {q!, ""} = Float.parse(value)

    kalman = socket.assigns.kalman
    socket =
      socket
      |> assign(kalman: %{kalman | q: 1/q!})
      |> update_estimates()
      |> put_graph()

    {:noreply, socket}
  end

  def handle_event("slide-key", params, socket) do
    Logger.info("key: slide-key: #{inspect(params)}")

    %{"key" => key} = params

    kalman = socket.assigns.kalman
    moving_count = socket.assigns.moving_count
    key_selection = socket.assigns.key_selection

    {update, adj} =
      case key do
        "ArrowLeft" ->
          {true, -1}
        "ArrowRight" ->
          {true, +1}
        _other ->
          {false, 0}
      end

    socket =
      case {update, key_selection, key} do
        {false, selection, k} when k == "ArrowDown" or k == "ArrowUp" ->
          case selection do
            "qinv" ->
              socket |> assign(:key_selection, "moving")
            "moving" ->
              socket |> assign(:key_selection, "qinv")
          end
        {true, "qinv", _} ->
          socket
          |> assign(kalman: %{kalman | q: 1.0/max(1.0/kalman.q + adj, 1.0)})
          |> update_estimates()
          |> put_graph()
        {true, "moving", _} ->
          socket
          |> assign(moving_count: moving_count + adj)
          |> update_estimates()
          |> put_graph()
        {false, _, _} ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("slide-moving", params, socket) do
    %{"value" => value} = params
    {moving_count, _} = Integer.parse(value)

    socket =
      socket
      |> assign(moving_count: moving_count)
      |> update_estimates()
      |> put_graph()

    {:noreply, socket}
  end

  ## very dumb box average, but avoids shortening the sample
  def box_average(data, 0) do
    data
  end

  def box_average(data, count) do
    data
    |> Enum.map_reduce([], fn x, acc ->
      group = Enum.take([x | acc], count)
      {Enum.sum(group) / Enum.count(group), group}
    end)
    |> (fn {data, _} -> data end).()
  end

end
