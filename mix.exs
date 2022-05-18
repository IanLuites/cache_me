defmodule CacheMe.MixProject do
  use Mix.Project

  def project do
    [
      app: :cache_me,
      description: "Cache functions without hassle.",
      version: "0.0.5",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "Cache Me",
      source_url: "https://github.com/IanLuites/cache_me",
      homepage_url: "https://github.com/IanLuites/cache_me",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def package do
    [
      name: :cache_me,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/cache_me",
        "lib/cache_me.ex",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/IanLuites/cache_me"
      }
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :logger],
      mod: {CacheMe.Application, []}
    ]
  end

  defp deps do
    [
      {:benchee, ">= 0.0.0", only: [:dev]},
      {:heimdallr, ">= 0.0.0", only: [:dev, :test]}
    ]
  end
end
