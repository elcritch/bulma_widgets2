defmodule BulmaWidgetsWeb.Router do
  use BulmaWidgetsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BulmaWidgetsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :testing do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BulmaWidgetsWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/widgets.html", WidgetExamplesLive
    live "/graph.html", ExampleGraphLive
  end

  scope "/examples", BulmaWidgetsWeb do
    pipe_through :testing

  end

  # Other scopes may use custom stacks.
  # scope "/api", BulmaWidgetsWeb do
  #   pipe_through :api
  # end
end
