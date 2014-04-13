defmodule Parser do
  def parse(items) do
    Enum.sort(items, &(&1.name < &2.name))
      |> Enum.flat_map(fn(item) ->
           [parse_base_item(item)] ++ parse_events(item.name, item.events)
         end)
  end

  defp parse_base_item(item) do
    [c: [[v: item.name, f: nil],
         [v: item.tag, f: nil],
         [v: parse_date(item.start_time), f: nil],
         [v: parse_date(item.end_time), f: nil]]]
  end

  defp parse_events(_name, nil), do: []
  defp parse_events(name, events) do
    Enum.map(events, fn({time, marker}) ->
      [c: [[v: name, f: nil],
           [v: marker, f: nil],
           [v: parse_date(time), f: nil],
           [v: parse_date(time), f: nil]]]
    end)
  end

  defp parse_date(date) do
    "Date(#{date.year}, #{date.month}, #{date.day}, #{date.hour}, #{date.minute}, #{date.second}, #{date.ms})"
  end

  @doc """
  Count row items for display purpose.
  Add offsets if there're registered events as they're displayed as multi-row.
  """
  def count_row(records) do
    Enum.reduce(records, 0.0, fn(record, acc) ->
      if record.events do
        acc + 1.7  # add offsets for additional row
      else
        acc + 1
      end
    end)
  end
end
