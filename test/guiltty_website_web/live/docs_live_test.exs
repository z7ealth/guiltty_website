defmodule GuilttyWebsiteWeb.DocsLiveTest do
  use GuilttyWebsiteWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders every section the sidebar links to", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/docs")

    sections =
      ~w(overview requirements install update windows-and-tabs scrollback broadcast keys
         config-file settings themes tab-styles fonts renderer example-config command environment
         troubleshooting hacking learn-more)

    for id <- sections do
      assert has_element?(view, "section##{id}")
      assert has_element?(view, ~s(#docs-toc a[href="##{id}"]))
    end
  end

  test "lists every key, setting and install command", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/docs")

    assert has_element?(view, "#keys-table code", "rename_tab")
    assert has_element?(view, "#settings-table code", "broadcast_programs")
    assert has_element?(view, "#docs-deps-opensuse")
    assert has_element?(view, "#docs-versions-table")
    assert has_element?(view, "#docs-example-config")
    assert has_element?(view, "#settings-table code", "tab_style")
    assert has_element?(view, "#tab-style-powerline")
  end

  test "the top bar links to the docs", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ~s(header a[href="/docs"]))
  end
end
