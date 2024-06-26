defmodule Q.MixProject do
  use Mix.Project

  @version "2.0.0"

  def project do
    [
      app: :q,
      description: "Q makes ad-hoc Ecto queries as simple as snapping your fingers",
      version: @version,
      elixir: "~> 1.15",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "Q",
      package: package(),
      docs: [
        source_ref: "v#{@version}",
        main: "readme",
        source_url: "https://github.com/amberbit/q",
        extras: ["README.md"]
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Q.Application, []}
    ]
  end

  def package do
    [
      maintainers: ["Hubert Łępicki"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/amberbit/q"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:mappable, path: "../mappable/"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
