defmodule SpawnViewer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    HTTPoison.start
    Store.start_link
    Runner.Poolboy.Supervisor.start_link
    Runner.Supervisor.Sup.start_link([])

    children = [
      # Start the endpoint when the application starts
      supervisor(SpawnViewer.Endpoint, []),
      # Start the Ecto repository
      supervisor(SpawnViewer.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(SpawnViewer.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpawnViewer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpawnViewer.Endpoint.config_change(changed, removed)
    :ok
  end

  def run(id) do
    {:ok, actor} = Store.start_link

    parent = self
    spawn_link(fn ->
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
