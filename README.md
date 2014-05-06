# Spawn Viewer

Trial implementation to visualize process spawning.

## Usage

```shell
$ git clone https://github.com/parroty/spawn_viewer
$ cd spawn_viewer
$ mix deps.get
$ mix compile
$ mix server
```

Then, open `http://localhost:4000` in the browser. In the browser, select a function and click `Execute` to draw the graph.

## Sample

![htmlimage](https://raw.githubusercontent.com/parroty/spawn_viewer/ead4bdcceb8efc8f36b5cb5750bc7d1cc8a58649/image/spawn_viewer.png?w=600&h450)

```Elixir
defmodule Runner.ParallelHttp do
  @moduledoc """
  Spawn processes which sends http get requests.
  """

  use Runner.Base

  @urls ["http://www.google.com",    "http://www.google.co.jp",
         "http://www.google.com.au", "http://www.google.ch",
         "http://www.google.cn",     "http://www.google.ru"]

  def run(actor) do
    parent = self

    Enum.map(@urls, fn(url) ->
      spawn_link(fn ->
        event_start(actor, self, tag: url)

        send parent, {self, HTTPotion.get(url)}

        event_end(actor, self)
      end)
    end)

    wait_events(Enum.count(@urls))
  end
end
```

## Functions
#### Runner.RandomSleep
Spawn processes which just sleep random time and then exit.

#### Runner.Chain
Spawn processes which gets a value from child process, and then returns an incremented value.

#### Runner.ParallelHttp
Spawn processes which sends http get requests. The reqeusts are executed in parallel.

#### Runner.BinaryTree
Spawn processes which braches into 2 new processes until it reaches specified height.

#### Runner.Poolboy
Spawn processes which checkout worker from the pool and do some work. When number of running workers exeed the pool size, the following processes wait for the completion of previous ones.

#### Runner.PingPong
Spawn process to communicate each other to count-down a number.

#### Runner.TimeoutAfter
Spawn process to wait a message with after keyword. The logic in the `after` section is regularly executed until the completion message is received from the child.

#### Runner.Stream
Spawn processes to calculate value through stream and enum. Stream iteratively processes each value in the list, and Enum waits for the entire list to complete.

#### Runner.MapReducer
Parallel map-reducer, with two different types of reducer. Mapper just waits for some time and return values, and reducer accumulates returned values.

#### Runner.Supervisor
Spawn child processes and worker which are monitored by supervisors. When worker is crashed, it's automatically restarted by supervisor, and tries to restore the status from the stash.


## Notes
- `Runner.Base` module defines some helper functions to trigger events for the monitoring.
  - `event_start` and `event_end` functions take a pid (ex. self) to monitor, and a actor to store the monitoring results (which is passed as `run` function argument).
  - `event_marker` function allows to put a marker in the graph for the pid and the timing.
- `:timer.sleep` call is inserted for some locations for graph visualization purpose.
