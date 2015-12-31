defmodule Config do
  @moduledoc """
  Provides configuration settings.
  """

  def all_modules do
    [ [name: "Base",         module: Runner.Base,         src: "lib/runner/base.ex", exclude: true],
      [name: "RandomSleep",  module: Runner.RandomSleep,  src: "lib/runner/random_sleep.ex"],
      [name: "Chain",        module: Runner.Chain,        src: "lib/runner/chain.ex"],
      [name: "ParallelHttp", module: Runner.ParallelHttp, src: "lib/runner/parallel_http.ex"],
      [name: "BinaryTree",   module: Runner.BinaryTree,   src: "lib/runner/binary_tree.ex"],
      [name: "Poolboy",      module: Runner.Poolboy,      src: "lib/runner/poolboy.ex"],
      [name: "PingPong",     module: Runner.PingPong,     src: "lib/runner/ping_pong.ex"],
      [name: "TimeoutAfter", module: Runner.TimeoutAfter, src: "lib/runner/timeout_after.ex"],
      [name: "Stream",       module: Runner.Stream,       src: "lib/runner/stream.ex"],
      [name: "MapReducer",   module: Runner.MapReducer,   src: "lib/runner/map_reducer.ex"],
      [name: "Supervisor",   module: Runner.Supervisor,   src: "lib/runner/supervisor.ex"] ]
  end

  def target_modules do
    all_modules |> Enum.filter(fn(x) -> x[:exclude] != true end)
  end

  def default_module do
    List.first(target_modules)
  end
end