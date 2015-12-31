defmodule SpawnViewer.Router do
  use SpawnViewer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpawnViewer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/analyze/:id", PageController, :analyze
    get "/code/:id", PageController, :code
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpawnViewer do
  #   pipe_through :api
  # end
end
