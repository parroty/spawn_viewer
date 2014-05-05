defmodule Runner.TimeoutAfter do
  @moduledoc """
  Spawn process to wait a message with after keyword.
  The logic in the `after` section is regularly executed until the
  completion message is received from the child.
  """

  use Runner.Base

  @count 5

  def run(actor) do
    event_start(actor, self, tag: "Parent")

    child = spawn_link(fn ->
      event_start(actor, self, tag: "Child")
      receive_message(actor)
      event_end(actor, self)
    end)

    :timer.sleep(config[:delay] * @count)
    send child, {:ok, self}

    wait_events(1)
    event_end(actor, self)
  end

  def receive_message(actor) do
    receive do
      {:ok, pid} ->
        event_marker(actor, self, "completed")
        :timer.sleep(config[:delay])
        send pid, :ok
    after
      config[:delay] ->
        event_marker(actor, self, "timeout")
        receive_message(actor)
    end
  end
end
