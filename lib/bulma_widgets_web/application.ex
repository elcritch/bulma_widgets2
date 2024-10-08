defmodule BulmaWidgets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:bulma_widgets, :dev_server) == true do
        [
          # BulmaWidgetsWeb.Telemetry,
          {DNSCluster, query: Application.get_env(:bulma_widgets, :dns_cluster_query) || :ignore},
          {Phoenix.PubSub, name: BulmaWidgetsWeb.PubSub},
          BulmaWidgets.Cache,
          # Start a worker by calling: BulmaWidgets.Worker.start_link(arg)
          # {BulmaWidgets.Worker, arg},
          # Start to serve requests, typically the last entry
          BulmaWidgetsWeb.Endpoint
        ]
      else
        []
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BulmaWidgets.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BulmaWidgetsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
