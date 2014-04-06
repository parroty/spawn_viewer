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

Then, open `http://localhost:4000` in the browser.

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