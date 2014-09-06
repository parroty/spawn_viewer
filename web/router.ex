defmodule SpawnViewer.Router do
  use Phoenix.Router

  plug Plug.Static, at: "/static", from: :spawn_viewer

  scope alias: SpawnViewer do
    get "/", PageController, :index, as: :index
    get "/analyze/:id", PageController, :analyze
    get "/code/:id", PageController, :code
  end
end
