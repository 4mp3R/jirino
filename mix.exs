defmodule Jirino.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jirino,
      version: "0.1.0",
      elixir: "~> 1.5",
      escript: [main_module: Jirino],
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:momento, "~> 0.1.1"},

      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},

      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
