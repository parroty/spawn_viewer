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
