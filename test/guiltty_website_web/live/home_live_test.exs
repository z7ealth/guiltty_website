defmodule GuilttyWebsiteWeb.HomeLiveTest do
  use GuilttyWebsiteWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the landing page sections", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for id <-
          ~w(#hero #hero-terminal #how #features #supervision #themes #keys #install #changelog #book) do
      assert has_element?(view, id)
    end

    assert has_element?(view, "#deps-opensuse")
    assert has_element?(view, "#theme-dracula")
    assert has_element?(view, "#versions-table")
  end

  test "killing a process takes down what its supervisor restarts", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#kill-screen-1") |> render_click()

    assert has_element?(view, "#node-screen-1[data-status=down]")
    assert has_element?(view, "#node-parser-1[data-status=down]")
    assert has_element?(view, "#node-pty-1[data-status=up]")
    assert has_element?(view, "#kill-count", "1")
    assert has_element?(view, "#crash-log .log-line")
  end

  test "killing a desk takes down its window but not the tabs' sessions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#kill-desk-1") |> render_click()

    for id <- ~w(desk-1 tabs window renderer) do
      assert has_element?(view, "#node-#{id}[data-status=down]")
    end

    assert has_element?(view, "#node-session-1[data-status=up]")
    assert has_element?(view, "#node-desk-2[data-status=up]")
  end

  test "a killed process comes back with a new pid", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    old_pid = view |> element("#node-parser-1 .tree-pid") |> render()

    view |> element("#kill-parser-1") |> render_click()
    send(view.pid, {:restart, ["parser-1"], "the halo; the screen stays"})

    assert has_element?(view, "#node-parser-1[data-status=restarted]")
    refute view |> element("#node-parser-1 .tree-pid") |> render() == old_pid
  end
end
