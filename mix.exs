defmodule ExQuickBooks.Mixfile do
  use Mix.Project

  def project do
    [app: :exquickbooks,
     version: "0.3.0",
     elixir: "~> 1.4",

     # Compilation
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,

     # Packaging
     name: "ExQuickBooks",
     description: description(),
     package: package(),
     deps: deps(),
     docs: docs(),

     # Test coverage
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [env: env(),
     extra_applications: [:logger, :httpoison]]
  end

  defp env do
    [backend: ExQuickBooks.HTTPoisonBackend]
  end

  defp description do
    """
    QuickBooks Online API client for Elixir.
    """
  end

  defp package do
    [licenses: ["ISC"],
     maintainers: ["Boulevard Labs, Inc."],
     links: %{"GitHub" => "https://github.com/Boulevard/ExQuickBooks"}]
  end

  defp docs do
    [main: ExQuickBooks]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:httpoison, "~> 0.11"},
     {:oauther, "~> 1.1"},
     {:poison, "~> 3.1"},
     {:ex_doc, "~> 0.15", only: :dev, runtime: false},
     {:excoveralls, "~> 0.6", only: :test}]
  end

  defp elixirc_paths(:test),  do: ["lib", "test/support"]
  defp elixirc_paths(_),      do: ["lib"]
end
