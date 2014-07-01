defmodule SpawnViewer.Router do
  use Phoenix.Router

  plug Plug.Static, at: "/static", from: :spawn_viewer
  get "/", SpawnViewer.Controllers.Pages, :index, as: :index
  get "/analyze/:id", SpawnViewer.Controllers.Pages, :analyze
  get "/code/:id", SpawnViewer.Controllers.Pages, :code
end
