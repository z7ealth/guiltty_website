defmodule GuilttyWebsiteWeb.HomeLive do
  @moduledoc """
  The landing page: one screen, the pitch and a terminal that types (and
  crashes, and comes back). What guiltty can do is told in the docs.
  """
  use GuilttyWebsiteWeb, :live_view

  alias GuilttyWebsite.Guiltty

  @hero_scenes [
    %{cmd: ~s(echo "let it crash · 🧙‍♂️⚗️"), out: ["let it crash · 🧙‍♂️⚗️"]},
    %{
      cmd:
        ~S(printf '\e[1;31mbold\e[0m \e[4;34munder\e[0m \e[9;35mstrike\e[0m \e[7;32minverse\e[0m \e[33m|> -> !=\e[0m\n'),
      out: [
        ~s(<b class="t-red">bold</b> <u class="t-blue">under</u> <s class="t-magenta">strike</s> <span class="t-inverse-green">inverse</span> <span class="t-yellow">|&gt; -&gt; !=</span>)
      ]
    },
    %{cmd: "pkill -9 guiltty_vk   # go on, kill the renderer", out: [], crash: true},
    %{
      cmd: "ls ~/.config/guiltty",
      out: [~s(<span class="t-blue">config.exs</span>)]
    }
  ]

  @hero_features [
    {"hero-shield-check", "Self-healing tabs"},
    {"hero-bolt", "Vulkan + OpenGL"},
    {"hero-lock-closed", "Lockable tabs"},
    {"hero-signal", "Broadcast input"},
    {"hero-arrow-path", "Live config reload"},
    {"hero-magnifying-glass", "Scrollback search"},
    {"hero-language", "Unicode & emoji"},
    {"hero-code-bracket", "Ligatures"},
    {"hero-bell", "Activity marks"},
    {"hero-photo", "Images"},
    {"hero-view-columns", "Split panes"},
    {"hero-command-line", "Scriptable from a shell"},
    {"hero-chat-bubble-left-right", "AI key"},
    {"hero-link", "Hyperlinks"},
    {"hero-swatch", "Built-in themes"},
    {"hero-musical-note", "Music visualizer"}
  ]

  # The visualizer's 16 bars, bass on the left: {peak, seconds per loop,
  # delay}. The bass bars reach highest and move slowest.
  @viz_bars [
    {0.95, 1.8, 0.0},
    {1.0, 2.2, -0.6},
    {0.9, 1.6, -1.2},
    {0.8, 2.0, -0.4},
    {0.85, 1.4, -1.0},
    {0.7, 1.8, -0.2},
    {0.75, 1.3, -0.8},
    {0.6, 1.6, -1.4},
    {0.65, 1.2, -0.4},
    {0.55, 1.5, -1.0},
    {0.5, 1.1, -0.6},
    {0.45, 1.4, -1.2},
    {0.4, 1.0, -0.2},
    {0.35, 1.2, -0.8},
    {0.3, 0.9, -0.4},
    {0.25, 1.1, -1.0}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "guiltty · a GPU-accelerated terminal emulator in Elixir and C")
     |> assign(:github, Guiltty.github())
     |> assign(:hero_features, Enum.with_index(@hero_features))
     |> assign(:viz_bars, @viz_bars)
     |> assign(:hero_scenes, Jason.encode!(@hero_scenes))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="site" data-term-theme="guiltty">
        <section
          id="hero"
          class="hero-section relative flex flex-col items-center justify-center overflow-hidden"
        >
          <div class="hero-glow" aria-hidden="true"></div>

          <div class="relative mx-auto flex w-full max-w-4xl flex-col items-center px-4 py-12 sm:px-6 text-center">
            <a
              href={"#{@github}/blob/master/CHANGELOG.md"}
              class="hero-pill pp-label-large mb-8"
              id="hero-release"
            >
              <span class="rounded-pp-full bg-pp-primary px-2 py-0.5 text-pp-on-primary pp-label-medium">
                v0.28.0
              </span>
              <span>A music visualizer in the tab bar</span>
              <.pp_icon name="hero-arrow-right-micro" size="none" class="hero-pill-arrow size-4" />
            </a>

            <h1 class="hero-name">
              <.logo_mark class="hero-name-mark text-pp-primary" />
              <span>guil<span class="text-pp-primary">tty</span></span>
            </h1>

            <p class="hero-tagline mt-5 text-pretty">
              A GPU-accelerated Linux terminal that runs on the BEAM.
            </p>

            <div
              id="hero-features"
              class="hero-chips mt-8 flex max-w-3xl flex-wrap justify-center gap-2"
            >
              <.pp_chip :for={{{icon, label}, i} <- @hero_features} style={"--i: #{i}"}>
                <:icon><.icon name={icon} class="size-4.5" /></:icon>
                {label}
              </.pp_chip>
            </div>

            <div class="hero-term-wrap mt-10 w-full">
              <.terminal
                id="hero-terminal"
                class="hero-term tabs-powerline text-left"
                title="you@linux:~/src"
                body_class="hero-panes"
              >
                <:tab_bar>
                  <span class="term-tab">you@linux:~</span>
                  <span class="term-tab">● you@linux:~/guiltty</span>
                  <span class="term-tab is-active">you@linux:~/src</span>
                  <%!-- The visualizer (visualizer: true, the default): 16 bars
                       at the right, in the accent color, moving with the music --%>
                  <span id="hero-visualizer" class="tab-viz">
                    <span
                      :for={{peak, dur, delay} <- @viz_bars}
                      class="tab-viz-bar"
                      style={"--peak: #{peak}; --dur: #{dur}s; --delay: #{delay}s"}
                    ></span>
                  </span>
                </:tab_bar>
                <div class="hero-pane">
                  <div
                    id="hero-typing"
                    phx-hook=".Typing"
                    phx-update="ignore"
                    data-scenes={@hero_scenes}
                    class="min-h-[20rem]"
                  >
                    <.p10k_prompt />
                    <div>
                      <span class="p10k-frame">╰─</span> <span class="t-cursor"></span>
                    </div>
                  </div>
                </div>
                <%!-- A split pane (Ctrl+Shift+O): unfocused, so its cursor is hollow --%>
                <div id="hero-side-pane" class="hero-pane hero-pane-side" aria-hidden="true">
                  <div class="t-dim">Interactive Elixir (1.20.4)</div>
                  <div class="mt-1">
                    <span class="t-green">iex(1)&gt;</span> Process.list |&gt; length
                  </div>
                  <div class="t-yellow">412</div>
                  <div><span class="t-green">iex(2)&gt;</span> :erlang.memory(:total)</div>
                  <div class="t-yellow">48_311_920</div>
                  <div><span class="t-green">iex(3)&gt;</span> Node.self()</div>
                  <div class="t-magenta">:"guiltty@127.0.0.1"</div>
                  <div>
                    <span class="t-green">iex(4)&gt;</span> <span class="t-cursor-hollow"></span>
                  </div>
                </div>
                <div class="term-toast" aria-hidden="true">
                  <.pp_icon name="hero-arrow-path-micro" size="none" class="size-4" />
                  renderer restarted · every tab intact
                </div>
              </.terminal>
            </div>

            <div class="mt-12 flex flex-wrap items-center justify-center gap-3">
              <.pp_button href="/docs" size="md" id="cta-docs">
                Documentation
              </.pp_button>
              <.pp_button href={@github} variant="outlined" size="md" id="cta-github">
                <:start_icon><.github_mark class="size-5" /></:start_icon>
                GitHub
              </.pp_button>
            </div>
          </div>
        </section>

        <section id="install-band" class="install-band px-4 py-16 sm:px-6 sm:py-20">
          <div id="hero-install" class="mx-auto w-full max-w-2xl">
            <h2 class="hero-install-title">Install</h2>
            <.one_line_tabs id="one-line" class="mt-5 text-left" />
            <p class="hero-fine mt-4">
              <a
                href={"#{@github}/blob/master/CHANGELOG.md"}
                id="install-release"
                class="hero-fine-link"
              >
                v0.28.0
              </a>
              <span aria-hidden="true">·</span>
              <.link navigate={~p"/docs#install"} class="hero-fine-link">More ways to install</.link>
            </p>
          </div>
        </section>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".Typing">
        export default {
          mounted() {
            const scenes = JSON.parse(this.el.dataset.scenes)
            const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches
            const term = this.el.closest(".term")
            this.alive = true
            const sleep = ms => new Promise(r => { this.timer = setTimeout(r, reduce ? 0 : ms) })
            // p10k's first line, rendered once by the server; the clock is ours.
            const firstLine = this.el.querySelector(".p10k").cloneNode(true)
            const line = html => {
              const div = document.createElement("div")
              div.innerHTML = html
              this.el.appendChild(div)
              return div
            }
            const promptLine = () => {
              const first = firstLine.cloneNode(true)
              first.querySelector(".p10k-clock").textContent =
                new Date().toLocaleTimeString("en-GB", {hour12: false})
              this.el.appendChild(first)
              const div = line('<span class="p10k-frame">╰─</span> ')
              const cmd = document.createElement("span")
              const cursor = document.createElement("span")
              cursor.className = "t-cursor"
              div.append(cmd, cursor)
              return {cmd, cursor}
            }
            const run = async () => {
              while (this.alive) {
                this.el.innerHTML = ""
                for (const scene of scenes) {
                  const {cmd, cursor} = promptLine()
                  await sleep(600)
                  for (const ch of scene.cmd) {
                    if (!this.alive) return
                    cmd.textContent += ch
                    await sleep(22 + Math.random() * 55)
                  }
                  await sleep(380)
                  cursor.remove()
                  if (scene.crash && !reduce) {
                    term.classList.add("is-crashing")
                    await sleep(1100)
                    term.classList.remove("is-crashing")
                    term.classList.add("is-restored")
                    await sleep(1800)
                    term.classList.remove("is-restored")
                  }
                  for (const out of scene.out) { line(out); await sleep(70) }
                  if (!this.alive) return
                }
                promptLine()
                if (reduce) return
                await sleep(4200)
              }
            }
            run()
          },
          destroyed() {
            this.alive = false
            clearTimeout(this.timer)
          }
        }
      </script>
    </Layouts.app>
    """
  end
end
