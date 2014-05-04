defmodule Runner.Base do
  @moduledoc """
  Provides base implementation and utilities for runners.
  """

  defmacro __using__(_) do
    quote do
      @doc """
      Base configuration setting.
        counts: number of processes to spawn.
        wait: delay in milliseconds
      """
      def config do
        [counts: 10, delay: 500]
      end

      def run(act) do
        raise "run/1 is not implemented for the specified module."
      end
      defoverridable [run: 1]

      def event_start(actor, pid, options \\ []) do
        Store.append(actor, pid, :start, :erlang.now, options[:tag])
        if options[:delay] do
          :timer.sleep(config[:delay])
        end
      end

      def event_end(actor, pid, options \\ []) do
        if options[:delay] do
          :timer.sleep(config[:delay])
        end
        Store.append(actor, pid, :end, :erlang.now)
      end

      def event_marker(actor, pid, marker) do
        Store.append_marker(actor, pid, :erlang.now, marker)
      end

      def wait_events(n) do
        if n > 0 do
          receive do
            _ -> wait_events(n - 1)
          end
        end
      end
    end
  end
end
