defmodule Parser do
  def parse(items) do
    Enum.sort(items, &(&1.name < &2.name))
      |> Enum.map(fn(item) ->
           [c: [[v: item.name, f: nil],
                [v: item.tag, f: nil],
                [v: parse_date(item.start_time), f: nil],
                [v: parse_date(item.end_time), f: nil]]]
         end)
  end

  defp parse_date(date) do
    "Date(#{date.year}, #{date.month}, #{date.day}, #{date.hour}, #{date.minute}, #{date.second}, #{date.ms})"
  end
end
