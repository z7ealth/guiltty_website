defmodule GuilttyWebsiteWeb.HomeLive do
  @moduledoc """
  The landing page. Almost all of it is static; the one live part is the
  supervision tree, where clicking a process "kills" it and the tree shows
  what guiltty's supervisors restart (from book chapter 12).
  """
  use GuilttyWebsiteWeb, :live_view

  alias GuilttyWebsite.Guiltty

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
    {"hero-bell", "Activity marks"},
    {"hero-photo", "Images"},
    {"hero-view-columns", "Split panes"},
    {"hero-chat-bubble-left-right", "AI key"},
    {"hero-link", "Hyperlinks"},
    {"hero-swatch", "Built-in themes"}
  ]

  # Every default key of each action, from @default_keys in guiltty's
  # lib/guiltty/config.ex (paste is the fixed one): {[keys], action}.
  @keys [
    {["Ctrl+Shift+N"], "New window"},
    {["Ctrl+Shift+T"], "New tab"},
    {["Ctrl+Shift+W"], "Close the pane or tab (asks if busy)"},
    {["Ctrl+PgUp", "Ctrl+Shift+Tab"], "Previous tab"},
    {["Ctrl+PgDn", "Ctrl+Tab"], "Next tab"},
    {["Ctrl+Shift+PgUp"], "Move tab left"},
    {["Ctrl+Shift+PgDn"], "Move tab right"},
    {["Ctrl+Shift+R"], "Rename the tab"},
    {["Shift+PgUp"], "Scroll back"},
    {["Ctrl+Shift+K"], "Clear the scrollback"},
    {["Ctrl+Shift+F"], "Search the scrollback"},
    {["Ctrl+Shift+Z"], "Previous prompt"},
    {["Ctrl+Shift+X"], "Next prompt"},
    {["Ctrl+Shift+C"], "Copy"},
    {["Ctrl+Shift+A"], "Select all"},
    {["Ctrl+Shift+V", "Shift+Insert"], "Paste"},
    {["Ctrl+=", "Ctrl+Shift+=", "Ctrl++"], "Zoom in"},
    {["Ctrl+-"], "Zoom out"},
    {["Ctrl+0"], "Reset zoom"},
    {["Ctrl+,"], "Open the config file"},
    {["Ctrl+Shift+H", "Ctrl+Shift+/"], "The cheatsheet: every key"},
    {["Ctrl+Shift+L"], "Lock the tab 🔒"},
    {["Ctrl+Shift+B"], "Broadcast tabs"},
    {["Ctrl+Shift+Space", "AI key"], "Open the AI tool, and back"},
    {["Ctrl+Shift+O"], "Split the pane right"},
    {["Ctrl+Shift+E"], "Split the pane down"},
    {["Ctrl+Shift+Arrows"], "Focus the pane that way"},
    {["Alt+Shift+Arrows"], "Move the separator"}
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
     "guiltty is a small client that asks the running guiltty for a window, like emacsclient: 0.1 s."},
    {"0.16.1", "Tab comforts and styles", "Nov 1",
     "Busy tabs ask before closing, ● and 🔔 mark tabs you're not looking at, tabs can be renamed and reordered, and drawn flat, powerline, rounded, minimal or with separators."},
    {"0.17.1", "Faster text", "Nov 2",
     "A small C NIF turns printed text into cells: text with accents, CJK or emoji prints about twice as fast, and full-screen redraws about 50% faster."},
    {"0.18.2", "Images and a one-line install", "Nov 6",
     "The Kitty graphics protocol: PNG and raw RGB(A) images that scroll with the text and into the scrollback. Ctrl+, opens the config in your $EDITOR. One line now installs it all."},
    {"0.19.1", "Split panes", "Nov 6",
     "Several shells in one tab, side by side or stacked, each a whole terminal, with a border you can style. Broadcast takes every pane of a tab."},
    {"0.20.1", "A terminal you can rely on", "Nov 9",
     "xterm conformance: 449 esctest2 checks pass, up from 112. Long lines rewrap on resize, the Kitty keyboard protocol, hyperlinks, OSC 52 copy over ssh, jumps between prompts. Right click copies and pastes."},
    {"0.21.0", "The AI key", "Nov 9",
     "One key opens the command-line AI tool you choose in a pane beside you, and back. Only what you select goes to it, and nothing runs until you press Enter."},
    {"0.22.1", "Clickable URLs and select all", "Nov 9",
     "Ctrl+click opens URLs in plain text, like the address a server prints when it starts, not only links a program marked. Hold Ctrl to see them underlined. Ctrl+Shift+A selects all; the AI key moves to Ctrl+Shift+Space."},
    {"0.22.2", "The laptop AI key and ten themes", "Nov 10",
     "The AI key on newer laptops opens the AI tool too. Five more themes, Nord, Tokyo Night, One Dark, Catppuccin Latte and guiltty's own lavender on near-black, which is now the default."},
    {"0.23.3", "The password lock", "Nov 10",
     "While sudo, ssh or anything else reads a password, a lock shows in place of the cursor, so you can tell guiltty is listening even though nothing you type appears."},
    {"0.24.0", "Copy the last output", "Nov 11",
     "Ctrl+Shift+G copies what the last command printed. Ctrl+Shift+J labels every link on screen; type a label to open it. Tabs you're not looking at show ✓ or ✗ when a command finishes, and come back as they were if the part that keeps them crashes."},
    {"0.25.0", "A long command calls you back", "Nov 11",
     "When a command that ran 10 seconds or more finishes while you're in another window, guiltty asks the desktop for attention. With Ctrl held, the pointer is a hand over a link. Observer can attach to a running guiltty and show its tabs' processes and memory."}
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
    {"23-client-server", "Client and server: the guiltty command"},
    {"24-tab-comforts", "Tab comforts: busy tabs, marks, names, order"},
    {"25-tab-styles", "Tab styles: five ways to draw one row"},
    {"26-images", "Images: pictures in a grid of characters"},
    {"27-split-panes", "Split panes: one tab, several shells"},
    {"28-conversation", "The conversation: what programs say to a terminal, and what it answers"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    ids = Enum.map(@tree, &elem(&1, 0))

    {:ok,
     socket
     |> assign(:page_title, "guiltty · a GPU-accelerated terminal emulator in Elixir and C")
     |> assign(:github, Guiltty.github())
     |> assign(:tree, @tree)
     |> assign(:status, Map.new(ids, &{&1, :up}))
     |> assign(:pids, ids |> Enum.with_index() |> Map.new(fn {id, i} -> {id, 212 + i * 7} end))
     |> assign(:next_pid, 400)
     |> assign(:kills, 0)
     |> assign(:hero_scenes, Jason.encode!(@hero_scenes))
     |> assign(:hero_features, @hero_features)
     |> assign(:themes, Guiltty.themes())
     |> assign(:distros, Guiltty.distros())
     |> assign(:tested_versions, Guiltty.tested_versions())
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
        <span class="p10k-dir"><.pp_icon name="hero-home-micro" size="none" class="size-3.5" /><span>~/<b>src</b></span></span>
      </span>
      <span class="p10k-gap"></span>
      <span class="p10k-seg p10k-seg-right">
        <span class="p10k-ok">✔</span>
        <span class="p10k-sub">│</span>
        <span class="p10k-time">
          at <span class="p10k-clock">16:24:55</span>
          <.pp_icon name="hero-clock-micro" size="none" class="size-3.5" />
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
      <div id="site" data-term-theme="guiltty">
        <%!-- ───────────────────────── Hero ───────────────────────── --%>
        <section id="hero" class="hero-section relative flex flex-col justify-center overflow-hidden">
          <div class="hero-grid" aria-hidden="true"></div>
          <div class="hero-glow hero-glow-1" aria-hidden="true"></div>
          <div class="hero-glow hero-glow-2" aria-hidden="true"></div>

          <div class="relative mx-auto w-full max-w-6xl px-6 pt-16 pb-24 sm:pt-24 text-center">
            <a
              href={"#{@github}/blob/master/CHANGELOG.md"}
              class="hero-pill pp-label-large"
              id="hero-release"
            >
              <span class="rounded-pp-full bg-pp-primary px-2 py-0.5 text-pp-on-primary pp-label-medium">
                v0.25.0
              </span>
              <span>A long command calls you back when it finishes</span>
              <.pp_icon name="hero-arrow-right-micro" size="none" class="size-4" />
            </a>

            <h1 class="hero-title mt-8 text-balance">
              Kill it. Crash it.<br />
              <span class="hero-title-accent">Your tabs are still there.</span>
            </h1>

            <p class="pp-body-large sm:text-xl! sm:leading-8! mx-auto mt-6 max-w-2xl text-pp-on-surface-variant text-pretty">
              guiltty is a GPU-accelerated Linux terminal with the power of the BEAM and the speed of
              C, made to be rock solid while maintaining good performance.
            </p>

            <.pp_button_group size="md" class="mt-10 flex-wrap justify-center">
              <.pp_button href="#install" size="md" id="cta-install">
                <:start_icon><.pp_icon name="hero-arrow-down-tray" /></:start_icon>
                Install guiltty
              </.pp_button>
              <.pp_button href={@github} variant="outlined" size="md" id="cta-github">
                <:start_icon><.github_mark class="size-5" /></:start_icon>
                Read the source
              </.pp_button>
            </.pp_button_group>

            <div class="mx-auto mt-6 flex max-w-5xl flex-wrap justify-center gap-2">
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
                  {"● you@linux:~/guiltty", false},
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
                  <.pp_icon name="hero-arrow-path-micro" size="none" class="size-4" />
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
                  {"22", "milestones implemented"},
                  {"2", "renderers, the same pixels"},
                  {"10,000", "rows of scrollback"},
                  {"29", "book chapters on how it works"}
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
            parser and a screen, Elixir processes with a small C helper for printed text, turn them
            into cells. The renderer is a
            separate program that only draws: if it dies, guiltty starts a new one and your tabs are
            still there.
          </.section_header>

          <div class="pipeline mt-14" role="list">
            <div class="pipe-node" role="listitem">
              <span class="pipe-icon"><.pp_icon name="hero-command-line" size="none" class="size-6" /></span>
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
                  <span class="pipe-icon"><.pp_icon name="hero-cpu-chip" size="none" class="size-6" /></span>
                  <p class="pp-title-medium">PTY NIF</p>
                  <p class="pp-body-small text-pp-on-surface-variant">C · enif_select</p>
                </div>
                <div class="pipe-link" aria-hidden="true"><span></span></div>
                <div class="pipe-node">
                  <span class="pipe-icon"><.pp_icon name="hero-funnel" size="none" class="size-6" /></span>
                  <p class="pp-title-medium">Parser</p>
                  <p class="pp-body-small text-pp-on-surface-variant">DEC state machine</p>
                </div>
                <div class="pipe-link" aria-hidden="true"><span></span></div>
                <div class="pipe-node">
                  <span class="pipe-icon"><.pp_icon
                    name="hero-squares-2x2"
                    size="none"
                    class="size-6"
                  /></span>
                  <p class="pp-title-medium">Screen</p>
                  <p class="pp-body-small text-pp-on-surface-variant">grid, scrollback</p>
                </div>
              </div>
            </div>
            <div class="pipe-link" aria-hidden="true"><span></span></div>
            <div class="pipe-node pipe-node-gpu" role="listitem">
              <span class="pipe-icon"><.pp_icon name="hero-sparkles" size="none" class="size-6" /></span>
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
                <div class="feature-icon">
                  <.pp_icon name="hero-sparkles" size="none" class="size-6" />
                </div>
                <h3 class="pp-headline-small mt-5">Vulkan 1.3, or OpenGL. Same pixels.</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant max-w-lg">
                  guiltty draws with Vulkan by default. No driver? It falls back to OpenGL by itself and
                  says so in the tab bar, and <code class="inline-code">GUILTTY_RENDERER=gl</code>
                  picks one
                  for a run. A test replays recorded frames through both and checks they match, pixel
                  for pixel.
                </p>
                <div class="pixel-compare mt-6" aria-hidden="true">
                  <div class="pixel-pane"><span class="pp-label-medium">guiltty_vk</span></div>
                  <span class="pp-title-medium text-pp-primary">=</span>
                  <div class="pixel-pane"><span class="pp-label-medium">guiltty_gl</span></div>
                </div>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-lock">
                <div class="feature-icon">
                  <.pp_icon name="hero-lock-closed" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Lockable tabs</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Lock a tab and close its window: it keeps running, and the next
                  <code class="inline-code">guiltty</code>
                  brings that window back with it.
                </p>
                <div class="mt-4"><.keys keys="Ctrl+Shift+L" /></div>
              </.pp_card>

              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-images">
                <div class="grid gap-6 md:grid-cols-2 md:items-center">
                  <div>
                    <div class="feature-icon">
                      <.pp_icon name="hero-photo" size="none" class="size-6" />
                    </div>
                    <h3 class="pp-headline-small mt-5">Pictures, in the terminal</h3>
                    <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                      guiltty speaks the Kitty graphics protocol, so programs that use it show
                      pictures: PNG or raw RGB(A), sent in chunks, scrolling with the text and into
                      the scrollback. Images read from a file path are refused, so a remote program
                      can't read your files with them.
                    </p>
                  </div>
                  <.terminal id="images-terminal" title="Kitty graphics" body_class="text-[13px]!">
                    <img
                      src={~p"/images/guiltty-icon.png"}
                      alt="guiltty's icon, drawn in the terminal"
                      class="images-demo"
                      width="128"
                      height="128"
                    />
                    <div class="mt-2">
                      <span class="t-magenta">❯</span> <span class="t-cursor"></span>
                    </div>
                  </.terminal>
                </div>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-broadcast">
                <div class="feature-icon">
                  <.pp_icon name="hero-signal" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Safe broadcast</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Type once into every tab in the group, every pane of each. If a connection drops, typing goes nowhere, so a command
                  meant for your servers doesn't land on your own machine.
                </p>
                <div class="mt-4"><.keys keys="Ctrl+Shift+B" /></div>
              </.pp_card>

              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-panes">
                <div class="feature-icon">
                  <.pp_icon name="hero-view-columns" size="none" class="size-6" />
                </div>
                <h3 class="pp-headline-small mt-5">Split panes</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant max-w-xl">
                  Several shells in one tab, side by side or stacked. Each pane is a whole terminal,
                  with its own scrollback, search, selection and images. Move the focus with the keys
                  or a click, and the separator with the keys.
                </p>
                <div class="mt-4 flex flex-wrap gap-x-4 gap-y-2">
                  <.keys keys="Ctrl+Shift+O" />
                  <.keys keys="Ctrl+Shift+E" />
                </div>
                <%!-- As guiltty draws it: a thin separator, the focused pane is the one
                      with the cursor, the title follows it --%>
                <.terminal
                  id="panes-terminal"
                  title="mix phx.server"
                  tabs={[{"mix phx.server", true}]}
                  class="mt-6"
                  body_class="panes-body"
                >
                  <div class="pane">
                    <.p10k_prompt />
                    <div><span class="p10k-frame">╰─</span></div>
                  </div>
                  <div class="pane">
                    <.p10k_prompt />
                    <div><span class="p10k-frame">╰─</span> mix phx.server</div>
                    <div>[info] Running Endpoint at 127.0.0.1:4000</div>
                    <div>[info] Access it at http://localhost:4000</div>
                    <div>[watch] build finished, watching for changes...</div>
                    <div class="t-cyan">[debug] Replied in 136µs</div>
                    <div><span class="t-cursor"></span></div>
                  </div>
                </.terminal>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-windows">
                <div class="feature-icon">
                  <.pp_icon name="hero-square-2-stack" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Many windows, one guiltty</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Each window has its own tabs, locked tabs and broadcast group. Closing one never
                  touches the others; guiltty stops after the last.
                </p>
                <div class="mt-4"><.keys keys="Ctrl+Shift+N" /></div>
              </.pp_card>

              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-ai">
                <div class="feature-icon">
                  <.pp_icon name="hero-chat-bubble-left-right" size="none" class="size-6" />
                </div>
                <h3 class="pp-headline-small mt-5">The AI key</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant max-w-xl">
                  Set <code class="inline-code">ai: [command: "your-ai-tool"]</code>
                  and one key opens it in a pane beside you, in the folder you're in; press it again to
                  go back. Only what you select goes to its prompt, without Enter. guiltty just starts
                  the program: no API keys, no accounts, any command-line tool.
                </p>
                <div class="mt-4 flex flex-wrap items-center gap-2">
                  <.keys keys="Ctrl+Shift+Space" />
                  <span class="pp-body-small text-pp-on-surface-variant">or the laptop's</span>
                  <.keys keys="AI key" />
                </div>
                <%!-- The shell on the left with an error selected; the AI tool on
                      the right, focused, the selection pasted at its prompt --%>
                <.terminal
                  id="ai-terminal"
                  title="your-ai-tool"
                  tabs={[{"your-ai-tool", true}]}
                  class="mt-6"
                  body_class="panes-body"
                >
                  <div class="pane">
                    <.p10k_prompt />
                    <div><span class="p10k-frame">╰─</span> mix test</div>
                    <div class="t-red">1) test login (AuthTest)</div>
                    <div><span class="search-hit">** (KeyError) key :email not found</span></div>
                    <div class="t-dim">test/auth_test.exs:14</div>
                  </div>
                  <div class="pane">
                    <div class="t-dim">your-ai-tool</div>
                    <div class="mt-2">
                      <span class="t-magenta">&gt;</span>
                      ** (KeyError) key :email not found<span class="t-cursor"></span>
                    </div>
                  </div>
                </.terminal>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-conformance">
                <div class="feature-icon">
                  <.pp_icon name="hero-check-badge" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Speaks xterm</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  449 esctest2 checks pass. Long lines rewrap on resize, Alt works as Meta, the Kitty
                  keyboard protocol tells Ctrl+I from Tab, Ctrl+click opens links and plain URLs, and copying
                  over ssh reaches your clipboard. Programs can never read it.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-unicode">
                <div class="feature-icon">
                  <.pp_icon name="hero-language" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Unicode, properly</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Grapheme clusters, wide characters, HarfBuzz shaping, ligatures, fallback fonts, color
                  emoji and Nerd Font icons that spill into the next cell.
                </p>
                <p class="unicode-sample mt-4" aria-hidden="true">Ωμέγα 🧙‍♂️⚗️  ╭─╮ ▓▒░</p>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-config">
                <div class="feature-icon">
                  <.pp_icon name="hero-adjustments-horizontal" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Live config, in Elixir</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  <code class="inline-code">config.exs</code>
                  is plain Elixir, applied to the open window on save. Mistakes show in red in the tab
                  bar, with a suggestion for misspelled settings.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-fullscreen">
                <div class="feature-icon">
                  <.pp_icon name="hero-window" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Full-screen programs</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Alternate screen, scroll regions, mouse reporting, bracketed paste, cursor shapes,
                  focus events, synchronized output. Tested in real sessions of vim, less, htop, btop,
                  mc and tmux.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-performance">
                <div class="feature-icon">
                  <.pp_icon name="hero-chart-bar" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">Measured, then faster</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  Floods of short lines (<code class="inline-code">seq</code>, logs) land about 3x faster
                  than in v0.13, laid down together and scrolled once. Since v0.17, text with accents,
                  CJK or emoji prints about twice as fast, and full-screen redraws about 50% faster.
                  <code class="inline-code">make bench</code>
                  measures it.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="feature-card" id="feature-client">
                <div class="feature-icon">
                  <.pp_icon name="hero-rocket-launch" size="none" class="size-6" />
                </div>
                <h3 class="pp-title-large mt-5">A window in 0.1 s</h3>
                <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                  <code class="inline-code">guiltty</code>
                  is a small client that asks the running guiltty for a window over a private socket,
                  like <code class="inline-code">emacsclient</code>. About 0.1 s with guiltty running, 0.7 s from
                  cold, on the developer's machine.
                </p>
              </.pp_card>

              <.pp_card variant="filled" class="bento-wide feature-card" id="feature-scrollback">
                <div class="grid gap-6 md:grid-cols-2 md:items-center">
                  <div>
                    <div class="feature-icon">
                      <.pp_icon name="hero-magnifying-glass" size="none" class="size-6" />
                    </div>
                    <h3 class="pp-headline-small mt-5">Scrollback, search, selection</h3>
                    <p class="pp-body-medium mt-2 text-pp-on-surface-variant">
                      10,000 rows per tab, searched with Enter and Shift+Enter. Select to copy to the
                      primary selection, middle click to paste; a right click copies it and pastes it at the
                      prompt under the pointer. Backpressure from the shell to the screen
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
                      <.pp_icon name="hero-magnifying-glass-micro" size="none" class="size-3.5" />
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
          <div class="grid grid-cols-1 gap-12 lg:grid-cols-[1fr_1.15fr] lg:items-start [&>*]:min-w-0">
            <div class="lg:sticky lg:top-28">
              <.section_header eyebrow="Self-healing" title="Go on. Kill something.">
                A simulation of guiltty's real supervision tree. Click a process to kill it and watch what its
                supervisor restarts. In the real thing, you'd barely notice.
              </.section_header>
              <ul class="mt-8 space-y-3 pp-body-medium text-pp-on-surface-variant">
                <li class="flex gap-3">
                  <.pp_icon
                    name="hero-check-circle"
                    size="none"
                    class="size-5 shrink-0 text-pp-primary"
                  />
                  <span>
                    Each tab is its own <code class="inline-code">rest_for_one</code>
                    tree: Pty, Screen, Parser.
                  </span>
                </li>
                <li class="flex gap-3">
                  <.pp_icon
                    name="hero-check-circle"
                    size="none"
                    class="size-5 shrink-0 text-pp-primary"
                  /> Every window is its own Desk: crash one and the others never notice.
                </li>
                <li class="flex gap-3">
                  <.pp_icon
                    name="hero-check-circle"
                    size="none"
                    class="size-5 shrink-0 text-pp-primary"
                  />
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
            <div class="grid grid-cols-1 gap-12 lg:grid-cols-[1fr_1.25fr] lg:items-center [&>*]:min-w-0">
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
                    selected={slug == "guiltty"}
                    on_toggle={JS.set_attribute({"data-term-theme", slug}, to: "#site")}
                  >
                    {name}
                  </.pp_chip>
                </div>
                <p class="pp-body-small mt-4 text-pp-on-surface-variant">
                  guiltty's own, the icon's lavender on near-black, is what it uses without a config.
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
              <.keys keys="Ctrl+Shift+H" /> opens the cheatsheet, built from your own config.
            </.section_header>
          </div>
          <.pp_card variant="outlined" class="mt-12" content_class="py-2!">
            <.pp_list id="keys-list" class="key-list" aria-label="Default keys">
              <%!-- three_line so a long label wraps on phones; the rows stay
                    one-line height and centered (PhoenixPaper's ! overrides) --%>
              <.pp_list_item
                :for={{combos, action} <- @keys}
                three_line
                class="min-h-14! items-center! py-2!"
              >
                {action}
                <:trailing>
                  <span class="flex flex-col items-end gap-1">
                    <.keys :for={combo <- combos} keys={combo} />
                  </span>
                </:trailing>
              </.pp_list_item>
            </.pp_list>
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
              guiltty builds from source, so you need Elixir 1.18+ on Erlang/OTP 26+, and GCC 15+,
              once. The installed copy carries its own Erlang runtime and needs no root.
            </.section_header>

            <div id="install-one-line" class="mt-12">
              <p class="step-label">
                <span class="step-num"><.pp_icon name="hero-bolt-micro" size="xs" /></span> One line
              </p>
              <.code_block id="one-line-cmd" class="mt-4" code={Guiltty.one_line_install()} />
              <p class="pp-body-small mt-3 text-pp-on-surface-variant">
                For openSUSE, Fedora, Ubuntu/Debian and Arch. Asks before using <code class="inline-code">sudo</code>; run it again to update.
                <a href={Guiltty.get_sh_url()} class="text-pp-primary underline underline-offset-2">
                  Read the script
                </a>
                ·
                <.link
                  navigate={~p"/docs#install"}
                  class="text-pp-primary underline underline-offset-2"
                >Options</.link>
              </p>
            </div>

            <.pp_typography variant="title-medium" tag="h3" class="mt-14 mb-6">
              Or by hand
            </.pp_typography>

            <div class="space-y-10">
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
                      <.pp_icon
                        name="hero-information-circle"
                        size="none"
                        class="size-4 shrink-0 mt-0.5"
                      />{note}
                    </p>
                  </.pp_tab_panel>
                </.pp_card>
                <p class="pp-body-small mt-3 text-pp-on-surface-variant">
                  openSUSE Tumbleweed has been tried all the way to a running guiltty. On the others,
                  these package names were found in fresh containers of each, but the build itself
                  hasn't been tried.
                </p>

                <div id="versions" class="mt-8">
                  <p class="pp-title-small">Tested Elixir and Erlang/OTP</p>
                  <p class="pp-body-small mt-1 text-pp-on-surface-variant">
                    The minimum is Elixir 1.18 on Erlang/OTP 26. Older versions aren't supported.
                  </p>
                  <.pp_table_container class="mt-3">
                    <.pp_table id="versions-table">
                      <.pp_table_head>
                        <.pp_table_row>
                          <.pp_table_cell variant="head">Elixir</.pp_table_cell>
                          <.pp_table_cell variant="head">Erlang/OTP</.pp_table_cell>
                          <.pp_table_cell variant="head">Status</.pp_table_cell>
                        </.pp_table_row>
                      </.pp_table_head>
                      <.pp_table_body>
                        <.pp_table_row :for={{elixir, otp, status} <- @tested_versions}>
                          <.pp_table_cell class="font-mono">{elixir}</.pp_table_cell>
                          <.pp_table_cell class="font-mono">{otp}</.pp_table_cell>
                          <.pp_table_cell>
                            <span class="inline-flex items-center gap-1.5">
                              <.pp_icon
                                name="hero-check-circle-micro"
                                size="none"
                                class="size-4 text-pp-primary"
                              />
                              {status}
                            </span>
                          </.pp_table_cell>
                        </.pp_table_row>
                      </.pp_table_body>
                    </.pp_table>
                  </.pp_table_container>
                </div>
              </div>

              <div>
                <p class="step-label">
                  <span class="step-num">2</span> Clone it and run the installer
                </p>
                <.code_block
                  id="install-cmd"
                  class="mt-4"
                  code={Guiltty.install_command()}
                />
                <div class="mt-4 grid gap-3 sm:grid-cols-3">
                  <.pp_card
                    :for={
                      {icon, title, body} <- [
                        {"hero-arrow-path", "Update", "git pull && ./install.sh"},
                        {"hero-trash", "Uninstall", "./install.sh --uninstall"},
                        {"hero-folder", "Elsewhere", "PREFIX=/opt/guiltty ./install.sh"}
                      ]
                    }
                    variant="outlined"
                    content_class="p-4!"
                  >
                    <.pp_icon name={icon} size="sm" class="text-pp-primary" />
                    <.pp_typography variant="title-small" class="mt-2">{title}</.pp_typography>
                    <code class="pp-body-small block font-mono text-pp-on-surface-variant">
                      <%!-- Wrap at spaces only, never after a "/" --%>
                      <%= for word <- String.split(body, " ") do %>
                        <span class="whitespace-nowrap">{word}</span>
                      <% end %>
                    </code>
                  </.pp_card>
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
                <.pp_button href="/docs" variant="tonal" class="mt-6" id="install-docs">
                  <:start_icon>
                    <.pp_icon name="hero-book-open" size="none" class="size-5" />
                  </:start_icon>
                  Read the docs: keys, settings, themes
                </.pp_button>
              </div>
            </div>
          </div>
        </section>

        <%!-- ───────────────────────── Timeline ───────────────────────── --%>
        <section id="changelog" class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
          <.section_header eyebrow="The build" title="Implemented in milestones.">
            Each version is one milestone of the build plan, from the first byte through a PTY to
            tab comforts. The devlog tells how each one went.
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
          <.pp_button_group class="mt-10 flex-wrap">
            <.pp_button href={"#{@github}/blob/master/CHANGELOG.md"} variant="tonal">
              The changelog
            </.pp_button>
            <.pp_button href={"#{@github}/blob/master/DEVLOG.md"} variant="text">
              The devlog
              <:end_icon><.pp_icon name="hero-arrow-up-right" /></:end_icon>
            </.pp_button>
          </.pp_button_group>
        </section>

        <%!-- ───────────────────────── Book ───────────────────────── --%>
        <section id="book" class="bg-pp-surface-container-lowest border-t border-pp-outline-variant">
          <div class="mx-auto max-w-6xl px-6 py-24 sm:py-32">
            <.section_header
              eyebrow="The book"
              title="Learn how a terminal works, from the kernel up."
            >
              guiltty comes with a book: twenty-nine chapters with diagrams, one for every part, from
              pseudoterminals to the escape sequences programs send.
            </.section_header>
            <ol
              id="chapters"
              class="chapters is-collapsed mt-12 grid gap-3 sm:grid-cols-2 lg:grid-cols-4"
            >
              <li :for={{slug, title} <- @chapters}>
                <.pp_card
                  variant="outlined"
                  href={book_url(@github, slug)}
                  class="chapter-card h-full"
                  content_class="flex items-start gap-3 p-4!"
                >
                  <span class="chapter-num">{String.slice(slug, 0, 2)}</span>
                  <.pp_typography variant="body-medium" tag="span">{title}</.pp_typography>
                </.pp_card>
              </li>
            </ol>
            <.pp_button
              id="chapters-more"
              variant="outlined"
              class="chapters-more mt-4 w-full sm:hidden"
              phx-click={JS.remove_class("is-collapsed", to: "#chapters") |> JS.hide()}
            >
              Show all {length(@chapters)} chapters
            </.pp_button>
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
              Linux. Tried on openSUSE Tumbleweed, on X11 and Wayland (GNOME), with an AMD GPU;
              Intel and NVIDIA should work but haven't been tried. Open source, MIT licensed.
            </p>
            <.pp_button_group size="md" class="mt-8 flex-wrap justify-center">
              <.pp_button href="#install" size="md">Install guiltty</.pp_button>
              <.pp_button href={@github} variant="elevated" size="md">
                <:start_icon><.github_mark class="size-5" /></:start_icon>
                Star it on GitHub
              </.pp_button>
            </.pp_button_group>
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
