defmodule Runner.Supervisor do
  @moduledoc """
  Spawn child processes and worker which are monitored by supervisors.
  When worker is crashed, it's automatically restarted by supervisor, and
  tries to restore the status from the stash.
  """

  use Runner.Base

  @wait_count 4

  def run(actor) do
    event_start(actor, self, tag: "Parent")
    setup_stash(actor)
    parent = self

    process_child(actor, parent, [name: "Child (Crash)",  crash: true])
    process_child(actor, parent, [name: "Child (Normal)", crash: false])

    event_end(actor, self, delay: true)
  end

  defp setup_stash(actor) do
    event_marker(actor, self, "setup")
    :gen_server.cast(:supervise_worker, {:setup, {actor, 0}})
    insert_delay
  end

  defp process_child(actor, parent, [name: name, crash: crash]) do
    spawn(fn ->
      event_start(actor, self, tag: name)

      send_normal_message(actor)
      send_normal_message(actor)

      if crash, do: send_crash_message(actor)

      send_normal_message(actor)

      send(parent, {self, :ok})

      event_marker(actor, self, "reply")
      event_end(actor, self)
    end)

    receive_message(actor)
  end

  defp send_normal_message(actor) do
    event_marker(actor, self, "call")
    :gen_server.call(:supervise_worker, :call)
    insert_delay
  end

  defp send_crash_message(actor) do
    event_marker(actor, self, "crash")
    event_end(actor, self)
    :gen_server.call(:supervise_worker, :crash)
  end

  defp receive_message(actor) do
    receive do
      _ ->
        event_marker(actor, self, "success")
    after
      @wait_count * config[:delay] ->
        event_marker(actor, self, "timeout")
    end
  end
end

defmodule Runner.Supervisor.Sup do
  @moduledoc """
  Main supervisor module, which manages Stash and SubSup.
  """

  use Supervisor

  def start_link(_) do
    {:ok, sup} = :supervisor.start_link(__MODULE__, [])
    start_workers(sup)
    {:ok, sup}
  end

  def start_workers(sup) do
    {:ok, _stash} = :supervisor.start_child(sup, worker(Runner.Supervisor.Stash, []))
    :supervisor.start_child(sup, supervisor(Runner.Supervisor.SubSup, []))
  end

  def init([]) do
    supervise([], strategy: :one_for_one)
  end
end

defmodule Runner.Supervisor.SubSup do
  @moduledoc """
  Sub supervisor module, which manages Worker.
  """

  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [ worker(Runner.Supervisor.Worker, []) ]
    supervise(children, strategy: :one_for_one)
  end
end

defmodule Runner.Supervisor.Stash do
  @moduledoc """
  Stash module to preserve the actor and number.
  """

  use GenServer
  use Runner.Base

  @default_value {nil, 0}

  def start_link do
    :gen_server.start_link(
      {:local, :supervise_stash}, __MODULE__, @default_value, [])
  end

  def init(current) do
    {:ok, current}
  end

  def handle_call(:get, _from, current = {actor, _number}) do
    if actor, do: event_marker(actor, self, "get")
    {:reply, current, current}
  end

  def handle_cast({:put, {actor, number}}, _current) do
    event_marker(actor, self, "put #{number}")

    {:noreply, {actor, number}}
  end

  def handle_cast({:setup, {actor, number}}, _current) do
    event_start(actor, self, tag: "Stash")
    event_marker(actor, self, "setup")

    {:noreply, {actor, number}}
  end
end

defmodule Runner.Supervisor.Worker do
  @moduledoc """
  Worker module to do some processing based on the requests from childs.
  """

  use GenServer
  use Runner.Base

  def start_link do
    :gen_server.start_link(
      {:local, :supervise_worker}, __MODULE__, [], [])
  end

  def init(_) do
    {actor, number} = :gen_server.call(:supervise_stash, :get)

    if actor do
      event_start(actor, self, tag: "Worker")
      event_marker(actor, self, "restart")
    end

    {:ok, {actor, number}}
  end

  def handle_cast({:setup, {actor, number}}, _) do
    event_start(actor, self, tag: "Worker")
    event_marker(actor, self, "setup")

    :gen_server.cast(:supervise_stash, {:setup, {actor, number}})
    {:noreply, {actor, number}}
  end

  def handle_call(:call, _from, {actor, number}) do
    event_marker(actor, self, "call")

    :gen_server.cast(:supervise_stash, {:put, {actor, number + 1}})
    {:reply, :call, {actor, number + 1}}
  end

  def handle_call(:crash, _from, {actor, _number}) do
    event_marker(actor, self, "crash")
    event_end(actor, self)

    divide(1, 0)
    {:reply, :crash, nil}  # should not reach here
  end

  defp divide(a, b) do
    a / b
  end
end
