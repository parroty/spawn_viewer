defmodule Runner.ParallelHttp do
  @moduledoc """
  Spawn processes which sends http get requests.
  The reqeusts are executed in parallel.
  """

  use Runner.Base

  @urls ["http://www.google.com",    "http://www.google.co.jp",
         "http://www.google.com.au", "http://www.google.ch",
         "http://www.google.cn",     "http://www.google.ru",
         "http://invalidurl" ]

  def run(actor) do
    parent = self

    event_start(actor, self, tag: "Parent")
    Enum.map(@urls, fn(url) ->
      spawn_link(fn ->
        event_start(actor, self, tag: url)

        case HTTPoison.get(url) do
          {:ok, %HTTPoison.Response{status_code: status_code}} ->
            event_marker(actor, self, "ok (#{status_code})")
          {:error, %HTTPoison.Error{reason: reason}} ->
            event_marker(actor, self, "error (#{inspect reason})")
        end
        send parent, {self, url}

        event_end(actor, self)
      end)
    end)

    wait_events(Enum.count(@urls))
    event_marker(actor, self, "completed")
    :timer.sleep(1000) # some wait to avoid completing too quick.
    event_end(actor, self)
  end
end
