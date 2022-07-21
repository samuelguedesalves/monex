defmodule MonexWeb.Router do
  use MonexWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MonexWeb do
    pipe_through :api

    post "/sign_up", UsersController, :create
    post "/login", UsersController, :auth

    get "/users/details", UsersController, :show
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: MonexWeb.Telemetry
    end
  end
end
