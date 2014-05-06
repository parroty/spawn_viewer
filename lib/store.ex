defmodule Store do
  use ExActor.GenServer, initial_state: HashDict.new

  defcast append(pid, event, time), state: dict do
    do_append(dict, pid, event, time, nil) |> new_state
  end

  defcast append(pid, event, time, tag), state: dict do
    do_append(dict, pid, event, time, tag) |> new_state
  end

  defcast append_marker(pid, time, marker), state: dict do
    case HashDict.fetch(dict, pid) do
      {:ok, item} ->
        current_events = item[:events] || []
        updated_events = [{time, marker}|current_events]
        updated_item   = Keyword.merge(item, [events: updated_events])
        HashDict.put(dict, pid, updated_item) |> new_state
      {:error} ->
        raise RuntimeError.new(message: "Store.append_marker should be called for already registered pid item.")
    end
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
