defmodule GuilttyWebsiteWeb.HomeLive do
  @moduledoc """
  The landing page. Almost all of it is static; the one live part is the
  supervision tree, where clicking a process "kills" it and the tree shows
  what guiltty's supervisors restart (from book chapter 12).
  """
  use GuilttyWebsiteWeb, :live_view

  @github "https://github.com/z7ealth/guiltty"

  # {id, tree prefix, module, note, killable?}
  @tree [
    {"sup", "", "Guiltty.Supervisor", "rest_for_one", false},
    {"registry", "├── ", "Guiltty.Registry", nil, false},
    {"config", "├── ", "Guiltty.Config", "reloaded on save", false},
    {"sessions", "├── ", "Guiltty.Sessions", "DynamicSupervisor", false},
    {"session-1", "│   ├── ", "Session.Supervisor 1", "rest_for_one", true},
    {"pty-1", "│   │   ├── ", "Pty", "the PTY NIF", true},
    {"screen-1", "│   │   ├── ", "Screen", nil, true},
    {"parser-1", "│   │   └── ", "Parser", nil, true},
    {"session-2", "│   └── ", "Session.Supervisor 2", nil, false},
    {"desks", "├── ", "Guiltty.Desks", "DynamicSupervisor", false},
    {"desk-1", "│   ├── ", "Desk 1", "one per window", true},
    {"tabs", "│   │   ├── ", "Guiltty.Tabs", "significant", true},
    {"window", "│   │   └── ", "Guiltty.Window", "the renderer port", false},
    {"renderer", "│   │       └── ", "guiltty_vk", "its own OS process", true},
    {"desk-2", "│   └── ", "Desk 2", nil, false},
    {"lifeline", "└── ", "Guiltty.Lifeline", "watches the desks", false}
  ]

  # What a kill takes down (rest_for_one inside a session: Pty, Screen,
  # Parser; and inside a desk: Tabs, Window), and what you see, per
  # book/12-beam-advantage.org.
  @crashes %{
    "parser-1" => {~w(parser-1), "the halo; the screen stays"},
    "screen-1" => {~w(screen-1 parser-1), "the window follows the new Screen"},
    "pty-1" => {~w(pty-1 screen-1 parser-1), "the window follows the new Screen"},
    "session-1" => {~w(session-1 pty-1 screen-1 parser-1), "the tab stays in place, same id"},
    "tabs" => {~w(tabs window renderer), "nothing: the tabs are taken back"},
    "renderer" => {~w(window renderer), "the window comes back, all tabs"},
    "desk-1" => {~w(desk-1 tabs window renderer), "that window comes back; others never notice"}
  }

  @restart_ms 700
  @settle_ms 1600

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
    {"hero-swatch", "Built-in themes"}
  ]

  @themes [
    {"tomorrow-night", "Tomorrow Night"},
    {"catppuccin-mocha", "Catppuccin Mocha"},
    {"dracula", "Dracula"},
    {"gruvbox-dark", "Gruvbox Dark"},
    {"solarized-dark", "Solarized Dark"}
  ]

  @distros [
    {"opensuse", "openSUSE Tumbleweed",
     "sudo zypper install gcc make pkg-config SDL3-devel freetype2-devel \\\n  fontconfig-devel harfbuzz-devel vulkan-devel shaderc elixir erlang-epmd",
     "The one guiltty is developed on."},
    {"fedora", "Fedora 45+",
     "sudo dnf install gcc make pkgconf-pkg-config SDL3-devel freetype-devel \\\n  fontconfig-devel harfbuzz-devel vulkan-loader-devel vulkan-headers glslc elixir",
     "Fedora 43 and 44 have everything but Elixir 1.20: leave out elixir and get it from asdf."},
    {"ubuntu", "Ubuntu 26.04+",
     "sudo apt install build-essential pkg-config libsdl3-dev libfreetype-dev \\\n  libfontconfig-dev libharfbuzz-dev libvulkan-dev glslc",
     "26.04's Elixir is 1.18: get Elixir 1.20 and Erlang from asdf. From 26.10 on, add elixir erlang-dev instead."},
    {"arch", "Arch Linux",
     "sudo pacman -S --needed base-devel sdl3 freetype2 fontconfig harfbuzz \\\n  vulkan-icd-loader vulkan-headers shaderc elixir",
     "Everything is in the official repositories."}
  ]

  @keys [
    {"Ctrl+Shift+N", "New window"},
    {"Ctrl+Shift+T", "New tab"},
    {"Ctrl+Shift+W", "Close tab"},
    {"Ctrl+PgUp", "Previous tab"},
    {"Ctrl+PgDn", "Next tab"},
    {"Shift+PgUp", "Scroll back"},
    {"Ctrl+Shift+F", "Search the scrollback"},
    {"Ctrl+Shift+C", "Copy"},
    {"Ctrl+Shift+V", "Paste"},
    {"Ctrl+=", "Zoom in"},
    {"Ctrl+-", "Zoom out"},
    {"Ctrl+0", "Reset zoom"},
    {"Ctrl+,", "Open the config file"},
    {"Ctrl+Shift+/", "The cheatsheet: every key"},
    {"Ctrl+Shift+L", "Lock the tab 🔒"},
    {"Ctrl+Shift+B", "Broadcast tabs"}
  ]

  @milestones [
    {"0.1", "First light", "Oct 29",
     "The whole pipeline: a PTY NIF, a parser, the screen in Elixir and an OpenGL renderer. ASCII only, 80×24."},
    {"0.2", "Color", "Oct 29",
     "16, 256 and 24-bit color, Paul Williams' DEC parser, and a resizable window."},
    {"0.3", "The vim fight", "Oct 29",
     "Alternate screen, scroll regions, mouse reporting. vim, less, htop, btop and tmux work."},
    {"0.4", "The BEAM advantage", "Oct 29",
     "Tabs, self-healing sessions, detach and reattach, live config, backpressure."},
    {"0.5", "Daily driver", "Oct 30",
     "Unicode, HarfBuzz shaping, color emoji, 10,000 rows of scrollback, search, HiDPI."},
    {"0.6", "Flat tabs", "Oct 30",
     "The flat tab bar, named themes, cursor and window settings, the cheatsheet."},
    {"0.7", "The installer", "Oct 30", "./install.sh, a menu entry and the logo."},
    {"0.8", "Lockable tabs", "Oct 30", "Lock a tab and it outlives the window."},
    {"0.9", "Broadcast", "Oct 30",
     "Type once into every tab in the group, without typing into your own machine by mistake."},
    {"0.10", "Vulkan", "Oct 30",
     "A Vulkan 1.3 renderer, pixel-for-pixel the same as OpenGL, with automatic fallback."},
    {"0.11", "Ligatures", "Oct 30",
     "With a font that has them, |>, ->, != and === are drawn as one symbol. Cleaner tabs, too."},
    {"0.12.4", "Security", "Oct 30",
     "Hardened C, a localhost-only node with a private cookie, a pidfd for the shell, and titles that can't fake a locked tab."},
    {"0.13", "Multi window", "Oct 30",
     "Several windows, each with its own tabs, locked tabs and broadcast group. Ctrl+Shift+N opens one."},
    {"0.14", "Performance", "Oct 31",
     "Floods of short lines show up 3x faster, startup is 100 ms sooner, and make bench measures it all."},
    {"0.15.3", "Client and server", "Oct 31",
     "guiltty is a small client that asks the running guiltty for a window, like emacsclient: 0.1 s."}
  ]

  @chapters [
    {"00-overview", "Overview: what a terminal emulator actually is"},
    {"01-pseudoterminals", "Pseudoterminals: the kernel half of a terminal"},
    {"02-pty-nif", "The PTY NIF: a pseudoterminal inside the BEAM"},
    {"03-parser", "The parser: bytes in, commands out"},
    {"04-screen-and-grid", "The screen and the grid"},
    {"05-port-protocol", "The port protocol: Elixir and the renderer"},
    {"06-renderer", "The renderer: from cells to pixels"},
    {"07-input", "Input: from a key press to bash"},
    {"08-colors", "Colors: from SGR to pixels"},
    {"09-resize", "Resize: from a dragged window to SIGWINCH"},
    {"10-testing", "Testing a terminal with real bytes"},
    {"11-full-screen", "Full-screen programs: what vim needs from a terminal"},
    {"12-beam-advantage", "The BEAM advantage: tabs, crashes, detaching, live config"},
    {"13-unicode", "Unicode: bytes, characters, clusters and columns"},
    {"14-fonts-and-atlas", "Fonts and the atlas: every glyph, from any font"},
    {"15-scrollback-and-selection", "Scrollback, search and the clipboard"},
    {"16-config", "Configuration: every setting, from file to pixels"},
    {"17-installing", "Installing: the release, the menu entry, the icon"},
    {"18-broadcast", "Broadcast: typing into many servers, safely"},
    {"19-vulkan", "Vulkan: the same picture, with nothing hidden"},
    {"20-security", "Security: making the C hard to break"},
    {"21-multi-window", "Multi window: every window its own desk"},
    {"22-performance", "Performance: measure, then fix what the numbers say"},
    {"23-client-server", "Client and server: the guiltty command"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    ids = Enum.map(@tree, &elem(&1, 0))

    {:ok,
     socket
     |> assign(:page_title, "guiltty · a GPU-accelerated terminal emulator in Elixir and C")
     |> assign(:github, @github)
     |> assign(:tree, @tree)
     |> assign(:status, Map.new(ids, &{&1, :up}))
     |> assign(:pids, ids |> Enum.with_index() |> Map.new(fn {id, i} -> {id, 212 + i * 7} end))
     |> assign(:next_pid, 400)
     |> assign(:kills, 0)
     |> assign(:hero_scenes, Jason.encode!(@hero_scenes))
     |> assign(:hero_features, @hero_features)
     |> assign(:themes, @themes)
     |> assign(:distros, @distros)
     |> assign(:keys, @keys)
     |> assign(:milestones, @milestones)
     |> assign(:chapters, @chapters)
     |> stream(:log, [])}
  end

  @impl true
  def handle_event("kill", %{"node" => node}, socket) do
    with {nodes, seen} <- Map.get(@crashes, node),
         true <- Enum.all?(nodes, &(socket.assigns.status[&1] == :up)) do
      Process.send_after(self(), {:restart, nodes, seen}, @restart_ms)

      {:noreply,
       socket
       |> update(:status, &set_status(&1, nodes, :down))
       |> update(:kills, &(&1 + 1))
       |> log(:exit, "** (EXIT) #{label(node)} #{pid(socket, node)} killed")}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:restart, nodes, seen}, socket) do
    {pids, next} =
      Enum.reduce(nodes, {socket.assigns.pids, socket.assigns.next_pid}, fn id, {pids, n} ->
        {Map.put(pids, id, n), n + Enum.random(3..11)}
      end)

    Process.send_after(self(), {:settle, nodes}, @settle_ms)

    {:noreply,
     socket
     |> assign(pids: pids, next_pid: next)
     |> update(:status, &set_status(&1, nodes, :restarted))
     |> log(:restart, "#{Enum.map_join(nodes, ", ", &label/1)} restarted → #{seen}")}
  end

  def handle_info({:settle, nodes}, socket) do
    status =
      Enum.reduce(nodes, socket.assigns.status, fn id, acc ->
        if acc[id] == :restarted, do: Map.put(acc, id, :up), else: acc
      end)

    {:noreply, assign(socket, :status, status)}
  end

  defp set_status(status, nodes, value), do: Enum.reduce(nodes, status, &Map.put(&2, &1, value))

  defp log(socket, kind, text) do
    entry = %{
      id: System.unique_integer([:positive]),
      kind: kind,
      time: Time.utc_now() |> Time.truncate(:second) |> Time.to_string(),
      text: text
    }

    stream_insert(socket, :log, entry, at: 0, limit: 7)
  end

  defp label(id) do
    case List.keyfind(@tree, id, 0) do
      {_, _, "Session.Supervisor 1", _, _} -> "Session.Supervisor"
      {_, _, "guiltty_vk", _, _} -> "renderer"
      {_, _, "Guiltty." <> name, _, _} -> name
      {_, _, name, _, _} -> name
    end
  end

  defp pid(socket, id) do
    if id == "renderer",
      do: "(os pid #{socket.assigns.pids[id] * 31})",
      else: "#PID<0.#{socket.assigns.pids[id]}.0>"
  end

  defp book_url(github, slug), do: "#{github}/blob/master/book/#{slug}.org"

  # Line one of a Powerlevel10k "classic" prompt: os_icon and dir on the left,
  # status and time on the right, a dotted gap between them. Its colors are
  # xterm's 256-color cube, not the theme's, as in a real terminal.
  defp p10k_prompt(assigns) do
    ~H"""
    <div class="p10k">
      <span class="p10k-frame">╭─</span>
      <span class="p10k-seg p10k-seg-left">
        <.logo_mark class="p10k-os" />
        <span class="p10k-sub">│</span>
        <span class="p10k-dir"><span class="hero-home-micro size-3.5"></span><span>~/<b>src</b></span></span>
      </span>
      <span class="p10k-gap"></span>
      <span class="p10k-seg p10k-seg-right">
        <span class="p10k-ok">✔</span>
        <span class="p10k-sub">│</span>
        <span class="p10k-time">
          at <span class="p10k-clock">16:24:55</span>
          <span class="hero-clock-micro size-3.5"></span>
        </span>
      </span>
      <span class="p10k-frame">─╮</span>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="site" data-term-theme="catppuccin-mocha">
        <%!-- ───────────────────────── Hero ───────────────────────── --%>
        <section id="hero" class="hero-section relative overflow-hidden">
          <div class="hero-grid" aria-hidden="true"></div>
          <div class="hero-glow hero-glow-1" aria-hidden="true"></div>
          <div class="hero-glow hero-glow-2" aria-hidden="true"></div>

          <div class="relative mx-auto max-w-6xl px-6 pt-16 pb-24 sm:pt-24 text-center">
            <a
              href={"#{@github}/blob/master/CHANGELOG.md"}
              class="hero-pill pp-label-large"
              id="hero-release"
            >
              <span class="rounded-pp-full bg-pp-primary px-2 py-0.5 text-pp-on-primary pp-label-medium">
                v0.15.3
              </span>
              <span>Client and server: a new window in 0.1 s</span>
              <span class="hero-arrow-right-micro size-4"></span>
            </a>

            <h1 class="hero-title mt-8 text-balance">
              Kill it. Crash it.<br />
              <span class="hero-title-accent">Your tabs are still there.</span>
            </h1>

            <p class="pp-body-large sm:text-xl! sm:leading-8! mx-auto mt-6 max-w-2xl text-pp-on-surface-variant text-pretty">
              guiltty is a Linux-only, GPU-accelerated terminal emulator written in Elixir and C. Every tab is a supervised
              process tree and the renderer is its own OS process, so when a part crashes, its
              supervisor restarts it and your tabs stay.
            </p>

            <div class="mt-10 flex flex-wrap items-center justify-center gap-3">
              <.pp_button href="#install" size="md" id="cta-install">
                <:start_icon><.pp_icon name="hero-arrow-down-tray" /></:start_icon>
                Install guiltty
              </.pp_button>
              <.pp_button href={@github} variant="outlined" size="md" id="cta-github">
                <:start_icon><.github_mark class="size-5" /></:start_icon>
                Read the source
              </.pp_button>
            </div>

            <div class="mx-auto mt-6 flex max-w-4xl flex-wrap justify-center gap-2">
              <.pp_chip :for={{icon, label} <- @hero_features}>
                <:icon><.icon name={icon} class="size-4.5" /></:icon>
                {label}
              </.pp_chip>
            </div>

            <div class="hero-term-wrap mt-16">
              <.terminal
                id="hero-terminal"
                class="hero-term text-left"
                title="you@linux:~/src"
                tabs={[
                  {"you@linux:~", false},
                  {"you@linux:~/guiltty", false},
                  {"you@linux:~/src", true}
                ]}
              >
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
                <div class="term-toast" aria-hidden="true">
                  <span class="hero-arrow-path-micro size-4"></span>
                  renderer restarted · every tab intact
                </div>
              </.terminal>
            </div>
          </div>
        </section>

        <%!-- ───────────────────────── Stats ───────────────────────── --%>
        <section class="border-y border-pp-outline-variant bg-pp-surface-container-low">
          <dl class="mx-auto grid max-w-6xl grid-cols-2 gap-px px-6 md:grid-cols-4">
            <div
              :for={
                {value, label} <- [
                  {"15", "milestones implemented"},
                  {"2", "renderers, the same pixels"},
                  {"10,000", "rows of scrollback"},
                  {"24", "book chapters on how it works"}
                ]
              }
              class="py-8 text-center"
            >
              <dt class="sr-only">{label}</dt>
              <dd class="pp-display-small-emphasized text-pp-primary">{value}</dd>
              <dd class="pp-body-medium mt-1 text-pp-on-surface-variant">{label}</dd>
            </div>
          </dl>
        </section>

        <%!-- ───────────────────────── Pipeline ───────────────────────── --%>
        <section id="how" class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
          <.section_header
            eyebrow="How it works"
            title="Elixir does the thinking. C draws the pixels."
          >
            Your shell writes bytes into a pseudoterminal. A NIF hands them to the BEAM, where a
            parser and a screen, plain Elixir processes, turn them into cells. The renderer is a
            separate program that only draws: if it dies, guiltty starts a new one and your tabs are
            still there.
          </.section_header>

          <div class="pipeline mt-14" role="list">
            <div class="pipe-node" role="listitem">
              <span class="pipe-icon"><span class="hero-command-line size-6"></span></span>
              <p class="pp-title-medium">Your shell</p>
              <p class="pp-body-small text-pp-on-surface-variant">
                bash, zsh, fish: your login shell
              </p>
            </div>
            <div class="pipe-link" aria-hidden="true"><span></span></div>
            <div class="pipe-beam" role="listitem">
              <p class="pipe-beam-label pp-label-medium">the BEAM</p>
              <div class="pipe-beam-row">
                <div class="pipe-node">
                  <span class="pipe-icon"><span class="hero-cpu-chip size-6"></span></span>
                  <p class="pp-title-medium">PTY NIF</p>
                  <p class="pp-body-small text-pp-on-surface-variant">C · enif_select</p>
                </div>
                <div class="pipe-link" aria-hidden="true"><span></span></div>
                <div class="pipe-node">
                  <span class="pipe-icon"><span class="hero-funnel size-6"></span></span>
                  <p class="pp-title-medium">Parser</p>
                  <p class="pp-body-small text-pp-on-surface-variant">DEC state machine</p>
                </div>
                <div class="pipe-link" aria-hidden="true"><span></span></div>
                <div class="pipe-node">
                  <span class="pipe-icon"><span class="hero-squares-2x2 size-6"></span></span>
                  <p class="pp-title-medium">Screen</p>
                  <p class="pp-body-small text-pp-on-surface-variant">grid, scrollback</p>
                </div>
              </div>
            </div>
            <div class="pipe-link" aria-hidden="true"><span></span></div>
            <div class="pipe-node pipe-node-gpu" role="listitem">
              <span class="pipe-icon"><span class="hero-sparkles size-6"></span></span>
              <p class="pp-title-medium">Renderer</p>
              <p class="pp-body-small text-pp-on-surface-variant">its own process · Vulkan or GL</p>
            </div>
          </div>
        </section>

        <%!-- ───────────────────────── Features ───────────────────────── --%>
        <section
          id="features"
          class="bg-pp-surface-container-lowest border-y border-pp-outline-variant"
        >
          <div class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
            <.section_header eyebrow="Features" title="A daily driver, with the BEAM underneath.">
              The things you expect from a modern terminal, and a few that come almost for free with a supervision tree.
            </.section_header>

            <div class="bento mt-14">
              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-vulkan">
                <div class="feature-icon"><span class="hero-sparkles size-6"></span></div>
                <h3 class="pp-headline-small mt-5">Vulkan 1.3, or OpenGL. Same pixels.</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant max-w-lg">
                  guiltty draws with Vulkan by default. No driver? It falls back to OpenGL by itself and
                  says so in the tab bar. A test replays recorded frames through both and checks they
                  match, pixel for pixel.
                </p>
                <div class="pixel-compare mt-6" aria-hidden="true">
                  <div class="pixel-pane"><span class="pp-label-medium">guiltty_vk</span></div>
                  <span class="pp-title-medium text-pp-primary">=</span>
                  <div class="pixel-pane"><span class="pp-label-medium">guiltty_gl</span></div>
                </div>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-lock">
                <div class="feature-icon"><span class="hero-lock-closed size-6"></span></div>
                <h3 class="pp-title-large mt-5">Lockable tabs</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Lock a tab and close its window: it keeps running, and the next
                  <code class="inline-code">guiltty</code>
                  brings that window back with it.
                </p>
                <div class="mt-4"><.keys keys="Ctrl+Shift+L" /></div>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-broadcast">
                <div class="feature-icon"><span class="hero-signal size-6"></span></div>
                <h3 class="pp-title-large mt-5">Safe broadcast</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Type once into every tab in the group. If a connection drops, typing goes nowhere, so a command
                  meant for your servers doesn't land on your own machine.
                </p>
                <div class="mt-4"><.keys keys="Ctrl+Shift+B" /></div>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-unicode">
                <div class="feature-icon"><span class="hero-language size-6"></span></div>
                <h3 class="pp-title-large mt-5">Unicode, properly</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Grapheme clusters, wide characters, HarfBuzz shaping, ligatures, fallback fonts, color
                  emoji and Nerd Font icons that spill into the next cell.
                </p>
                <p class="unicode-sample mt-4" aria-hidden="true">Ωμέγα 🧙‍♂️⚗️  ╭─╮ ▓▒░</p>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-config">
                <div class="feature-icon">
                  <span class="hero-adjustments-horizontal size-6"></span>
                </div>
                <h3 class="pp-title-large mt-5">Live config, in Elixir</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  <code class="inline-code">config.exs</code>
                  is plain Elixir, applied to the open window on save. Mistakes show in red in the tab
                  bar, with a suggestion for misspelled settings.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-fullscreen">
                <div class="feature-icon"><span class="hero-window size-6"></span></div>
                <h3 class="pp-title-large mt-5">Full-screen programs</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Alternate screen, scroll regions, mouse reporting, bracketed paste, cursor shapes.
                  Tested with vim, less, htop, btop and tmux.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-windows">
                <div class="feature-icon"><span class="hero-square-2-stack size-6"></span></div>
                <h3 class="pp-title-large mt-5">Many windows, one guiltty</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Each window has its own tabs, locked tabs and broadcast group. Closing one never
                  touches the others; guiltty stops after the last.
                </p>
                <div class="mt-4"><.keys keys="Ctrl+Shift+N" /></div>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-client">
                <div class="feature-icon"><span class="hero-rocket-launch size-6"></span></div>
                <h3 class="pp-title-large mt-5">A window in 0.1 s</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  <code class="inline-code">guiltty</code>
                  is a small client that asks the running guiltty for a window over a private socket,
                  like <code class="inline-code">emacsclient</code>. About 0.1 s with guiltty running, 0.7 s from
                  cold, on the developer's machine.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-performance">
                <div class="feature-icon"><span class="hero-chart-bar size-6"></span></div>
                <h3 class="pp-title-large mt-5">Measured, then faster</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Floods of short lines (<code class="inline-code">seq</code>, logs) land about 3x faster
                  than in v0.13, laid down together and scrolled once. Heavy output is still slow: a big
                  <code class="inline-code">cat</code>
                  runs at 3 to 4 MB/s, and <code class="inline-code">make bench</code>
                  says so.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-scrollback">
                <div class="grid gap-6 md:grid-cols-2 md:items-center">
                  <div>
                    <div class="feature-icon"><span class="hero-magnifying-glass size-6"></span></div>
                    <h3 class="pp-headline-small mt-5">Scrollback, search, selection</h3>
                    <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                      10,000 rows per tab, searched with Enter and Shift+Enter. Select to copy to the
                      primary selection, middle click to paste. Backpressure from the shell to the screen
                      means a flood of output can't outrun the screen.
                    </p>
                  </div>
                  <.terminal id="search-terminal" title="search" body_class="text-[13px]!">
                    <div class="t-dim">[info] worker 3 started</div>
                    <div>[info] request <span class="search-hit">GET /health</span> 200 in 1ms</div>
                    <div class="t-dim">[info] worker 4 started</div>
                    <div>
                      [info] request <span class="search-hit search-hit-current">GET /health</span>
                      200 in 2ms
                    </div>
                    <div class="term-search mt-2">
                      <span class="hero-magnifying-glass-micro size-3.5"></span>
                      GET /health <span class="ml-auto t-dim">2 of 48</span>
                    </div>
                  </.terminal>
                </div>
              </.pp_card>
            </div>
          </div>
        </section>

        <%!-- ───────────────────────── Supervision demo ───────────────────────── --%>
        <section id="supervision" class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
          <div class="grid gap-12 lg:grid-cols-[1fr_1.15fr] lg:items-start">
            <div class="lg:sticky lg:top-28">
              <.section_header eyebrow="Self-healing" title="Go on. Kill something.">
                A simulation of guiltty's real supervision tree. Click a process to kill it and watch what its
                supervisor restarts. In the real thing, you'd barely notice.
              </.section_header>
              <ul class="mt-8 space-y-3 pp-body-medium text-pp-on-surface-variant">
                <li class="flex gap-3">
                  <span class="hero-check-circle size-5 shrink-0 text-pp-primary"></span>
                  Each tab is its own <code class="inline-code">rest_for_one</code>
                  tree: Pty, Screen, Parser.
                </li>
                <li class="flex gap-3">
                  <span class="hero-check-circle size-5 shrink-0 text-pp-primary"></span>
                  Every window is its own Desk: crash one and the others never notice.
                </li>
                <li class="flex gap-3">
                  <span class="hero-check-circle size-5 shrink-0 text-pp-primary"></span>
                  <span>
                    <code class="inline-code">kill -9</code>
                    the renderer and its Desk starts a new Window. The screen heals.
                  </span>
                </li>
              </ul>
              <p class="pp-label-large mt-8 text-pp-on-surface-variant">
                Processes killed:
                <span id="kill-count" class="text-pp-primary tabular-nums">{@kills}</span>
              </p>
            </div>

            <div class="space-y-4">
              <.terminal
                id="supervision-tree"
                title="iex(guiltty@127.0.0.1)1> :observer"
                class="tree-term"
              >
                <ul class="tree" aria-label="guiltty's supervision tree">
                  <li
                    :for={{id, prefix, name, note, killable} <- @tree}
                    id={"node-#{id}"}
                    data-status={@status[id]}
                    class="tree-row"
                  >
                    <span class="t-dim whitespace-pre" aria-hidden="true">{prefix}</span>
                    <%= if killable do %>
                      <button
                        type="button"
                        id={"kill-#{id}"}
                        class="tree-node is-killable"
                        phx-click="kill"
                        phx-value-node={id}
                        disabled={@status[id] != :up}
                        aria-label={"Kill #{name}"}
                      >
                        <span class="tree-dot"></span>{name}
                        <span class="tree-skull hero-bolt-micro size-3.5" aria-hidden="true"></span>
                      </button>
                    <% else %>
                      <span class="tree-node"><span class="tree-dot"></span>{name}</span>
                    <% end %>
                    <span :if={note} class="tree-note t-dim hidden sm:inline">{note}</span>
                    <span class="tree-pid t-dim">
                      {if id == "renderer", do: "pid #{@pids[id] * 31}", else: "<0.#{@pids[id]}.0>"}
                    </span>
                  </li>
                </ul>
              </.terminal>

              <.terminal id="supervision-log" title="log" class="log-term">
                <div id="crash-log" phx-update="stream" class="space-y-0.5">
                  <div id="crash-log-empty" class="hidden only:block t-dim">
                    # click a <span class="t-red">⚡</span> process above to kill it
                  </div>
                  <div :for={{dom_id, entry} <- @streams.log} id={dom_id} class="log-line">
                    <span class="t-dim">{entry.time}</span>
                    <span class={if(entry.kind == :exit, do: "t-red", else: "t-green")}>
                      {if entry.kind == :exit, do: "✗", else: "↻"}
                    </span>
                    {entry.text}
                  </div>
                </div>
              </.terminal>
            </div>
          </div>
        </section>

        <%!-- ───────────────────────── Themes ───────────────────────── --%>
        <section id="themes" class="themes-section border-y border-pp-outline-variant">
          <div class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
            <div class="grid gap-12 lg:grid-cols-[1fr_1.25fr] lg:items-center">
              <div>
                <.section_header eyebrow="Themes" title="Built-in themes. Or bring your own.">
                  Pick one by name, or start from one and change single colors. Every terminal on this
                  page follows your pick.
                </.section_header>
                <div class="mt-8 flex flex-wrap gap-2" role="group" aria-label="Terminal theme">
                  <.pp_chip
                    :for={{slug, name} <- @themes}
                    id={"theme-#{slug}"}
                    variant="filter"
                    group="term-theme"
                    selected={slug == "catppuccin-mocha"}
                    on_toggle={JS.set_attribute({"data-term-theme", slug}, to: "#site")}
                  >
                    {name}
                  </.pp_chip>
                </div>
                <p class="pp-body-small mt-4 text-pp-on-surface-variant">
                  Tomorrow Night is what guiltty uses without a config.
                </p>
              </div>

              <.terminal id="theme-terminal" title="~/.config/guiltty/config.exs" class="theme-term">
                <div class="space-y-3">
                  <div>
                    <span class="t-dim"># the last expression is the config</span><br />
                    <span class="t-white">[</span><br /> &nbsp;&nbsp;<span class="t-cyan">font:</span>
                    <span class="t-white">[</span><span class="t-cyan">family:</span>
                    <span class="t-green">"JetBrainsMono Nerd Font"</span>,
                    <span class="t-cyan">size:</span>
                    <span class="t-yellow">14</span><span class="t-white">]</span>,<br />
                    &nbsp;&nbsp;<span class="t-cyan">ligatures:</span>
                    <span class="t-magenta">true</span>,<br />
                    &nbsp;&nbsp;<span class="t-cyan">theme:</span>
                    <span class="t-green">"<span :for={{slug, _} <- @themes} class={"theme-name theme-name-#{slug}"}>{slug}</span>"</span>,<br />
                    &nbsp;&nbsp;<span class="t-cyan">cursor:</span>
                    <span class="t-white">[</span><span class="t-cyan">style:</span>
                    <span class="t-magenta">:block</span>, <span class="t-cyan">blink:</span>
                    <span class="t-magenta">false</span><span class="t-white">]</span>,<br />
                    &nbsp;&nbsp;<span class="t-cyan">renderer:</span>
                    <span class="t-magenta">:vulkan</span><br />
                    <span class="t-white">]</span>
                  </div>
                  <div class="palette" aria-label="The theme's 16 ANSI colors">
                    <span :for={i <- 0..15} class="palette-swatch" style={"background: var(--t-#{i})"}></span>
                  </div>
                  <div class="truecolor" aria-hidden="true"></div>
                </div>
              </.terminal>
            </div>
          </div>
        </section>

        <%!-- ───────────────────────── Keys ───────────────────────── --%>
        <section id="keys" class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
          <div class="flex flex-wrap items-end justify-between gap-6">
            <.section_header eyebrow="Keys" title="Rebind any of them.">
              The defaults, as they ship; paste (Ctrl+Shift+V) is the one fixed key. Forgot one?
              <.keys keys="Ctrl+Shift+/" /> opens the cheatsheet, built from your own config.
            </.section_header>
          </div>
          <.pp_card variant="outlined" class="mt-12" content_class="p-0!">
            <dl class="key-grid">
              <div :for={{combo, action} <- @keys} class="key-row">
                <dt class="pp-body-medium">{action}</dt>
                <dd><.keys keys={combo} /></dd>
              </div>
            </dl>
          </.pp_card>
        </section>

        <%!-- ───────────────────────── Install ───────────────────────── --%>
        <section id="install" class="bg-pp-surface-container-low border-y border-pp-outline-variant">
          <div class="mx-auto max-w-4xl px-6 py-24 sm:py-32">
            <.section_header
              eyebrow="Install"
              title="Built on your machine. Runs without Elixir."
              class="mx-auto text-center"
            >
              guiltty builds from source, so you need Elixir 1.20 and GCC 15+ once. The installed
              copy carries its own Erlang runtime and needs no root.
            </.section_header>

            <div class="mt-12 space-y-10">
              <div>
                <p class="step-label"><span class="step-num">1</span> What to install first</p>
                <.pp_card variant="outlined" class="mt-4 overflow-hidden" content_class="p-0!">
                  <.pp_tabs id="distro" layout="scrollable" aria-label="Distribution">
                    <.pp_tab
                      :for={{{slug, name, _, _}, i} <- Enum.with_index(@distros)}
                      id="distro"
                      value={slug}
                      default_selected={i == 0}
                    >
                      {name}
                    </.pp_tab>
                  </.pp_tabs>
                  <.pp_tab_panel
                    :for={{{slug, _, cmd, note}, i} <- Enum.with_index(@distros)}
                    id="distro"
                    value={slug}
                    default_selected={i == 0}
                    class="p-4 sm:p-6"
                  >
                    <.code_block id={"deps-#{slug}"} code={cmd} />
                    <p class="pp-body-small mt-3 flex gap-2 text-pp-on-surface-variant">
                      <span class="hero-information-circle size-4 shrink-0 mt-0.5"></span>{note}
                    </p>
                  </.pp_tab_panel>
                </.pp_card>
              </div>

              <div>
                <p class="step-label">
                  <span class="step-num">2</span> Clone it and run the installer
                </p>
                <.code_block
                  id="install-cmd"
                  class="mt-4"
                  code={"git clone #{@github}.git\ncd guiltty\n./install.sh"}
                />
                <div class="mt-4 grid gap-3 sm:grid-cols-3">
                  <div
                    :for={
                      {icon, title, body} <- [
                        {"hero-arrow-path", "Update", "git pull && ./install.sh"},
                        {"hero-trash", "Uninstall", "./install.sh --uninstall"},
                        {"hero-folder", "Elsewhere", "PREFIX=/opt/guiltty ./install.sh"}
                      ]
                    }
                    class="mini-card"
                  >
                    <span class={[icon, "size-5 text-pp-primary"]}></span>
                    <p class="pp-title-small mt-2">{title}</p>
                    <code class="pp-body-small block font-mono text-pp-on-surface-variant">
                      <%!-- Wrap at spaces only, never after a "/" --%>
                      <%= for word <- String.split(body, " ") do %>
                        <span class="whitespace-nowrap">{word}</span>
                      <% end %>
                    </code>
                  </div>
                </div>
              </div>

              <div>
                <p class="step-label"><span class="step-num">3</span> Run it</p>
                <p class="pp-body-medium mt-3 text-pp-on-surface-variant">
                  Type <code class="inline-code">guiltty</code>
                  or find it in your applications menu. It needs a GPU with OpenGL 3.3, and draws with
                  Vulkan where there's a 1.3 driver. It looks best with a Nerd Font, Noto Color Emoji
                  and a font for Chinese, Japanese and Korean.
                </p>
              </div>
            </div>
          </div>
        </section>

        <%!-- ───────────────────────── Timeline ───────────────────────── --%>
        <section id="changelog" class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
          <.section_header eyebrow="The build" title="Implemented in milestones.">
            Each version is one milestone of the build plan, from the first byte through a PTY to a
            client and server. The devlog tells how each one went.
          </.section_header>

          <ol class="milestones mt-14">
            <li :for={{version, name, date, body} <- @milestones} class="milestone">
              <span class="milestone-dot" aria-hidden="true"></span>
              <div class="flex flex-wrap items-baseline gap-x-3">
                <span class="pp-label-large font-mono text-pp-primary">{version}</span>
                <h3 class="pp-title-medium">{name}</h3>
                <span class="pp-label-medium text-pp-on-surface-variant">{date}</span>
              </div>
              <p class="pp-body-medium mt-1 text-pp-on-surface-variant">{body}</p>
            </li>
          </ol>
          <div class="mt-10 flex flex-wrap gap-3">
            <.pp_button href={"#{@github}/blob/master/CHANGELOG.md"} variant="tonal">
              The changelog
            </.pp_button>
            <.pp_button href={"#{@github}/blob/master/DEVLOG.md"} variant="text">
              The devlog
              <:end_icon><.pp_icon name="hero-arrow-up-right" /></:end_icon>
            </.pp_button>
          </div>
        </section>

        <%!-- ───────────────────────── Book ───────────────────────── --%>
        <section id="book" class="bg-pp-surface-container-lowest border-t border-pp-outline-variant">
          <div class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
            <.section_header
              eyebrow="The book"
              title="Learn how a terminal works, from the kernel up."
            >
              guiltty comes with a book: twenty-four chapters with diagrams, one for every part, from
              pseudoterminals to the client and server.
            </.section_header>
            <ol class="mt-12 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
              <li :for={{slug, title} <- @chapters}>
                <a href={book_url(@github, slug)} class="chapter pp-state-layer pp-focus-ring">
                  <span class="chapter-num">{String.slice(slug, 0, 2)}</span>
                  <span class="pp-body-medium">{title}</span>
                </a>
              </li>
            </ol>
          </div>
        </section>

        <%!-- ───────────────────────── Closing CTA ───────────────────────── --%>
        <section class="mx-auto max-w-6xl px-6 py-24">
          <div class="cta">
            <.logo_mark class="size-14 text-pp-on-primary-container cta-mark" />
            <h2 class="pp-display-small-emphasized mt-6 text-balance">
              Go on, try to break it.
            </h2>
            <p class="pp-body-large mt-4 text-pp-on-primary-container/80 max-w-xl mx-auto">
              Linux. Tried on openSUSE Tumbleweed, X11 and an AMD GPU; Wayland, Intel and NVIDIA
              should work but haven't been tried. Open source, MIT licensed.
            </p>
            <div class="mt-8 flex flex-wrap justify-center gap-3">
              <.pp_button href="#install" size="md">Install guiltty</.pp_button>
              <.pp_button href={@github} variant="elevated" size="md">
                <:start_icon><.github_mark class="size-5" /></:start_icon>
                Star it on GitHub
              </.pp_button>
            </div>
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
