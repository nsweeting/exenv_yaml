defmodule ExenvYaml.MixProject do
  use Mix.Project

  @version "0.4.1"

  def project do
    [
      app: :exenv_yaml,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Exenv Yaml",
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Exenv Yaml makes loading environment variables from yaml sources easy.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nsweeting/exenv_yaml"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: "https://github.com/nsweeting/exenv_yaml"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:yamerl, "~> 0.4"},
      {:exenv, "~> 0.4"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
