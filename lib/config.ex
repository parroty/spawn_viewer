defmodule Config do
  @moduledoc """
  Provides configuration settings.
  """

  def all_modules do
    [ [name: "Base",         module: Runner.Base,        exclude: true],
      [name: "RandomSleep",  module: Runner.RandomSleep               ],
      [name: "Chain",        module: Runner.Chain                     ],
      [name: "ParallelHttp", module: Runner.ParallelHttp              ],
      [name: "BinaryTree",   module: Runner.BinaryTree                ],
      [name: "Poolboy",      module: Runner.Poolboy                   ],
      [name: "PingPong",     module: Runner.PingPong                  ],
      [name: "TimeoutAfter", module: Runner.TimeoutAfter              ],
      [name: "Stream",       module: Runner.Stream                    ],
      [name: "MapReducer",   module: Runner.MapReducer                ] ]
  end

  def target_modules do
    all_modules |> Enum.filter(fn(x) -> x[:exclude] != true end)
  end

  def default_module do
    List.first(target_modules)
  end
end