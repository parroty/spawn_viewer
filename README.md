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

## Notes
- `Runner.Base` module defines some helper functions to trigger events for the monitoring.
  - `event_start` and `event_end` functions take a pid (ex. self) to monitor, and a actor to store the monitoring results (which is passed as `run` function argument).
  - `event_marker` function allows to put a marker in the graph for the pid and the timing.
- `:timer.sleep` call is inserted for some locations for graph visualization purpose.
