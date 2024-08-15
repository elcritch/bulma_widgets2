defmodule BulmaWidgets.MixProject do
  use Mix.Project

  def project do
    [
      app: :bulma_widgets,
      version: "0.5.8",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  def application do
    [
      mod: {BulmaWidgets.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0-rc.1"},

      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0", only: [:test, :dev]},
      {:telemetry_poller, "~> 1.0", only: [:test, :dev]},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1", only: [:test, :dev]},
      {:bandit, "~> 1.5", only: [:test, :dev]},

      {:dart_sass, "~> 0.6", only: [:test, :dev]},

      {:ex_cldr_dates_times, "~> 2.4", optional: true},
      {:ex_cldr, "~> 2.16", optional: true},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # setup: ["deps.get", "assets.setup", "assets.deploy"],
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild bulma_widgets"],
      "assets.deploy": [
        "esbuild bulma_widgets --minify",
        "sass default --no-source-map --style=compressed",
        "phx.digest"
      ]
    ]
  end
end
