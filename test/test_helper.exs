Dynamo.under_test(SpawnViewer.Dynamo)
Dynamo.Loader.enable
ExUnit.start

defmodule SpawnViewer.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
