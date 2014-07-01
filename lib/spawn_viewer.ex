defmodule SpawnViewer do
  use Application

  @doc """
  The application callback used to start this
  application and its Dynamos.
  """
  def start(_type, _args) do
    HTTPotion.start
    Store.start
    Runner.Poolboy.Supervisor.start_link
    Runner.Supervisor.Sup.start_link([])
    SpawnViewer.Supervisor.start_link
  end

  def run(id) do
    {:ok, actor} = Store.start

    parent = self
    pid = spawn_link(fn ->
      find_module(id).run(actor)
      send parent, :ok
    end)
    wait_completion

    format_item(Store.all(actor))
  end

  defp wait_completion do
    receive do
      {:plug_conn, _}
        -> wait_completion
      :ok
        -> nil
    end
  end

  def get_code(id) do
    module = find_module(id)
    module.__info__(:compile)[:source] |> File.read!
  end

  defp find_module(id) do
    Enum.find(Config.all_modules, Config.default_module, fn(function) ->
      to_string(function[:name]) == id
    end) |> Keyword.fetch!(:module)
  end

  defp format_item(dict) do
    Enum.map(HashDict.keys(dict), fn(pid) ->
      item = HashDict.get(dict, pid)
      %PlotItem{name: inspect(pid), tag: item[:tag],
                   start_time: format_time(item[:start]), end_time: format_time(item[:end]),
                   events: format_events(item[:events])}
    end)
  end

  defp format_time(nil) do
    format_time(:erlang.now)
  end

  defp format_time({_, _, microsec} = time) do
    %{Timex.Date.from(:calendar.now_to_universal_time(time)) | ms: Float.floor(microsec / 1000)}
  end

  defp format_events(nil) do
    nil
  end

  defp format_events(events) do
    Enum.map(events, fn({time, marker}) ->
      {format_time(time), marker}
    end)
  end
end
