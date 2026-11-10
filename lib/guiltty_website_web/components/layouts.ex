defmodule GuilttyWebsiteWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use GuilttyWebsiteWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @site_description "guiltty: a Linux GPU-accelerated terminal emulator written in Elixir and C. Self-healing tabs, Vulkan rendering, live config."

  @doc "The site-wide description, used by the description, Open Graph and Twitter tags."
  def site_description, do: @site_description

  @doc """
  The site's base URL with any `www.` dropped, so the canonical address is
  always the bare domain (CanonicalHost redirects www there).
  """
  def site_url do
    GuilttyWebsiteWeb.Endpoint.url()
    |> String.replace("://www.", "://")
  end

  @doc "The canonical URL of the current page: the bare domain plus the path, without query."
  def canonical_url(%Plug.Conn{request_path: path}), do: site_url() <> path
  def canonical_url(_), do: site_url() <> "/"

  @doc """
  The share image's absolute URL. In prod it's the digested path
  (`og-image-<hash>.png`), so a new image gets a new URL and LinkedIn & co.
  can't keep showing a cached old one.
  """
  def og_image_url do
    site_url() <> GuilttyWebsiteWeb.Endpoint.static_path("/images/og-image.png")
  end

  @doc "JSON-LD describing the site and the app, for search engines' rich results."
  def structured_data do
    url = site_url() <> "/"

    Jason.encode!(
      %{
        "@context" => "https://schema.org",
        "@graph" => [
          %{
            "@type" => "WebSite",
            "name" => "guiltty",
            "url" => url
          },
          %{
            "@type" => "SoftwareApplication",
            "name" => "guiltty",
            "url" => url,
            "description" => @site_description,
            "applicationCategory" => "DeveloperApplication",
            "operatingSystem" => "Linux",
            "image" => og_image_url(),
            "codeRepository" => "https://github.com/z7ealth/guiltty",
            "offers" => %{"@type" => "Offer", "price" => "0", "priceCurrency" => "USD"}
          }
        ]
      },
      escape: :html_safe
    )
  end

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <.pp_top_app_bar position="sticky" class="site-bar z-40 px-3 sm:px-6 lg:px-8">
      <:leading>
        <a
          href="/"
          class="flex items-center rounded-pp-full pp-focus-ring"
          aria-label="guiltty home"
        >
          <.wordmark />
        </a>
      </:leading>
      <span class="sr-only">guiltty</span>
      <:actions>
        <nav class="hidden md:flex items-center gap-2 mr-3" aria-label="Sections">
          <.pp_button
            :for={{label, href} <- nav_links()}
            href={href}
            variant="text"
            color="secondary"
            class="px-5!"
          >
            {label}
          </.pp_button>
        </nav>
        <.pp_tooltip title="guiltty on GitHub" placement="bottom">
          <.pp_icon_button
            href={github_url()}
            label="guiltty on GitHub"
            target="_blank"
            rel="noopener"
          >
            <.github_mark />
          </.pp_icon_button>
        </.pp_tooltip>
        <.pp_theme_toggle class="hidden sm:inline-flex" />
        <.pp_icon_button
          id="mobile-nav-button"
          label="Menu"
          class="md:hidden"
          aria-controls="mobile-nav"
          phx-click={PhoenixPaper.SideSheet.show("mobile-nav")}
        >
          <.pp_icon name="hero-bars-3" size="none" class="size-6" />
        </.pp_icon_button>
      </:actions>
    </.pp_top_app_bar>

    <%!-- Phones and small tablets: the section links in a side sheet --%>
    <.pp_side_sheet id="mobile-nav">
      <:title>guiltty</:title>
      <.pp_list aria-label="Sections">
        <.pp_list_item
          :for={{label, href} <- nav_links()}
          href={href}
          phx-click={PhoenixPaper.SideSheet.hide("mobile-nav")}
        >
          {label}
          <:trailing><.pp_icon name="hero-chevron-right" size="sm" /></:trailing>
        </.pp_list_item>
      </.pp_list>
      <.pp_divider class="my-2" />
      <div class="flex items-center justify-between px-4 py-2">
        <.pp_typography variant="body-large" color="on-surface-variant" tag="span">
          Theme
        </.pp_typography>
        <.pp_theme_toggle />
      </div>
    </.pp_side_sheet>

    <main id="top">
      {render_slot(@inner_block)}
    </main>

    <footer class="border-t border-pp-outline-variant bg-pp-surface-container-low">
      <div class="mx-auto max-w-6xl px-6 py-12 grid gap-10 md:grid-cols-[1.4fr_1fr_1fr]">
        <div class="space-y-3">
          <.wordmark />
          <p class="pp-body-medium text-pp-on-surface-variant max-w-sm">
            A GPU-accelerated terminal emulator in Elixir and C. Linux only, built from source, no guilt.
          </p>
          <.pp_theme_toggle class="sm:hidden" />
        </div>
        <div>
          <p class="pp-title-small mb-3">Project</p>
          <ul class="space-y-2 pp-body-medium text-pp-on-surface-variant">
            <li><a class="footer-link" href="/docs">Documentation</a></li>
            <li><a class="footer-link" href={github_url()}>Source on GitHub</a></li>
            <li>
              <a class="footer-link" href={github_url() <> "/blob/master/CHANGELOG.md"}>Changelog</a>
            </li>
            <li><a class="footer-link" href={github_url() <> "/blob/master/DEVLOG.md"}>Devlog</a></li>
            <li><a class="footer-link" href={github_url() <> "/tree/master/book"}>The book</a></li>
          </ul>
        </div>
        <div>
          <p class="pp-title-small mb-3">This site</p>
          <p class="pp-body-medium text-pp-on-surface-variant">
            Built with Phoenix and <a
              class="footer-link text-pp-primary"
              href="https://phoenixpaper.dev"
            >PhoenixPaper</a>.
          </p>
        </div>
      </div>
      <div class="border-t border-pp-outline-variant">
        <p
          id="copyright"
          class="mx-auto max-w-6xl px-6 py-5 text-center pp-body-small text-pp-on-surface-variant"
        >
          © z7ealth 2026
        </p>
      </div>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc "The GitHub repository."
  def github_url, do: "https://github.com/z7ealth/guiltty"

  defp nav_links do
    [
      {"Features", "/#features"},
      {"Crash it", "/#supervision"},
      {"Themes", "/#themes"},
      {"Install", "/#install"},
      {"Docs", "/docs"},
      {"Book", "/#book"}
    ]
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
