defmodule SpawnViewer.Mixfile do
  use Mix.Project

  def project do
    [ app: :spawn_viewer,
      version: "0.0.1",
      elixir: "~> 1.0.0-rc1",
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
      {:phoenix, "0.4.0"},
      {:cowboy, "~> 1.0.0"},
      {:timex, github: "bitwalker/timex", ref: "0.11.0"},
      {:exactor, github: "sasa1977/exactor"},
      {:jsex, github: "talentdeficit/jsex"},
      {:httpotion, github: "myfreeweb/httpotion"},
      {:poolboy, github: "devinus/poolboy"}
    ]
  end
end
