defmodule SpawnViewer do
  use Application.Behaviour

  @doc """
  The application callback used to start this
  application and its Dynamos.
  """
  def start(_type, _args) do
    HTTPotion.start
    Store.start
    Runner.Poolboy.Supervisor.start_link
    SpawnViewer.Dynamo.start_link([max_restarts: 5, max_seconds: 5])
  end

  def run(id) do
    {:ok, actor} = Store.start
    find_module(id).run(actor)
    format_item(Store.all(actor))
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
    Enum.map(dict.keys, fn(pid) ->
      item = HashDict.get(dict, pid)
      PlotItem.new(name: inspect(pid), tag: item[:tag],
                   start_time: format_time(item[:start]), end_time: format_time(item[:end]))
    end)
  end

  defp format_time(nil) do
    format_time(:erlang.now)
  end

  defp format_time({_, _, microsec} = time) do
    Timex.Date.from(:calendar.now_to_universal_time(time)).update(ms: Float.floor(microsec / 1000))
  end
end
