defmodule Runner.PingPong do
  @moduledoc """
  Spawn process to communicate each other to count-down a number.
  """

  use Runner.Base

  def run(actor) do
    parent = self
    event_start(actor, self, tag: "Parent")

    child = spawn_link(fn ->
      event_start(actor, self, tag: "Child")
      send parent, config[:counts]
      receive_message(parent, actor)
    end)

    receive_message(child, actor)
  end

  def receive_message(pid, actor) do
    receive do
      0 ->
        event_end(actor, pid)
      count ->
        event_marker(actor, self, "receive #{count}")
        :timer.sleep(config[:delay])

        send pid, count - 1
        receive_message(pid, actor)
    end
  end
end
