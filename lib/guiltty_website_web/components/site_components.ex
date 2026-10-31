defmodule GuilttyWebsiteWeb.SiteComponents do
  @moduledoc """
  The site's own presentational pieces: the guiltty mark and wordmark, a
  terminal window drawn the way guiltty draws one (a flat tab bar with an
  accent line under the active tab), code blocks with a copy button, and
  section headings. Everything else on the page is PhoenixPaper.
  """
  use Phoenix.Component

  @doc "The guiltty mark (`|>_`), drawn in `currentColor`."
  attr :class, :any, default: "size-8"

  def logo_mark(assigns) do
    ~H"""
    <svg
      viewBox="0 0 64 64"
      fill="none"
      class={@class}
      aria-hidden="true"
      stroke="currentColor"
      stroke-width="6.5"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path d="M8 18L8 46" />
      <path d="M17 18L31 32L17 46" />
      <path class="logo-underscore" d="M42 46L56 46" />
    </svg>
    """
  end

  @doc "The mark and the `guil`+`tty` wordmark, as in guiltty's lockup."
  attr :class, :any, default: nil

  def wordmark(assigns) do
    ~H"""
    <span class={["inline-flex items-center gap-2", @class]}>
      <.logo_mark class="size-7 text-pp-primary" />
      <span class="pp-title-large tracking-tight">guil<span class="text-pp-primary">tty</span></span>
    </span>
    """
  end

  @doc "GitHub's mark (heroicons has none)."
  attr :class, :any, default: "size-5"

  def github_mark(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="currentColor" class={@class} aria-hidden="true">
      <path d="M12 .5a11.5 11.5 0 0 0-3.64 22.41c.58.1.79-.25.79-.56v-2c-3.2.7-3.88-1.37-3.88-1.37-.53-1.33-1.28-1.69-1.28-1.69-1.04-.71.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.76 2.7 1.25 3.36.96.1-.75.4-1.25.73-1.54-2.55-.29-5.24-1.28-5.24-5.68 0-1.26.45-2.28 1.19-3.09-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.17 1.18a11 11 0 0 1 5.77 0c2.2-1.49 3.17-1.18 3.17-1.18.63 1.59.23 2.76.11 3.05.74.81 1.19 1.83 1.19 3.09 0 4.42-2.7 5.39-5.26 5.67.41.36.78 1.06.78 2.14v3.17c0 .31.21.67.8.56A11.5 11.5 0 0 0 12 .5Z" />
    </svg>
    """
  end

  @doc """
  A terminal window: a KDE-style title bar, a monospace body and guiltty's
  flat tab bar under it. Colors come from the `--t-*` custom properties, which
  `[data-term-theme]` on an ancestor sets (see site.css).
  """
  attr :id, :string, required: true
  attr :title, :string, default: "guiltty"
  attr :tabs, :list, default: [], doc: "{label, active?} tuples"
  attr :class, :any, default: nil
  attr :body_class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def terminal(assigns) do
    ~H"""
    <div id={@id} class={["term", @class]} {@rest}>
      <div class="term-titlebar">
        <.logo_mark class="term-app-icon" />
        <span class="term-title">{@title}</span>
        <span class="term-controls" aria-hidden="true">
          <span class="hero-chevron-up-micro size-3.5"></span>
          <span class="hero-minus-micro size-3.5"></span>
          <span class="hero-stop-micro size-3"></span>
          <span class="hero-x-mark-micro size-3.5"></span>
        </span>
      </div>
      <div class={["term-body", @body_class]}>
        {render_slot(@inner_block)}
      </div>
      <%!-- At the bottom, guiltty's default since 0.15 --%>
      <div :if={@tabs != []} class="term-tabs" aria-hidden="true">
        <span :for={{label, active} <- @tabs} class={["term-tab", active && "is-active"]}>
          {label}
        </span>
      </div>
    </div>
    """
  end

  @doc """
  A shell snippet with a copy button. The copied text is the `<code>`'s.
  The code is an attribute, not a slot, so the formatter's indentation never
  ends up inside the `<pre>`.
  """
  attr :id, :string, required: true
  attr :code, :string, required: true
  attr :label, :string, default: "shell"
  attr :class, :any, default: nil

  def code_block(assigns) do
    ~H"""
    <div class={["code-block group/code", @class]}>
      <div class="flex items-center justify-between px-4 pt-2.5">
        <span class="pp-label-small uppercase tracking-widest text-white/45">{@label}</span>
        <button
          type="button"
          id={"#{@id}-copy"}
          phx-hook=".Copy"
          data-copy={"##{@id}"}
          class="copy-btn"
          aria-label="Copy to clipboard"
          title="Copy"
        >
          <span class="hero-clipboard-document size-4 copy-idle"></span>
          <span class="hero-check size-4 copy-done"></span>
          <span class="copy-done pp-label-medium">Copied</span>
        </button>
      </div>
      <pre class="overflow-x-auto px-4 pt-1 pb-4"><code id={@id}>{@code}</code></pre>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Copy">
      export default {
        mounted() {
          this.el.addEventListener("click", async () => {
            const code = document.querySelector(this.el.dataset.copy)
            try {
              await navigator.clipboard.writeText(code.innerText.trim())
              this.el.dataset.copied = "true"
              clearTimeout(this.timer)
              this.timer = setTimeout(() => delete this.el.dataset.copied, 1600)
            } catch (_e) {}
          })
        },
        destroyed() { clearTimeout(this.timer) }
      }
    </script>
    """
  end

  @doc "A section's eyebrow, headline and lede."
  attr :eyebrow, :string, required: true
  attr :title, :string, required: true
  attr :class, :any, default: nil
  slot :inner_block

  def section_header(assigns) do
    ~H"""
    <div class={["max-w-2xl", @class]}>
      <p class="pp-label-large uppercase tracking-[0.2em] text-pp-primary">{@eyebrow}</p>
      <h2 class="pp-display-small-emphasized mt-3 text-balance">{@title}</h2>
      <p :if={@inner_block != []} class="pp-body-large mt-4 text-pp-on-surface-variant text-pretty">
        {render_slot(@inner_block)}
      </p>
    </div>
    """
  end

  @doc "A key combination as daisyUI `kbd` keycaps: \"Ctrl+Shift+T\"."
  attr :keys, :string, required: true

  def keys(assigns) do
    assigns = assign(assigns, :parts, String.split(assigns.keys, ~r/\+(?!$)/))

    ~H"""
    <span class="inline-flex items-center gap-1 whitespace-nowrap">
      <%= for {key, i} <- Enum.with_index(@parts) do %>
        <span :if={i > 0} class="text-pp-on-surface-variant/60 text-xs">+</span>
        <kbd class="kbd kbd-sm">{key}</kbd>
      <% end %>
    </span>
    """
  end
end
