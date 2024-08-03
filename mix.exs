defmodule BulmaWidgets.MixProject do
  use Mix.Project

  def project do
    [
      app: :bulma_widgets,
      version: "0.4.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      # {:swoosh, "~> 1.5"},
      # {:finch, "~> 0.13"},
      # {:telemetry_metrics, "~> 1.0", override: true},
      # {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      # {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},

      {:dart_sass, "~> 0.6", only: [:test, :dev]},

      {:ex_cldr_dates_times, "~> 2.4", optional: true},
      {:ex_cldr, "~> 2.16", optional: true},


    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.deploy"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.deploy": [
        # "esbuild bulma_widgets --minify",
        "sass default --no-source-map --style=compressed",
        "phx.digest"
      ]
    ]
  end

end
