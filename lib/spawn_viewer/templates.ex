defmodule SpawnViewer.Templates do
  require EEx

  EEx.function_from_file :def, :index, "templates/index.html.eex", [:target_modules]
end