defmodule Runner.Chain do
  @moduledoc """
  Spawn processes which gets a value from child process,
  and then returns an incremented value.
  """

  use Runner.Base

  def run(actor) do
    last = Enum.reduce(1..config[:counts], self,
      fn(index, send_to) ->
        spawn(Runner.Chain, :counter, [send_to, actor, index])
      end)

    send last, 0
    wait_events(1)
  end

  def counter(next_pid, actor, index) do
    event_start(actor, self, tag: index)

    receive do
      n ->
        event_marker(actor, self, "receive #{n}")
        :timer.sleep(config[:delay])
        send next_pid, n + 1
    end

    event_end(actor, self)
  end
end
