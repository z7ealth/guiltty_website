defmodule GuilttyWebsiteWeb.DocsLive do
  @moduledoc """
  The documentation: installing, using and configuring guiltty, on one
  page with a sidebar. Everything here comes from guiltty's README,
  `priv/config.example.exs`, `lib/guiltty/config.ex` and its book; keep it
  to what those say.
  """
  use GuilttyWebsiteWeb, :live_view

  alias GuilttyWebsite.Guiltty

  # The sidebar: {group, [{id, title}]}. Each id is a section on the page.
  @toc [
    {"Getting started",
     [
       {"overview", "Overview"},
       {"requirements", "Requirements"},
       {"install", "Install"},
       {"update", "Update and uninstall"}
     ]},
    {"Using guiltty",
     [
       {"windows-and-tabs", "Windows and tabs"},
       {"scrollback", "Scrollback, search, selection"},
       {"broadcast", "Broadcast"},
       {"keys", "Keys"}
     ]},
    {"Configuration",
     [
       {"config-file", "The config file"},
       {"settings", "Settings"},
       {"themes", "Themes"},
       {"tab-styles", "Tab styles"},
       {"fonts", "Fonts and ligatures"},
       {"renderer", "Vulkan or OpenGL"},
       {"example-config", "Example config"}
     ]},
    {"Reference",
     [
       {"command", "The guiltty command"},
       {"environment", "Environment variables"},
       {"troubleshooting", "Troubleshooting"},
       {"hacking", "Building from source"},
       {"learn-more", "Learn more"}
     ]}
  ]

  # Every action in `keys:`, with its defaults, from @default_keys in
  # lib/guiltty/config.ex: {action, [key], what it does}.
  @bindings [
    {"new_window", ["ctrl+shift+n"], "A new window, with its own tabs."},
    {"new_tab", ["ctrl+shift+t"], "A new tab."},
    {"close_tab", ["ctrl+shift+w"],
     "Close the tab. If it's running a program, the tab bar says what, and pressing it again closes it."},
    {"next_tab", ["ctrl+page_down", "ctrl+tab"], "The next tab."},
    {"prev_tab", ["ctrl+page_up", "ctrl+shift+tab"], "The previous tab."},
    {"move_tab_left", ["ctrl+shift+page_up"], "Move the tab left."},
    {"move_tab_right", ["ctrl+shift+page_down"], "Move the tab right."},
    {"rename_tab", ["ctrl+shift+r"],
     "Rename the tab: type a name, Enter. An empty name gives the program's title back."},
    {"scroll_page_up", ["shift+page_up"], "Scroll back a page."},
    {"scroll_page_down", ["shift+page_down"], "Scroll forward a page."},
    {"scroll_top", ["shift+home"], "Scroll to the oldest row."},
    {"scroll_bottom", ["shift+end"], "Scroll back to the prompt."},
    {"clear_scrollback", ["ctrl+shift+k"], "Drop the tab's scrollback; the screen stays."},
    {"search", ["ctrl+shift+f"],
     "Search the scrollback: Enter finds older, Shift+Enter newer, Escape ends."},
    {"copy", ["ctrl+shift+c"], "Copy the selection to the clipboard."},
    {"zoom_in", ["ctrl+=", "ctrl+shift+="], "Bigger text."},
    {"zoom_out", ["ctrl+-"], "Smaller text."},
    {"zoom_reset", ["ctrl+0"], "The configured size again."},
    {"open_config", ["ctrl+,"],
     "Open the config file in your editor, creating it from the example first."},
    {"cheatsheet", ["ctrl+shift+/"], "Every key, as you bound it, on one page."},
    {"lock_tab", ["ctrl+shift+l"], "Lock the tab, so it outlives its window."},
    {"broadcast", ["ctrl+shift+b"], "Put the tab in the broadcast group, or take it out."}
  ]

  # Every setting, from defaults/0 and the checks in lib/guiltty/config.ex:
  # {setting, default, accepts, notes}. A {:text, _} default is words, not
  # a value.
  @settings [
    {"font", ~s([family: "monospace", size: 18]), "family: any fontconfig name; size: 6 to 96",
     nil},
    {"theme", ~s("tomorrow-night"), "a built-in name, or your own colors", "See Themes."},
    {"cursor", "[style: :block, blink: false]", "style: :block, :bar or :underline",
     "Programs can change the style while they run (vim shows a bar in insert mode); it comes back when they're done."},
    {"window: padding", "6", "0 to 100", "Pixels around the text; more on a HiDPI screen."},
    {"window: columns, rows", "80, 24", "10 to 1000, 3 to 1000",
     "The size of a new window, in cells."},
    {"window: opacity", "1.0", "0.1 to 1.0",
     "The background's. Needs a compositor; applies to windows opened after a change."},
    {"shell", {:text, "your login shell"}, ~s([command: "/usr/bin/zsh", args: ["-l"]]),
     "The program each new tab runs."},
    {"working_directory", ":inherit", ":inherit, :home or a path",
     ":inherit starts a new tab where the current tab's shell is."},
    {"copy_on_select", "true", "true, :clipboard or false",
     "true copies a selection to the primary selection; :clipboard to the clipboard too; false copies nothing until Ctrl+Shift+C."},
    {"wheel_lines", "3", "1 to 50", "Rows the mouse wheel scrolls per step."},
    {"bold_is_bright", "true", "true or false",
     "Bold text in the 8 basic colors uses their bright versions, as xterm does."},
    {"broadcast_programs", ~s(["ssh", "mosh-client"]), "a list of program names",
     "What a tab must be running to join the broadcast group."},
    {"tab_bar", ":bottom", ":bottom or :top", nil},
    {"tab_style", ":flat", ":flat, :powerline, :rounded, :minimal or :separators",
     "How the tabs look. Their colors are in the theme."},
    {"ligatures", "true", "true or false",
     "Join ->, !=, |> and the like into one symbol, when the font has ligatures."},
    {"renderer", ":vulkan", ":vulkan or :gl",
     "Applies to windows opened after a change. GUILTTY_RENDERER wins over it."},
    {"scrollback", "10_000", "0 to 1,000,000",
     "Rows each tab keeps for scrolling back; applies to new tabs."},
    {"keys", {:text, "see Keys"}, "action: [key, ...]",
     "Any action you leave out keeps its default."}
  ]

  @custom_theme ~S"""
  theme: [
    name: "catppuccin-mocha",
    fg: "#c5c8c6",
    bg: "#1d1f21",
    cursor: "#c5c8c6",
    # black, red, green, yellow, blue, magenta, cyan, white, then bright
    ansi: ~w(#1d1f21 #cc6666 #b5bd68 #f0c674 #81a2be #b294bb #8abeb7 #c5c8c6
             #969896 #d54e53 #b9ca4a #e7c547 #7aa6da #c397d8 #70c0b1 #eaeaea),
    # The tab bar's colors. Any you leave out are worked out from the
    # theme, to suit the tab_style.
    tab_bar: "#282a36",
    tab_text: "#6272a4",
    tab_active: "#ff79c6",
    tab_active_text: "#282a36",
    tab_accent: "#ff79c6"
  ]
  """

  # The tab styles: {style, what it looks like}, from priv/config.example.exs.
  @tab_styles [
    {"flat", "Side by side, the active one lighter, with a line along its edge. The default."},
    {"powerline", "Colored blocks joined by arrows."},
    {"rounded", "Pills with round ends, the active one filled."},
    {"minimal", "No bar: titles on the terminal's background, the line under the active one."},
    {"separators", "Titles between thin bars, the active one filled."}
  ]

  @keys_example ~S"""
  keys: [
    new_tab: ["ctrl+t"],
    search: ["ctrl+shift+f", "f3"]
  ]
  """

  # guiltty's priv/config.example.exs, as it ships.
  @example_config ~S"""
  [
    font: [family: "monospace", size: 18],

    # A built-in theme by name: "catppuccin-mocha", "tomorrow-night" (what
    # guiltty uses without a config), "dracula", "gruvbox-dark" or
    # "solarized-dark".
    theme: "catppuccin-mocha",

    # :block, :bar or :underline. Programs can change it while they run (vim
    # shows a bar in insert mode); it comes back when they're done.
    cursor: [style: :block, blink: false],

    window: [
      # Pixels around the text (more on a HiDPI screen).
      padding: 6,
      # The size of a new window, in cells.
      columns: 80,
      rows: 24,
      # The background's opacity, 0.1 to 1.0. Needs a compositor; applies to
      # windows opened after a change.
      opacity: 1.0
    ],

    # The program each new tab runs. Without a command: your login shell.
    # shell: [command: "/usr/bin/zsh", args: ["-l"]],

    # Where a new tab starts: :inherit (where the current tab's shell is),
    # :home, or a path.
    working_directory: :inherit,

    # Selecting text copies it to the primary selection (middle click pastes
    # it); :clipboard copies it to the clipboard too; false copies nothing
    # until Ctrl+Shift+C.
    copy_on_select: true,

    # Rows the mouse wheel scrolls per step.
    wheel_lines: 3,

    # Bold text in the 8 basic colors uses their bright versions, as xterm
    # does.
    bold_is_bright: true,

    # Broadcast (Ctrl+Shift+B): a tab may join only while it runs one of
    # these. If one of them stops (a dropped connection), typing goes nowhere
    # until that tab leaves the group. A local tab (your own shell) joins on
    # a second Ctrl+Shift+B, and isn't checked.
    broadcast_programs: ["ssh", "mosh-client"],

    # Where the tabs go: :bottom (the default) or :top.
    tab_bar: :bottom,

    # How the tabs look:
    #   :flat        (the default) side by side, the active one lighter, with
    #                a line along its edge
    #   :powerline   colored blocks joined by arrows
    #   :rounded     pills with round ends, the active one filled
    #   :minimal     no bar: titles on the terminal's background, the line
    #                under the active one
    #   :separators  titles between thin bars, the active one filled
    # Their colors are in theme: (tab_bar, tab_active, ... above).
    tab_style: :flat,

    # Join ->, !=, |>, => and the like into one symbol, when the font has
    # ligatures (JetBrains Mono and Fira Code do; Source Code Pro doesn't).
    ligatures: true,

    # How guiltty draws: :vulkan, or :gl (OpenGL). If Vulkan can't start
    # (no driver, no GPU that can show the window), guiltty says so and
    # draws with OpenGL. Applies to windows opened after a change.
    # GUILTTY_RENDERER=gl (or vulkan) in guiltty's environment wins over
    # this, to try the other one for a run: `guiltty stop`, then
    # `GUILTTY_RENDERER=gl guiltty`.
    renderer: :vulkan,

    # Rows of output each tab keeps for scrolling back (new tabs only).
    scrollback: 10_000,

    # Each action takes a list of keys. Names: letters, digits, f1-f12,
    # tab, enter, page_up, page_down, home, end, insert, delete, or a
    # punctuation character like = or -, with any of the ctrl+, shift+ and
    # alt+ modifiers.
    keys: [
      new_window: ["ctrl+shift+n"],
      new_tab: ["ctrl+shift+t"],
      close_tab: ["ctrl+shift+w"],
      next_tab: ["ctrl+page_down", "ctrl+tab"],
      prev_tab: ["ctrl+page_up", "ctrl+shift+tab"],
      move_tab_left: ["ctrl+shift+page_up"],
      move_tab_right: ["ctrl+shift+page_down"],
      rename_tab: ["ctrl+shift+r"],
      scroll_page_up: ["shift+page_up"],
      scroll_page_down: ["shift+page_down"],
      scroll_top: ["shift+home"],
      scroll_bottom: ["shift+end"],
      clear_scrollback: ["ctrl+shift+k"],
      search: ["ctrl+shift+f"],
      copy: ["ctrl+shift+c"],
      zoom_in: ["ctrl+=", "ctrl+shift+="],
      zoom_out: ["ctrl+-"],
      zoom_reset: ["ctrl+0"],
      open_config: ["ctrl+,"],
      cheatsheet: ["ctrl+shift+/"],
      lock_tab: ["ctrl+shift+l"],
      broadcast: ["ctrl+shift+b"]
    ]
  ]
  """

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Docs · guiltty")
     |> assign(:github, Guiltty.github())
     |> assign(:example_url, Guiltty.github_path("priv/config.example.exs"))
     |> assign(:toc, @toc)
     |> assign(:bindings, @bindings)
     |> assign(:settings, @settings)
     |> assign(:distros, Guiltty.distros())
     |> assign(:tested_versions, Guiltty.tested_versions())
     |> assign(:themes, Guiltty.themes())
     |> assign(:install_command, Guiltty.install_command())
     |> assign(:custom_theme, String.trim(@custom_theme))
     |> assign(:tab_styles, @tab_styles)
     |> assign(:keys_example, String.trim(@keys_example))
     |> assign(:example_config, String.trim(@example_config))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="docs" class="mx-auto max-w-6xl px-6 py-12 sm:py-16">
        <header class="max-w-2xl">
          <p class="pp-label-large uppercase tracking-[0.2em] text-pp-primary">Documentation</p>
          <h1 class="pp-display-small-emphasized mt-3">Install, use and configure guiltty.</h1>
          <p class="pp-body-large mt-4 text-pp-on-surface-variant text-pretty">
            Everything here is also in guiltty's
            <a class="doc-link" href={Guiltty.github_path("README.md")}>README</a>
            and <a class="doc-link" href={@example_url}>example config</a>. How each part works is in <a
              class="doc-link"
              href={"#{@github}/tree/master/book"}
            >the book</a>.
          </p>
        </header>

        <div class="mt-12 grid gap-12 lg:grid-cols-[14rem_1fr]">
          <nav id="docs-toc" class="docs-toc" aria-label="Documentation" phx-hook=".DocsToc">
            <div :for={{group, sections} <- @toc} class="docs-toc-group">
              <p class="pp-label-medium uppercase tracking-widest text-pp-on-surface-variant">
                {group}
              </p>
              <ul class="mt-2 space-y-0.5">
                <li :for={{id, title} <- sections}>
                  <a href={"##{id}"} class="docs-toc-link" data-section={id}>{title}</a>
                </li>
              </ul>
            </div>
          </nav>

          <article class="doc min-w-0">
            <%!-- ───────────────────────── Getting started ───────────────────────── --%>
            <.doc_section id="overview" title="Overview">
              <p>
                guiltty is a GPU-accelerated terminal emulator in Elixir and C. Elixir holds the
                behavior: the parser, the screen, tabs, windows, config. C does the syscalls and the
                pixels: a PTY NIF, a renderer (Vulkan, or OpenGL) that runs as its own process, and
                the small <code>guiltty</code> command.
              </p>
              <p>
                It runs on Linux only. It's been tried on openSUSE Tumbleweed, X11 and an AMD GPU;
                Wayland, Intel, NVIDIA and other distributions should work but haven't been tried.
              </p>
              <.doc_note>
                guiltty isn't fast at heavy output: a big <code>cat</code>
                goes by at about 3 to 4 MB/s (book chapter 22).
              </.doc_note>
            </.doc_section>

            <.doc_section id="requirements" title="Requirements">
              <p>
                guiltty is built from source on your machine, so installing it needs Elixir and a C
                toolchain. The installed copy carries its own Erlang runtime: once it's installed, it
                runs without Elixir.
              </p>
              <.doc_table id="requirements-table" head={["What", "Why"]}>
                <tr>
                  <td>Elixir 1.18+, Erlang/OTP 26+</td>
                  <td>building guiltty and its release</td>
                </tr>
                <tr>
                  <td>GCC 15+, make, pkg-config</td>
                  <td>the C is C23 and uses <code>#embed</code></td>
                </tr>
                <tr>
                  <td>SDL3 (development files)</td>
                  <td>the window, keyboard and mouse</td>
                </tr>
                <tr>
                  <td>FreeType, fontconfig, HarfBuzz (dev files)</td>
                  <td>finding fonts, drawing and shaping text</td>
                </tr>
                <tr>
                  <td>Vulkan loader and headers (dev files)</td>
                  <td>the Vulkan renderer</td>
                </tr>
                <tr>
                  <td>glslc (from shaderc)</td>
                  <td>compiles the Vulkan shaders to SPIR-V</td>
                </tr>
              </.doc_table>
              <p>
                Your distribution's packages work if they're recent enough; for Elixir and Erlang, a
                version manager such as <a class="doc-link" href="https://asdf-vm.com">asdf</a>
                gets you exact versions. <code>elixir --version</code>
                should say Elixir 1.18 or newer, compiled with Erlang/OTP 26 or newer.
              </p>
              <h3>Tested Elixir and Erlang/OTP</h3>
              <.doc_table id="docs-versions-table" head={["Elixir", "Erlang/OTP", "Status"]}>
                <tr :for={{elixir, otp, status} <- @tested_versions}>
                  <td class="font-mono">{elixir}</td>
                  <td class="font-mono">{otp}</td>
                  <td>{status}</td>
                </tr>
              </.doc_table>
              <p>Anything older than Elixir 1.18 or Erlang/OTP 26 isn't supported.</p>
              <h3>GPU and fonts</h3>
              <p>
                guiltty needs a GPU driver with OpenGL 3.3, which almost any desktop from the last
                decade has. For Vulkan it needs a Vulkan 1.3 driver (for AMD and Intel GPUs, Mesa's;
                only AMD has been tried). Without one, it draws with OpenGL.
              </p>
              <p>
                Fonts come from fontconfig. guiltty looks best with a Nerd Font (for prompt icons),
                Noto Color Emoji (for emoji) and a font for Chinese, Japanese and Korean, such as
                Noto Sans CJK.
              </p>
            </.doc_section>

            <.doc_section id="install" title="Install">
              <h3>1. What to install first</h3>
              <p>
                On these distributions, one command installs it all. Only openSUSE has been tried;
                the other package names come from each distribution's package listings.
              </p>
              <.pp_card variant="outlined" class="mt-4 overflow-hidden" content_class="p-0!">
                <.pp_tabs id="docs-distro" layout="scrollable" aria-label="Distribution">
                  <.pp_tab
                    :for={{{slug, name, _, _}, i} <- Enum.with_index(@distros)}
                    id="docs-distro"
                    value={slug}
                    default_selected={i == 0}
                  >
                    {name}
                  </.pp_tab>
                </.pp_tabs>
                <.pp_tab_panel
                  :for={{{slug, _, cmd, note}, i} <- Enum.with_index(@distros)}
                  id="docs-distro"
                  value={slug}
                  default_selected={i == 0}
                  class="p-4 sm:p-6"
                >
                  <.code_block id={"docs-deps-#{slug}"} code={cmd} />
                  <p class="pp-body-small mt-3 text-pp-on-surface-variant">{note}</p>
                </.pp_tab_panel>
              </.pp_card>

              <h3>2. guiltty</h3>
              <.code_block id="docs-install-cmd" code={@install_command} />
              <p>
                <code>install.sh</code>
                checks for the tools above, builds a release and installs it into <code>~/.local</code>; it needs no root.
              </p>
              <.doc_table id="install-paths-table" head={["Where", "What"]}>
                <tr>
                  <td><code>~/.local/lib/guiltty/</code></td>
                  <td>the release</td>
                </tr>
                <tr>
                  <td><code>~/.local/bin/guiltty</code></td>
                  <td>the command</td>
                </tr>
                <tr>
                  <td><code>~/.local/share/applications/guiltty.desktop</code></td>
                  <td>the menu entry</td>
                </tr>
                <tr>
                  <td><code>~/.local/share/icons/hicolor/*/apps/guiltty.png</code></td>
                  <td>the icon</td>
                </tr>
              </.doc_table>

              <h3>3. Run it</h3>
              <p>
                Run <code>guiltty</code>, or find it in your applications menu. If your shell says <code>guiltty: command not found</code>, add
                <code>~/.local/bin</code>
                to your <code>PATH</code>.
              </p>
            </.doc_section>

            <.doc_section id="update" title="Update and uninstall">
              <dl class="doc-defs">
                <dt>Update</dt>
                <dd>
                  <.code_block id="docs-update-cmd" code="git pull && ./install.sh" />
                  <p>
                    If guiltty is running, the script asks before stopping it, since that closes its
                    tabs (<code>--yes</code> skips the question). Run from a guiltty tab, it finishes
                    after that tab closes, then opens guiltty again; its output goes to <code>~/.local/state/guiltty/install.log</code>.
                  </p>
                </dd>
                <dt>Uninstall</dt>
                <dd>
                  <.code_block id="docs-uninstall-cmd" code="./install.sh --uninstall" />
                  <p>Your config stays.</p>
                </dd>
                <dt>Install somewhere else</dt>
                <dd>
                  <.code_block id="docs-prefix-cmd" code="PREFIX=/opt/guiltty ./install.sh" />
                </dd>
              </dl>
            </.doc_section>

            <%!-- ───────────────────────── Using guiltty ───────────────────────── --%>
            <.doc_section id="windows-and-tabs" title="Windows and tabs">
              <p>
                Every window has its own tabs. <code>guiltty</code>
                (or <.keys keys="Ctrl+Shift+N" />) opens another window, and closing one never
                touches the others. guiltty stops after its last window.
              </p>
              <h3>Locked tabs</h3>
              <p>
                Closing a window ends its tabs, except the ones you lock with
                <.keys keys="Ctrl+Shift+L" />. They show a 🔒 and keep running, and the next
                <code>guiltty</code>
                brings that window back with them, where you left them.
              </p>
              <h3>Closing a busy tab</h3>
              <p>
                <.keys keys="Ctrl+Shift+W" />
                on a tab that's running a program (vim, ssh, a build) asks first: the tab bar says
                what's running, and pressing it again closes the tab. A tab waiting at its prompt
                closes at once.
              </p>
              <h3>Marks</h3>
              <p>
                A tab you're not looking at shows ● when it prints something and 🔔 when it rings
                the bell (a build that ends with <code>; printf '\a'</code>, say), until you switch
                to it.
              </p>
              <h3>Names and order</h3>
              <p>
                <.keys keys="Ctrl+Shift+R" />
                renames the tab: type a name, Enter. The name stays even when the program changes its
                title; an empty name gives the title back. <.keys keys="Ctrl+Shift+PgUp" /> and
                <.keys keys="Ctrl+Shift+PgDn" /> move the tab left and right.
              </p>
              <h3>Where a new tab starts</h3>
              <p>
                A new window's first tab starts in the folder you ran <code>guiltty</code>
                in. Other new tabs follow <code>working_directory</code>: by default, where the
                current tab's shell is. A tab's shell gets its window's display (<code>DISPLAY</code>
                and the like), so GUI programs started from it open where that window is.
              </p>
            </.doc_section>

            <.doc_section id="scrollback" title="Scrollback, search, selection">
              <p>
                Each tab keeps 10,000 rows of scrollback by default (<code>scrollback</code>).
                <.keys keys="Shift+PgUp" /> and <.keys keys="Shift+PgDn" />
                scroll back and forward, as does the mouse wheel; <.keys keys="Shift+Home" /> and
                <.keys keys="Shift+End" /> jump to the oldest row and back to the prompt.
                <.keys keys="Ctrl+Shift+K" /> clears the scrollback; the screen stays.
              </p>
              <h3>Search</h3>
              <p>
                <.keys keys="Ctrl+Shift+F" />
                searches the scrollback. Enter finds the next older match, Shift+Enter the next newer
                one, and Escape ends the search.
              </p>
              <h3>Selection and the clipboard</h3>
              <ul>
                <li>
                  Selecting with the mouse copies to the primary selection; a middle click pastes it.
                </li>
                <li>
                  <.keys keys="Ctrl+Shift+C" /> copies the selection to the clipboard, and
                  <.keys keys="Ctrl+Shift+V" /> or <.keys keys="Shift+Insert" /> paste it.
                </li>
                <li>
                  In programs that use the mouse (vim, htop), hold Shift to select.
                </li>
                <li>
                  <code>copy_on_select</code>
                  changes what selecting does: <code>:clipboard</code>
                  also copies to the clipboard, <code>false</code>
                  copies nothing until <.keys keys="Ctrl+Shift+C" />.
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="broadcast" title="Broadcast">
              <p>
                Broadcast types into every tab in a group at once: the same change on five servers,
                say. Open a tab per server, <code>ssh</code>
                in each, and press <.keys keys="Ctrl+Shift+B" /> in each to put it in the group.
                What you type in one goes to all of them. Each window has its own group.
              </p>
              <ul>
                <li>
                  A tab can join only while it's running one of <code>broadcast_programs</code>
                  (by default <code>ssh</code>
                  and <code>mosh-client</code>).
                </li>
                <li>
                  If a connection drops, typing goes nowhere until that tab leaves the group, and the
                  tab bar shows which tab was lost. A command meant for your servers doesn't land on
                  your own machine.
                </li>
                <li>
                  A local tab (your own shell) joins on purpose with a second
                  <.keys keys="Ctrl+Shift+B" />. It's marked 🏠 and isn't checked.
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="keys" title="Keys">
              <p>
                These are the defaults, as they ship. Every one can be rebound in the config's <code>keys</code>, and
                <.keys keys="Ctrl+Shift+/" /> shows them as you bound them.
              </p>
              <.doc_table id="keys-table" head={["Action", "Keys", "What it does"]}>
                <tr :for={{action, keys, what} <- @bindings}>
                  <td><code>{action}</code></td>
                  <td>
                    <span class="flex flex-col items-start gap-1">
                      <.keys :for={key <- keys} keys={key_label(key)} />
                    </span>
                  </td>
                  <td>{what}</td>
                </tr>
              </.doc_table>
              <h3>Fixed keys</h3>
              <p>
                Paste (<.keys keys="Ctrl+Shift+V" />, <.keys keys="Shift+Insert" />), middle-click
                paste and Shift-to-select aren't in <code>keys</code> and can't be rebound.
              </p>
              <h3>Rebinding</h3>
              <p>
                Each action takes a list of keys. Names are letters, digits, <code>f1</code>
                to <code>f12</code>, <code>tab</code>, <code>enter</code>, <code>page_up</code>, <code>page_down</code>, <code>home</code>, <code>end</code>, <code>insert</code>, <code>delete</code>, or a punctuation character like
                <code>=</code>
                or <code>-</code>, with any of the <code>ctrl+</code>, <code>shift+</code>
                and <code>alt+</code>
                modifiers. Actions you leave out keep their defaults.
              </p>
              <.code_block id="docs-keys-example" label="config.exs" code={@keys_example} />
            </.doc_section>

            <%!-- ───────────────────────── Configuration ───────────────────────── --%>
            <.doc_section id="config-file" title="The config file">
              <p>
                The config file is <code>~/.config/guiltty/config.exs</code>
                (or the path in <code>GUILTTY_CONFIG</code>). <.keys keys="Ctrl+," />
                creates it from the example config, which documents every setting, and opens it in
                your editor.
              </p>
              <p>
                It's plain Elixir: the last expression is the config, a keyword list. Settings you
                leave out keep their defaults.
              </p>
              <ul>
                <li>
                  guiltty checks the file every second and applies a saved change to the open
                  windows. A few settings apply only to what opens next; the settings table says
                  which.
                </li>
                <li>
                  If the file doesn't evaluate, or a setting is wrong, the previous config stays.
                  The tab bar shows the error in red, with the line
                  (<code>config.exs:4: theme: unknown name ...</code>), and a misspelled setting
                  gets a suggestion.
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="settings" title="Settings">
              <.doc_table id="settings-table" head={["Setting", "Default", "Accepts"]}>
                <%= for {name, default, accepts, notes} <- @settings do %>
                  <tr>
                    <td><code>{name}</code></td>
                    <td>
                      <%= case default do %>
                        <% {:text, text} -> %>
                          {text}
                        <% value -> %>
                          <code>{value}</code>
                      <% end %>
                    </td>
                    <td>
                      {accepts}
                      <span :if={notes} class="doc-cell-note">{notes}</span>
                    </td>
                  </tr>
                <% end %>
              </.doc_table>
            </.doc_section>

            <.doc_section id="themes" title="Themes">
              <p>Pick a built-in theme by name:</p>
              <ul class="doc-themes">
                <li :for={{slug, name} <- @themes} data-term-theme={slug}>
                  <span class="doc-theme-swatch" aria-hidden="true">
                    <span :for={i <- [1, 2, 3, 4, 5, 6]} style={"background: var(--t-#{i})"}></span>
                  </span>
                  <code>{slug}</code>
                  <span class="text-pp-on-surface-variant">{name}</span>
                  <span
                    :if={slug == "tomorrow-night"}
                    class="pp-label-small text-pp-on-surface-variant"
                  >
                    (the default)
                  </span>
                </li>
              </ul>
              <p>
                Or bring your own colors. Any you leave out come from <code>name:</code>
                (or from tomorrow-night without one), so you can start from a theme and change
                single colors.
              </p>
              <.code_block id="docs-theme-example" label="config.exs" code={@custom_theme} />
              <h3>Tab bar colors</h3>
              <.doc_table id="tab-colors-table" head={["Color", "What it colors"]}>
                <tr>
                  <td><code>tab_bar</code></td>
                  <td>the bar behind the tabs</td>
                </tr>
                <tr>
                  <td><code>tab_text</code></td>
                  <td>the other tabs' titles</td>
                </tr>
                <tr>
                  <td><code>tab_active</code></td>
                  <td>the active tab's background</td>
                </tr>
                <tr>
                  <td><code>tab_active_text</code></td>
                  <td>the active tab's title</td>
                </tr>
                <tr>
                  <td><code>tab_accent</code></td>
                  <td>
                    the line along the active tab (flat, minimal), or the filled tab's color (the
                    other styles)
                  </td>
                </tr>
              </.doc_table>
              <p>Any you leave out are worked out from the theme, to suit the tab style.</p>
            </.doc_section>

            <.doc_section id="tab-styles" title="Tab styles">
              <p>
                <code>tab_style</code>
                picks how the tab bar is drawn. The previews use Catppuccin Mocha; guiltty works
                out each style's colors from your theme, unless you set them.
              </p>
              <div class="mt-6 space-y-4" data-term-theme="catppuccin-mocha">
                <div :for={{style, what} <- @tab_styles} id={"tab-style-#{style}"}>
                  <div class={["tabstyle", "tabstyle-#{style}"]} aria-hidden="true">
                    <span class="tabstyle-tab">~</span>
                    <span class="tabstyle-tab is-active">~/src</span>
                    <span class="tabstyle-tab">ssh web-1</span>
                  </div>
                  <p class="mt-2!">
                    <code>:{style}</code> {what}
                  </p>
                </div>
              </div>
            </.doc_section>

            <.doc_section id="fonts" title="Fonts and ligatures">
              <p>
                <code>font</code>
                takes a fontconfig family name and a size from 6 to 96: <code>font: [family: "JetBrains Mono", size: 14]</code>. Characters the font doesn't
                have come from fallback fonts, so emoji, Nerd Font icons and CJK text show if those
                fonts are installed.
              </p>
              <p>
                With a font that has ligatures (JetBrains Mono and Fira Code do; Source Code Pro
                doesn't), <code>-&gt;</code>, <code>!=</code>, <code>|&gt;</code>, <code>=&gt;</code>
                and the like are drawn as one symbol. <code>ligatures: false</code>
                turns that off.
              </p>
              <p>
                Powerline arrows and half circles in prompts (U+E0B0, U+E0B2, U+E0B4, U+E0B6) are
                drawn by guiltty itself, like box drawing: they meet the blocks next to them exactly,
                and show even without a Nerd Font.
              </p>
            </.doc_section>

            <.doc_section id="renderer" title="Vulkan or OpenGL">
              <p>
                guiltty draws with Vulkan 1.3 by default. If Vulkan can't start (an old GPU, no
                driver), it switches to OpenGL by itself and says so in the tab bar. Both draw the
                same picture: a test replays recorded frames through each and compares them pixel
                for pixel.
              </p>
              <ul>
                <li>
                  <code>renderer: :gl</code>
                  always uses OpenGL, starting with the next window, so one window can be Vulkan and
                  the next OpenGL.
                </li>
                <li>
                  <code>GUILTTY_RENDERER=gl</code>
                  (or <code>vulkan</code>) does the same for a whole run, whatever the config says.
                  It's read when guiltty starts: <code>guiltty stop</code>, then <code>GUILTTY_RENDERER=gl guiltty</code>.
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="example-config" title="Example config">
              <p>
                The example config as it ships, with every setting at its default except the theme.
              </p>
              <.code_block id="docs-example-config" label="config.exs" code={@example_config} />
            </.doc_section>

            <%!-- ───────────────────────── Reference ───────────────────────── --%>
            <.doc_section id="command" title="The guiltty command">
              <p>
                <code>guiltty</code>
                is a small program that asks the running guiltty for a window over a private socket,
                like <code>emacsclient</code>. If guiltty isn't running, it starts it.
              </p>
              <.doc_table id="command-table" head={["Command", "What it does"]}>
                <tr>
                  <td><code>guiltty</code></td>
                  <td>
                    Opens a window, or brings back a closed one that kept locked tabs. Its first tab
                    starts in the folder you ran it in.
                  </td>
                </tr>
                <tr>
                  <td><code>guiltty stop</code></td>
                  <td>Stops guiltty: every window and every tab, locked ones too.</td>
                </tr>
                <tr>
                  <td><code>guiltty pid</code></td>
                  <td>Prints the running guiltty's process id.</td>
                </tr>
                <tr>
                  <td><code>guiltty remote</code></td>
                  <td>An IEx shell inside the running guiltty.</td>
                </tr>
              </.doc_table>
              <p>
                guiltty's Erlang node listens on 127.0.0.1 only, is named <code>guiltty@127.0.0.1</code>, and takes its cookie from <code>~/.erlang.cookie</code>.
                <code>install.sh</code>
                stops if that file can be read by other users.
              </p>
            </.doc_section>

            <.doc_section id="environment" title="Environment variables">
              <.doc_table id="environment-table" head={["Variable", "What it does"]}>
                <tr>
                  <td><code>GUILTTY_CONFIG</code></td>
                  <td>
                    The config file to use instead of <code>~/.config/guiltty/config.exs</code>.
                  </td>
                </tr>
                <tr>
                  <td><code>GUILTTY_RENDERER</code></td>
                  <td>
                    <code>gl</code>
                    or <code>vulkan</code>, for a whole run, whatever the config says. Read when
                    guiltty starts.
                  </td>
                </tr>
                <tr>
                  <td><code>PREFIX</code></td>
                  <td>
                    For <code>install.sh</code>: where to install instead of <code>~/.local</code>.
                  </td>
                </tr>
              </.doc_table>
            </.doc_section>

            <.doc_section id="troubleshooting" title="Troubleshooting">
              <dl class="doc-defs">
                <dt><code>guiltty: command not found</code></dt>
                <dd>
                  <p>Add <code>~/.local/bin</code> to your <code>PATH</code>.</p>
                </dd>
                <dt>The tab bar says guiltty is drawing with OpenGL</dt>
                <dd>
                  <p>
                    Vulkan couldn't start: there's no Vulkan 1.3 driver, or no GPU that can show the
                    window. guiltty works the same with OpenGL. To stop it trying Vulkan, set <code>renderer: :gl</code>.
                  </p>
                </dd>
                <dt>The tab bar shows an error in red</dt>
                <dd>
                  <p>
                    The config file has a mistake, at the line it names. The previous config stays
                    until you fix it and save.
                  </p>
                </dd>
                <dt>A setting didn't change anything</dt>
                <dd>
                  <p>
                    <code>window: opacity</code>
                    and <code>renderer</code>
                    apply to windows opened after the change, and <code>scrollback</code>
                    to new tabs. Opacity also needs a compositor.
                  </p>
                </dd>
                <dt>Emoji, icons or CJK text show as boxes</dt>
                <dd>
                  <p>
                    Install fonts that have them: a Nerd Font, Noto Color Emoji and Noto Sans CJK.
                  </p>
                </dd>
                <dt>I can't select text in vim or htop</dt>
                <dd>
                  <p>They use the mouse; hold Shift to select.</p>
                </dd>
                <dt>Updating from a guiltty tab</dt>
                <dd>
                  <p>
                    The tab closes when the old guiltty stops; the install carries on and opens
                    guiltty again. Its output is in <code>~/.local/state/guiltty/install.log</code>.
                  </p>
                </dd>
                <dt>Heavy output is slow</dt>
                <dd>
                  <p>
                    It is: about 3 to 4 MB/s for a big <code>cat</code>. Book chapter 22 measures it.
                  </p>
                </dd>
              </dl>
            </.doc_section>

            <.doc_section id="hacking" title="Building from source">
              <p>To work on guiltty itself, from a clone:</p>
              <.code_block
                id="docs-hack-cmd"
                code="mix deps.get\nmix guiltty        # a window from the source tree\nmix test\niex -S mix         # the same, with an iex shell alongside"
              />
              <p>
                <code>mix compile</code>
                also builds the C: the NIF and both renderers, each in a normal and a debug build.
                <code>make bench</code>
                measures throughput, and <code>AGENTS.md</code>
                lists every other command.
              </p>
            </.doc_section>

            <.doc_section id="learn-more" title="Learn more">
              <ul>
                <li>
                  <a class="doc-link" href={"#{@github}/tree/master/book"}>The book</a>
                  explains every part, with diagrams, from pseudoterminals to tab styles.
                </li>
                <li>
                  <a class="doc-link" href={Guiltty.github_path("CHANGELOG.md")}>CHANGELOG.md</a>
                  lists what each version added.
                </li>
                <li>
                  <a class="doc-link" href={Guiltty.github_path("DEVLOG.md")}>DEVLOG.md</a>
                  is what happened along the way.
                </li>
                <li>
                  guiltty is under the <a class="doc-link" href={Guiltty.github_path("LICENSE")}>MIT License</a>. The
                  installed copy also carries the Erlang runtime and the <code>telemetry</code>
                  library, both under the Apache License 2.0.
                </li>
              </ul>
            </.doc_section>
          </article>
        </div>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".DocsToc">
        export default {
          mounted() {
            const links = new Map(
              [...this.el.querySelectorAll("[data-section]")].map(a => [a.dataset.section, a])
            )
            const visible = new Set()
            this.observer = new IntersectionObserver(entries => {
              for (const e of entries) {
                e.isIntersecting ? visible.add(e.target.id) : visible.delete(e.target.id)
              }
              const current = [...links.keys()].find(id => visible.has(id))
              if (!current) return
              for (const [id, a] of links) {
                id === current ? a.setAttribute("aria-current", "true") : a.removeAttribute("aria-current")
              }
            }, {rootMargin: "-80px 0px -60% 0px"})
            for (const id of links.keys()) {
              const section = document.getElementById(id)
              if (section) this.observer.observe(section)
            }
          },
          destroyed() { this.observer?.disconnect() }
        }
      </script>
    </Layouts.app>
    """
  end

  attr :id, :string, required: true
  attr :title, :string, required: true
  slot :inner_block, required: true

  defp doc_section(assigns) do
    ~H"""
    <section id={@id} class="doc-section">
      <h2>
        <a href={"##{@id}"} class="doc-anchor">{@title}</a>
      </h2>
      {render_slot(@inner_block)}
    </section>
    """
  end

  attr :id, :string, required: true
  attr :head, :list, required: true
  slot :inner_block, required: true

  defp doc_table(assigns) do
    ~H"""
    <div class="doc-table-wrap">
      <table id={@id} class="doc-table">
        <thead>
          <tr>
            <th :for={h <- @head}>{h}</th>
          </tr>
        </thead>
        <tbody>{render_slot(@inner_block)}</tbody>
      </table>
    </div>
    """
  end

  slot :inner_block, required: true

  defp doc_note(assigns) do
    ~H"""
    <p class="doc-note">
      <span class="hero-information-circle size-5 shrink-0"></span>
      <span>{render_slot(@inner_block)}</span>
    </p>
    """
  end

  # "ctrl+shift+page_up" -> "Ctrl+Shift+PgUp", for the keys component.
  defp key_label(key) do
    key
    |> String.split(~r/\+(?!$)/)
    |> Enum.map_join("+", fn
      "ctrl" -> "Ctrl"
      "shift" -> "Shift"
      "alt" -> "Alt"
      "page_up" -> "PgUp"
      "page_down" -> "PgDn"
      "home" -> "Home"
      "end" -> "End"
      "tab" -> "Tab"
      "enter" -> "Enter"
      "insert" -> "Insert"
      "delete" -> "Delete"
      key -> String.upcase(key)
    end)
  end
end
