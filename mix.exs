defmodule Schemer.MixProject do
  use Mix.Project

  def project do
    [
      app: :schemer,
      version: "0.1.0",
      elixir: "~> 1.14",
      description: "The Schemer.",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: [
        name: "schemer",
        licenses: ["MIT"],
        files: ~w(lib mix.exs mix.lock .tool-versions README.md),
        links: %{"GitHub" => "https://github.com/Byzanteam/schemer"}
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:typed_struct, "~> 0.3.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    ["code.check": ["format --check-formatted", "credo --strict", "dialyzer"]]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/support"]
  end

  defp elixirc_paths(_) do
    ["lib"]
  end
end
