defmodule Twimg.Router do
  use Twimg.Web, :router

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

  scope "/", Twimg do
    pipe_through :browser # Use the default browser stack
    resources "/pictures", PictureController
    post "/create", PictureController, :create_multiple

    get "/", PictureController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Twimg do
  #   pipe_through :api
  # end
end
