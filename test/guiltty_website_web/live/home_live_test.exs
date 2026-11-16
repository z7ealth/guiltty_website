defmodule GuilttyWebsiteWeb.HomeLiveTest do
  use GuilttyWebsiteWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders a single screen: the pitch, the terminal, the one-line install", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for id <-
          ~w(#hero #hero-features #hero-terminal #hero-typing #hero-install #cta-docs #cta-github) do
      assert has_element?(view, id)
    end

    assert has_element?(view, "#one-line-curl", "curl -fsSL")
    assert has_element?(view, "#one-line-wget", "wget -qO-")

    for id <- ~w(#how #features #supervision #themes #keys #changelog #book) do
      refute has_element?(view, id)
    end
  end
end
