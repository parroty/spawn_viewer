defmodule Runner.Stream do
  @moduledoc """
  Spawn processes to calculate value through stream and enum.
  Stream iteratively processes each value in the list,
  and Enum waits for the entire list to complete.
  """

  use Runner.Base

  def run(actor) do
    parent = self

    spawn(fn -> process_stream(1..5, actor, parent) end)
    spawn(fn ->   process_enum(1..5, actor, parent) end)

    wait_events(2)
  end

  defp process_stream(range, actor, pid) do
    event_start(actor, self, tag: "Stream")

    range
    |> Stream.map(&calc_next(&1, actor))
    |> Stream.map(&calc_next(&1, actor))
    |> Enum.to_list

    event_end(actor, self, delay: true)
    send pid, :ok
  end

  defp process_enum(range, actor, pid) do
    event_start(actor, self, tag: "Enum")

    range
    |> Enum.map(&calc_next(&1, actor))
    |> Enum.map(&calc_next(&1, actor))
    |> Enum.to_list

    event_end(actor, self, delay: true)
    send pid, :ok
  end

  @doc """
  After putting delay/marker, returns the next value
  (e.g. 1 -> 11, 2 -> 22).
  """
  def calc_next(value, actor) do
    insert_delay
    event_marker(actor, self, "#{value}")

    10 * value + value
  end
end
