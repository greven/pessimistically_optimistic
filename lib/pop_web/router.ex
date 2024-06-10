defmodule POPWeb.Router do
  use POPWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {POPWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", POPWeb do
    pipe_through :browser

    get "/", PageController, :home

    live_session :default do
      live "/button", ButtonLive
      live "/collection", CollectionLive
      live "/tasks", TasksLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", POPWeb do
  #   pipe_through :api
  # end
end
