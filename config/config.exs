import Config

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
