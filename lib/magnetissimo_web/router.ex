defmodule MagnetissimoWeb.Router do
  use MagnetissimoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MagnetissimoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MagnetissimoWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/torrents/:id", TorrentLive
  end

  scope "/api", MagnetissimoWeb do
    pipe_through :api

    get "/latest", TorrentController, :latest
    get "/search/:term", TorrentController, :search
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:magnetissimo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MagnetissimoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
