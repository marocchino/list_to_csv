defmodule ListToCsv.MixProject do
  use Mix.Project

  @version "0.1.1"
  @scm_url "https://github.com/marocchino/list_to_csv"

  def project do
    [
      app: :list_to_csv,
      version: @version,
      elixir: "~> 1.11",
      description: description(),
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => @scm_url},
        files: ~w(lib mix.exs README.md)
      ],
      start_permanent: Mix.env() == :prod,
      source_url: @scm_url,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Convert a list of nested maps to `list(list(String.t))` or CSV. Can be used with GraphQL."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
