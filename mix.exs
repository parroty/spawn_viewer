defmodule SpawnViewer.Mixfile do
  use Mix.Project

  def project do
    [ app: :spawn_viewer,
      version: "0.0.1",
      elixir: "~> 1.0",
      elixirc_paths: ["lib", "web"],
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { SpawnViewer, [] },
      applications: [:phoenix, :cowboy, :logger]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:phoenix, "~> 0.4.0"},
      {:cowboy, "~> 1.0"},
      {:timex, "~> 0.13"},
      {:exactor, "~> 1.0.0"},
      {:exjsx, "~> 3.1"},
      {:httpoison, "~> 0.5"},
      {:poolboy, "~> 1.4"}
    ]
  end
end
