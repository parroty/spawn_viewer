defmodule SpawnViewer.Mixfile do
  use Mix.Project

  def project do
    [ app: :spawn_viewer,
      version: "0.0.1",
      build_per_environment: true,
      dynamos: [SpawnViewer.Dynamo],
      compilers: [:elixir, :dynamo, :app],
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:cowboy, :dynamo],
      mod: { SpawnViewer, [] } ]
  end

  defp deps do
    [ { :cowboy, github: "extend/cowboy" },
      { :dynamo, "~> 0.1.0-dev", github: "dynamo/dynamo" },
      { :timex, github: "bitwalker/timex"},
      { :exactor, github: "sasa1977/exactor"},
      { :jsex, github: "talentdeficit/jsex"},
      { :httpotion, github: "myfreeweb/httpotion"},
      { :poolboy, github: "devinus/poolboy"} ]
  end
end
