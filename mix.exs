defmodule AirbrakeEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :airbrake_ex,
      version: "0.2.8",
      elixir: "~> 1.14",
      description: "Airbrake notifier for Elixir",
      package: package(),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: [
        main: AirbrakeEx,
        source_url: "https://github.com/rum-and-code/airbrake_ex"
      ]
    ]
  end

  def package() do
    [
      maintainers: ["Rum&Code", "Michał Kalbarczyk"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/rum-and-code/airbrake_ex"}
    ]
  end

  def application() do
    []
  end

  defp deps() do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.4.4"},
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4.3", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :apps_direct,
      plt_add_apps: [:hackney, :logger, :mix],
      flags: [:error_handling, :race_conditions, :unmatched_returns]
    ]
  end
end
