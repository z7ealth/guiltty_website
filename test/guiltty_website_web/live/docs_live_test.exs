defmodule GuilttyWebsiteWeb.DocsLiveTest do
  use GuilttyWebsiteWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders every section the sidebar links to", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/docs")

    sections =
      ~w(overview requirements install update windows-and-tabs scrollback broadcast keys
         images config-file settings themes tab-styles fonts renderer example-config command environment
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
    assert has_element?(view, "#docs-one-line-cmd", "get.sh | sh")
    assert has_element?(view, "#get-sh-options-table")
    assert has_element?(view, "#docs-versions-table")
    assert has_element?(view, "#docs-example-config")
    assert has_element?(view, "#settings-table code", "tab_style")
    assert has_element?(view, "#tab-style-powerline")
  end

  # The formatter can turn code={"a\nb"} into code="a\nb", which HEEx
  # renders as a literal backslash-n: snippets live in heredocs instead.
  test "code blocks have real line breaks", %{conn: conn} do
    for path <- [~p"/docs", ~p"/"] do
      {:ok, view, _html} = live(conn, path)

      for code <-
            view |> render() |> LazyHTML.from_fragment() |> LazyHTML.query(".code-block code") do
        refute LazyHTML.text(code) =~ "\\n"
      end
    end

    {:ok, view, _html} = live(conn, ~p"/docs")
    assert view |> element("#docs-hack-cmd") |> render() =~ "mix deps.get\nmix guiltty"
  end

  test "the top bar links to the docs", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ~s(header a[href="/docs"]))
    assert has_element?(view, ~s(#mobile-nav a[href="/docs"]))
    assert has_element?(view, "#mobile-nav-button")
  end
end
