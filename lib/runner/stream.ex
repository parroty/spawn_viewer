defmodule Runner.Stream do
  @moduledoc """
  Spawn processes to calculate value through stream and enum.
  """

  use Runner.Base

  def run(actor) do
    parent = self

    spawn(fn -> process_stream(1..5, actor, parent) end)
    spawn(fn ->   process_enum(1..5, actor, parent) end)

    wait_events(2)
  end

  defp process_stream(range, actor, pid) do
    event_start(actor, self, tag: "stream")

    range
      |> Stream.map(&calc_next(&1, actor))
      |> Stream.map(&calc_next(&1, actor))
      |> Enum.to_list

    event_end(actor, self, delay: true)
    send pid, :ok
  end

  defp process_enum(range, actor, pid) do
    event_start(actor, self, tag: "enum")

    range
      |> Enum.map(&calc_next(&1, actor))
      |> Enum.map(&calc_next(&1, actor))
      |> Enum.to_list

    event_end(actor, self, delay: true)
    send pid, :ok
  end

  defp calc_next(value, actor) do
    :timer.sleep(config[:delay])
    event_marker(actor, self, "#{value}")
    10 * value + value
  end
end
