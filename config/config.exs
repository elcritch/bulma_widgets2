# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bulma_widgets,
  generators: [timestamp_type: :utc_datetime]

config :bulma_widgets,
  pubsub: BulmaWidgets.PubSub

# Configures the endpoint
config :bulma_widgets, BulmaWidgetsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: BulmaWidgetsWeb.ErrorHTML, json: BulmaWidgetsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BulmaWidgets.PubSub,
  live_view: [signing_salt: "TVdX5YE0"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  bulma_widgets: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.61.0",
  default: [
    args: ~w(css/bulma_widgets.scss ../priv/static/assets/bulma_widgets.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
