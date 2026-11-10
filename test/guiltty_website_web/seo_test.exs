defmodule GuilttyWebsiteWeb.SeoTest do
  use GuilttyWebsiteWeb.ConnCase, async: true

  test "pages carry canonical, Open Graph and structured data tags", %{conn: conn} do
    doc = conn |> get(~p"/docs") |> html_response(200) |> LazyHTML.from_document()

    assert [canonical] =
             doc |> LazyHTML.query("link[rel=canonical]") |> LazyHTML.attribute("href")

    assert String.ends_with?(canonical, "/docs")

    assert [image] =
             doc |> LazyHTML.query("meta[property='og:image']") |> LazyHTML.attribute("content")

    assert image =~ ~r{/images/og-image.*\.png}

    assert [json] =
             doc
             |> LazyHTML.query("script[type='application/ld+json']")
             |> Enum.map(&LazyHTML.text/1)

    assert %{"@graph" => [_ | _]} = Jason.decode!(json)
  end

  test "other hosts pass through untouched", %{conn: conn} do
    conn =
      GuilttyWebsiteWeb.Plugs.CanonicalHost.call(%{conn | host: "guiltty.dev"}, enabled: true)

    refute conn.halted
  end

  test "www redirects to the bare domain, keeping path and query", %{conn: conn} do
    conn =
      %{conn | host: "www.guiltty.dev", request_path: "/docs", query_string: "x=1"}
      |> GuilttyWebsiteWeb.Plugs.CanonicalHost.call(enabled: true)

    assert conn.halted

    assert conn.status == 301
    assert get_resp_header(conn, "location") == ["https://guiltty.dev/docs?x=1"]
  end

  test "serves the sitemap and points robots.txt at it", %{conn: conn} do
    assert conn |> get("/sitemap.xml") |> response(200) =~ "https://guiltty.dev/docs"

    assert build_conn() |> get("/robots.txt") |> response(200) =~
             "Sitemap: https://guiltty.dev/sitemap.xml"
  end
end
