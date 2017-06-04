defmodule Lonely.Mixfile do
  use Mix.Project

  def project do
    [app: :lonely,
     version: "0.3.0",
     description: description(),
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases(),

     # Package
     package: [files: ["lib", "mix.exs", "README.md", "LICENSE"],
               maintainers: ["Arnau Siches"],
               licenses: ["MIT"],
               links: %{"GitHub" => "https://github.com/arnau/lonely"}],

     # Docs
     name: "Lonely",
     source_url: "https://github.com/arnau/lonely",
     docs: [main: "Lonely",
            extras: ["README.md"]]]
  end

  def description do
    """
    Helpers to pipe through results (`{:ok, a} | {:error, e}`).
    """
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
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
    [{:credo, "~> 0.7", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
     {:ex_doc, "~> 0.14", only: [:dev], runtime: false}]
  end

  defp aliases do
    [check: ["credo --strict", "dialyzer"]]
  end
end
