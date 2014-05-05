defmodule Runner.RandomSleep do
  @moduledoc """
  Spawn processes which just sleep random time and then exit.
  """

  use Runner.Base

  def run(actor) do
    parent = self

    :random.seed(:erlang.now)
    values = Enum.map(1..config[:counts], fn(_) -> :random.uniform(config[:counts]) end)

    Enum.each(values, fn(v) ->
      spawn_link(fn ->
        event_start(actor, self, tag: "#{v} sec")

        :timer.sleep(v * config[:delay])
        send parent, {self, v}

        event_end(actor, self)
      end)
    end)

    wait_events(config[:counts])
  end
end
