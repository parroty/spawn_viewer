defmodule Runner.BinaryTree do
  @moduledoc """
  Spawn processes which braches into 2 new processes
  until it reaches specified height.
  """

  use Runner.Base

  @height 4

  def run(actor) do
    call_binary(@height, [], actor)
  end

  def call_binary(0, _acc, _actor) do
    nil
  end

  def call_binary(h, acc, actor) do
    parent = self

    spawn_link(fn ->
      process_spawn(actor, h, parent, [:left | acc])
    end)

    spawn_link(fn ->
      process_spawn(actor, h, parent, [:right | acc])
    end)

    wait_events(2)
  end

  def process_spawn(actor, h, parent, tag) do
    event_start(actor, self, [tag: inspect(tag), delay: true])

    ret = call_binary(h - 1, tag, actor)
    send parent, {ret, self}

    event_end(actor, self)
  end
end
