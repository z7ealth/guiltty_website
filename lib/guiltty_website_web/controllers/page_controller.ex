defmodule GuilttyWebsiteWeb.PageController do
  use GuilttyWebsiteWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
