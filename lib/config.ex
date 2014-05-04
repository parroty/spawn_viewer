defmodule Config do
  @moduledoc """
  Provides configuration settings.
  """

  def all_modules do
    [ [name: "Base",         module: Runner.Base,         target: false],
      [name: "RandomSleep",  module: Runner.RandomSleep,  target: true],
      [name: "Chain",        module: Runner.Chain,        target: true],
      [name: "ParallelHttp", module: Runner.ParallelHttp, target: true],
      [name: "BinaryTree",   module: Runner.BinaryTree,   target: true],
      [name: "Poolboy",      module: Runner.Poolboy,      target: true],
      [name: "PingPong",     module: Runner.PingPong,     target: true],
      [name: "TimeoutAfter", module: Runner.TimeoutAfter, target: true],
      [name: "Stream",       module: Runner.Stream,       target: true] ]
  end

  def target_modules do
    all_modules |> Enum.filter(fn(x) -> x[:target] == true end)
  end

  def default_module do
    List.first(target_modules)
  end
end