defmodule Runner.Poolboy do
  @moduledoc """
  Spawn processes which checkout worker from the pool and do some work.
  When number of running workers exeed the pool size, the following processes wait for the
  completion of previous ones.
  """

  use Runner.Base

  def run(actor) do
    parent = self

    Enum.each(1..config[:counts], fn(n) ->
      spawn_link(fn ->
        event_start(actor, self, tag: n)

        worker = :poolboy.checkout(:mypool)
        :timer.sleep(2 * config[:delay])
        reply = :gen_server.call worker, :greet
        send parent, {self, reply}
        :poolboy.checkin(:mypool, worker)

        event_end(actor, self)
      end)
    end)

    wait_events(config[:counts])
  end
end

defmodule Runner.Poolboy.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    pool_options = [
      name: {:local, :mypool},
      worker_module: Runner.Poolboy.Worker,
      size: 3,
      max_overflow: 0
    ]

    children = [
      :poolboy.child_spec(:mypool, pool_options, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

defmodule Runner.Poolboy.Worker do
  use GenServer.Behaviour

  def start_link(state) do
    :gen_server.start_link(__MODULE__, state, [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:greet, _from, state) do
    {:reply, "Reply from #{inspect self}", state}
  end
end
