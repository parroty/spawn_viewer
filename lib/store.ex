defmodule Store do
  use ExActor.GenServer, initial_state: HashDict.new

  defcast append(pid, event, time), state: dict do
    do_append(dict, pid, event, time, nil) |> new_state
  end

  defcast append(pid, event, time, tag), state: dict do
    do_append(dict, pid, event, time, tag) |> new_state
  end

  defcall get(pid), state: dict, do: reply(HashDict.get(dict, pid))
  defcall all, state: dict, do: reply(dict)

  defp do_append(dict, pid, event, time, tag) do
    dict = HashDict.update(dict, pid, [{event, time}], &([{event, time}|&1]))
    if tag do
      dict = HashDict.update(dict, pid, [{:tag, tag}], &([{:tag, tag}|&1]))
    end
    dict
  end
end
