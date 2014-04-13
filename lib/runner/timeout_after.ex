defmodule Runner.TimeoutAfter do
  @moduledoc """
  Spawn process to wait a message with after keyword.
  """

  use Runner.Base

  @count 5

  def run(actor) do
    parent = self
    event_start(actor, self, tag: "Parent")

    child = spawn_link(fn ->
      event_start(actor, self, tag: "Child")
      receive_message(actor, parent)
      event_end(actor, self)
    end)

    :timer.sleep(config[:delay] * @count)
    send child, {:ok, self}

    wait_events(1)
    event_end(actor, self)
  end

  def receive_message(actor, pid) do
    receive do
      {:ok, pid} ->
        event_marker(actor, self, "completed")
        :timer.sleep(config[:delay])
        send pid, :ok
    after
      config[:delay] ->
        event_marker(actor, self, "timeout")
        receive_message(actor, self)
    end
  end
end
