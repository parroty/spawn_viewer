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

      @doc """
      Record start event for the specifid pid.
      """
      def event_start(actor, pid, options \\ []) do
        Store.append(actor, pid, :start, :os.timestamp, options[:tag])
        if options[:delay], do: insert_delay
      end

      @doc """
      Record end event for the specifid pid.
      """
      def event_end(actor, pid, options \\ []) do
        if options[:delay], do: insert_delay
        Store.append(actor, pid, :end, :os.timestamp)
      end

      @doc """
      Put marker string for describing the status of the specified pid.
      """
      def event_marker(actor, pid, marker) do
        Store.append_marker(actor, pid, :os.timestamp, marker)
      end

      @doc """
      Wait specified number of messages to receive. Message itself will be discarded.
      """
      def wait_events(n, timeout \\ 30_000) do
        if n > 0 do
          receive do
            _ ->
              wait_events(n - 1)
          after
            timeout -> nil
          end
        end
      end

      @doc """
      Insert delays for easier to draw graph.
      """
      def insert_delay do
        :timer.sleep(config[:delay])
      end
    end
  end
end
