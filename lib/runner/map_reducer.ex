defmodule Runner.MapReducer do
  @moduledoc """
  Parallel map-reducer, with two different types of reducer.
  Mapper just waits for some time and return values, and reducer accumulates returned values.
    `strict_order_reducer` maintains the original order which Enum.map returns.
    `loose_order_reducer` does not maintain the original order, and process it as any value arrives.
  """

  use Runner.Base

  def run(actor) do
    parent = self

    # prepare reducers, which waits until target pids are sent.
    reducers =
      [ generate_reducer(&strict_order_reducer/2, actor, parent),
        generate_reducer(&loose_order_reducer/2, actor, parent) ]

    # initiate parallel mapper.
    pids = Enum.map(randomly_sorted_values, fn(value) ->
      spawn_link(fn ->
        event_start(actor, self, tag: value)

        :timer.sleep(value * config[:delay])
        Enum.each(reducers, &(send &1, {self, value}))

        event_end(actor, self)
      end)
    end)

    # send reducers target pids to initiate processing.
    Enum.each(reducers, &(send &1, pids))
    wait_events(2)
  end

  defp randomly_sorted_values do
    :random.seed(:erlang.now)
    Enum.sort(1..config[:counts], fn(_,_) -> :random.uniform > 0.5 end)
  end

  defp generate_reducer(reducer, actor, parent) do
    spawn(fn ->
      pids = receive do pids -> pids end

      {_, sum} = reducer.(actor, pids)

      event_marker(actor, self, "sum=#{sum}")
      event_end(actor, self, delay: true)

      send parent, :ok
    end)
  end

  defp strict_order_reducer(actor, pids) do
    event_start(actor, self, tag: "StrictOrderReducer")
    Enum.reduce(pids, {0, 0}, fn(pid, {cnt, acc}) ->
      receive do
        { ^pid, val } -> process_value(actor, acc, cnt, val)
      end
    end)
  end

  defp loose_order_reducer(actor, pids) do
    event_start(actor, self, tag: "LooseOrderReducer")
    Enum.reduce(pids, {0, 0}, fn(_pid, {cnt, acc}) ->
      receive do
        { _pid, val } -> process_value(actor, acc, cnt, val)
      end
    end)
  end

  defp process_value(actor, acc, cnt, val) do
    event_marker(actor, self, "#{cnt + 1}")
    :timer.sleep(20)  # put small delay
    {cnt + 1, acc + val}
  end
end
