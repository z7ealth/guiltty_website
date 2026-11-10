defmodule GuilttyWebsiteWeb.Plugs.CanonicalHost do
  @moduledoc """
  Sends `www.` requests to the bare domain with a 301, keeping the path and
  query string, so search engines see one copy of the site instead of two.

  Off unless `config :guiltty_website, redirect_www: true` (set in prod), or
  `enabled: true` is passed, since tests run on the host `www.example.com`.
  """
  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    enabled? =
      Keyword.get_lazy(opts, :enabled, fn ->
        Application.get_env(:guiltty_website, :redirect_www, false)
      end)

    if enabled?, do: redirect_www(conn), else: conn
  end

  defp redirect_www(%Plug.Conn{host: "www." <> apex} = conn) do
    query = if conn.query_string == "", do: "", else: "?" <> conn.query_string

    conn
    |> put_resp_header("location", "https://#{apex}#{conn.request_path}#{query}")
    |> send_resp(:moved_permanently, "")
    |> halt()
  end

  defp redirect_www(conn), do: conn
end
