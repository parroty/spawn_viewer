ExUnit.start

Mix.Task.run "ecto.create", ~w(-r SpawnViewer.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r SpawnViewer.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(SpawnViewer.Repo)

