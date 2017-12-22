defmodule MagnetissimoWeb.Router do
  use MagnetissimoWeb, :router

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

  scope "/", Magnetissimo do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/summary", TorrentController, :summary
  end

  scope "/rss", Magnetissimo do
    get "/",      RSSController, :index
    get "/:term", RssController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Magnetissimo do
  #   pipe_through :api
  # end
end
