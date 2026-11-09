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
       {"split-panes", "Split panes"},
       {"ai", "The AI key"},
       {"scrollback", "Scrollback, search, selection"},
       {"images", "Images"},
       {"programs", "What programs can do"},
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
     "Close the focused pane, or the tab with its last pane. If it's running a program, the tab bar says what, and pressing it again closes it."},
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
    {"prev_prompt", ["ctrl+shift+z"],
     "Jump to the prompt before the view, in shells that mark them (OSC 133)."},
    {"next_prompt", ["ctrl+shift+x"], "Jump to the prompt after the view."},
    {"copy", ["ctrl+shift+c"], "Copy the selection to the clipboard."},
    {"select_all", ["ctrl+shift+a"],
     "Select everything, the scrollback and the screen, as in an editor. Ctrl+Shift+C copies it."},
    {"zoom_in", ["ctrl+=", "ctrl+shift+=", "ctrl+plus"], "Bigger text."},
    {"zoom_out", ["ctrl+-"], "Smaller text."},
    {"zoom_reset", ["ctrl+0"], "The configured size again."},
    {"open_config", ["ctrl+,"],
     "Open the config file, creating it from the example first: in a new tab running $VISUAL or $EDITOR if one is set, otherwise in your desktop's app."},
    {"cheatsheet", ["ctrl+shift+h", "ctrl+shift+/"], "Every key, as you bound it, on one page."},
    {"lock_tab", ["ctrl+shift+l"], "Lock the tab, so it outlives its window."},
    {"broadcast", ["ctrl+shift+b"],
     "Put the tab, every pane of it, in the broadcast group, or take it out."},
    {"ai", ["ctrl+shift+space"],
     "Open the AI tool set in ai:, with the selection at its prompt, and go back. Without a command, it only says so."},
    {"split_right", ["ctrl+shift+o"], "A new pane right of the focused one, with half its room."},
    {"split_down", ["ctrl+shift+e"], "A new pane below the focused one, with half its room."},
    {"focus_left", ["ctrl+shift+left"], "Focus the pane to the left (a click works too)."},
    {"focus_right", ["ctrl+shift+right"], "Focus the pane to the right."},
    {"focus_up", ["ctrl+shift+up"], "Focus the pane above."},
    {"focus_down", ["ctrl+shift+down"], "Focus the pane below."},
    {"resize_left", ["alt+shift+left"], "Move the separator nearest the focused pane left."},
    {"resize_right", ["alt+shift+right"], "Move it right."},
    {"resize_up", ["alt+shift+up"], "Move it up."},
    {"resize_down", ["alt+shift+down"], "Move it down."}
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
    {"pane_border", "[style: :solid, thickness: :thin]",
     "style: :solid, :dashed, :double or :none; thickness: :thin or :thick",
     "The line between split panes. Its colors are in the theme."},
    {"tab_style", ":flat", ":flat, :powerline, :rounded, :minimal or :separators",
     "How the tabs look. Their colors are in the theme."},
    {"ligatures", "true", "true or false",
     "Join ->, !=, |> and the like into one symbol, when the font has ligatures."},
    {"ai", "[command: nil, position: :right]",
     ~s(command: a program, like "your-ai-tool"; position: :right, :down or :tab),
     "What the AI key (Ctrl+Shift+Space) opens, and where. No command by default: guiltty doesn't pick one for you."},
    {"clipboard_write", "true", "true or false",
     "Programs can put text on the clipboard (OSC 52), from the focused pane. They can never read it."},
    {"link_url", "true", "true or false",
     "Ctrl+click opens URLs in plain text (http, https, mailto, file), and holding Ctrl underlines them. Links a program marks (OSC 8) open either way."},
    {"screen_reports", "false", "true or false",
     "Answer DECRQCRA and the title reports, for terminal test suites. Leave it off: they let a program read your screen, even over ssh. For tabs opened after a change."},
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
    tab_accent: "#ff79c6",
    # The border between split panes, and along the focused one. Left
    # out: the palette's bright black and blue.
    pane_border: "#44475a",
    pane_border_active: "#bd93f9"
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

  # Makes ssh give up on a dead connection within about 45 seconds (book
  # chapter 18, "A frozen connection isn't a lost one").
  @ssh_alive ~S"""
  Host *
    ServerAliveInterval 15
    ServerAliveCountMax 3
  """

  @hack_commands ~S"""
  mix deps.get
  mix guiltty        # a window from the source tree
  mix test
  iex -S mix         # the same, with an iex shell alongside
  """

  @pane_border_example ~S"""
  pane_border: [style: :dashed, thickness: :thick]
  """

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

    # The border between split panes (Ctrl+Shift+O / E): one cell wide, a
    # line of style :solid, :dashed, :double or :none (blank), :thin or
    # :thick. Its colors are in theme: (pane_border, pane_border_active).
    pane_border: [style: :solid, thickness: :thin],

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
    # tab, enter, page_up, page_down, home, end, insert, delete, up, down,
    # left, right, space, plus (the + key), or a punctuation character like = or -,
    # with any of the ctrl+, shift+ and alt+ modifiers.
    #
    # A punctuation key is named by what it types *without* Shift on your
    # layout. "ctrl+shift+/" is the / ? key on a US keyboard; on a Latin
    # American one / is Shift+7, so no key matches it there, and the ' ?
    # key is "ctrl+shift+'". Letters are the same on every layout.
    keys: [
      new_window: ["ctrl+shift+n"],
      new_tab: ["ctrl+shift+t"],
      # Closes the focused pane (the tab, when it's the last one). Asks first
      # when it's running a program (vim, ssh, a build).
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
      # Selects everything: the scrollback and the screen, as in an editor.
      select_all: ["ctrl+shift+a"],
      # Ctrl and the + key: "plus" names the key that types + without Shift
      # (Latin American, Spanish, German layouts).
      zoom_in: ["ctrl+=", "ctrl+shift+=", "ctrl+plus"],
      zoom_out: ["ctrl+-"],
      zoom_reset: ["ctrl+0"],
      open_config: ["ctrl+,"],
      cheatsheet: ["ctrl+shift+h", "ctrl+shift+/"],
      lock_tab: ["ctrl+shift+l"],
      # Puts the tab in the broadcast group, or takes it out: all its panes.
      broadcast: ["ctrl+shift+b"],
      # Opens the AI tool set below, and goes back.
      ai: ["ctrl+shift+space"],
      # Split panes: a new pane right of the focused one, or below it, with
      # half its room.
      split_right: ["ctrl+shift+o"],
      split_down: ["ctrl+shift+e"],
      # The focus to the pane in that direction (a click works too).
      focus_left: ["ctrl+shift+left"],
      focus_right: ["ctrl+shift+right"],
      focus_up: ["ctrl+shift+up"],
      focus_down: ["ctrl+shift+down"],
      # Jumps to the prompt before or after the view (a shell must mark them:
      # OSC 133).
      prev_prompt: ["ctrl+shift+z"],
      next_prompt: ["ctrl+shift+x"],
      # Moves the separator nearest the focused pane, that way.
      resize_left: ["alt+shift+left"],
      resize_right: ["alt+shift+right"],
      resize_up: ["alt+shift+up"],
      resize_down: ["alt+shift+down"]
    ],

    # The AI tool the `ai` key opens, beside you (:right, :down) or in a tab of its
    # own (:tab). It's a program in a pane: what's selected goes to its prompt, and
    # nothing else on your screen does. Without a command, the key only says so.
    # ai: [command: "", position: :right],

    # Programs can put text on the clipboard (OSC 52), from the focused pane.
    # They can never read it.
    # clipboard_write: true,

    # Ctrl+click opens URLs in plain text (http, https, mailto, file), like the
    # one a server prints when it starts. Hold Ctrl to see them underlined.
    # Links a program marks (OSC 8) open either way.
    # link_url: true,

    # Answer DECRQCRA and the title reports, for terminal test suites. Leave it
    # off: these let a program read your screen, even from the far end of ssh.
    # screen_reports: false
  ]
  """

  @ai_example ~S"""
  ai: [command: "your-ai-tool", position: :right]    # or :down, or :tab
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
     |> assign(:one_line_install, Guiltty.one_line_install())
     |> assign(
       :one_line_dry_run,
       String.replace_suffix(Guiltty.one_line_install(), "| sh", "| sh -s -- --dry-run")
     )
     |> assign(:get_sh_url, Guiltty.get_sh_url())
     |> assign(:custom_theme, String.trim(@custom_theme))
     |> assign(:tab_styles, @tab_styles)
     |> assign(:keys_example, String.trim(@keys_example))
     |> assign(:pane_border_example, String.trim(@pane_border_example))
     |> assign(:ai_example, String.trim(@ai_example))
     |> assign(:ssh_alive, String.trim(@ssh_alive))
     |> assign(:hack_commands, String.trim(@hack_commands))
     |> assign(:example_config, String.trim(@example_config))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="docs" class="mx-auto max-w-6xl px-6 py-12 sm:py-16">
        <header class="max-w-2xl">
          <.pp_breadcrumbs>
            <:item href="/">Home</:item>
            <:item>Docs</:item>
          </.pp_breadcrumbs>
          <.pp_typography variant="display-small" emphasized tag="h1" class="mt-4">
            Install, use and configure guiltty.
          </.pp_typography>
          <.pp_typography variant="body-large" color="on-surface-variant" class="mt-4 text-pretty">
            Everything here is also in guiltty's
            <a class="doc-link" href={Guiltty.github_path("README.md")}>README</a>
            and <a class="doc-link" href={@example_url}>example config</a>. How each part works is in <a
              class="doc-link"
              href={"#{@github}/tree/master/book"}
            >the book</a>.
          </.pp_typography>
        </header>

        <div class="mt-12 grid gap-12 lg:grid-cols-[14rem_1fr]">
          <nav id="docs-toc" class="docs-toc" aria-label="Documentation" phx-hook=".DocsToc">
            <button
              type="button"
              id="docs-toc-toggle"
              class="docs-toc-toggle"
              aria-expanded="false"
              aria-controls="docs-toc"
              phx-click={
                JS.toggle_class("is-open", to: "#docs-toc")
                |> JS.toggle_attribute({"aria-expanded", "true", "false"})
              }
            >
              <.pp_icon name="hero-list-bullet" size="none" class="size-5" /> On this page
              <.pp_icon name="hero-chevron-down-micro" size="none" class="size-4 docs-toc-chevron" />
            </button>
            <div :for={{group, sections} <- @toc} class="docs-toc-group">
              <p class="pp-label-medium uppercase tracking-widest text-pp-on-surface-variant">
                {group}
              </p>
              <ul class="mt-2 space-y-0.5">
                <li :for={{id, title} <- sections}>
                  <a
                    href={"##{id}"}
                    class="docs-toc-link"
                    data-section={id}
                    phx-click={
                      JS.remove_class("is-open", to: "#docs-toc")
                      |> JS.set_attribute({"aria-expanded", "false"}, to: "#docs-toc-toggle")
                    }
                  >
                    {title}
                  </a>
                </li>
              </ul>
            </div>
          </nav>

          <article class="doc pp-body-large min-w-0">
            <%!-- ───────────────────────── Getting started ───────────────────────── --%>
            <.doc_section id="overview" title="Overview" divider={false}>
              <p>
                guiltty is a GPU-accelerated terminal emulator in Elixir and C. Elixir holds the
                behavior: the parser, the screen, tabs, windows, config. C does the syscalls, the hot
                path and the pixels: two NIFs (the PTY, and printed text into screen cells), a
                renderer (Vulkan, or OpenGL) that runs as its own process, and the small
                <code>guiltty</code>
                command.
              </p>
              <p>
                It runs on Linux only. It's been tried on openSUSE Tumbleweed, on X11 and on Wayland
                (GNOME), with an AMD GPU; Intel, NVIDIA and other distributions should work but
                haven't been tried.
              </p>
            </.doc_section>

            <.doc_section id="requirements" title="Requirements">
              <p>
                guiltty is built from source on your machine, so installing it needs Elixir and a C
                toolchain. The installed copy carries its own Erlang runtime: once it's installed, it
                runs without Elixir.
              </p>
              <.doc_table id="requirements-table" head={["What", "Why"]}>
                <.pp_table_row>
                  <.pp_table_cell>Elixir 1.18+, Erlang/OTP 26+</.pp_table_cell>
                  <.pp_table_cell>building guiltty and its release</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>GCC 15+, make, pkg-config</.pp_table_cell>
                  <.pp_table_cell>the C is C23 and uses <code>#embed</code></.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>SDL3 (development files)</.pp_table_cell>
                  <.pp_table_cell>the window, keyboard and mouse</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>FreeType, fontconfig, HarfBuzz (dev files)</.pp_table_cell>
                  <.pp_table_cell>finding fonts, drawing and shaping text</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>Vulkan loader and headers (dev files)</.pp_table_cell>
                  <.pp_table_cell>the Vulkan renderer</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>glslc (from shaderc)</.pp_table_cell>
                  <.pp_table_cell>compiles the Vulkan shaders to SPIR-V</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>libpng (development files)</.pp_table_cell>
                  <.pp_table_cell>pictures programs show (Kitty graphics)</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>
                Your distribution's packages work if they're recent enough; for Elixir and Erlang, a
                version manager such as <a class="doc-link" href="https://asdf-vm.com">asdf</a>
                gets you exact versions. <code>elixir --version</code>
                should say Elixir 1.18 or newer, compiled with Erlang/OTP 26 or newer.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                Tested Elixir and Erlang/OTP
              </.pp_typography>
              <.doc_table id="docs-versions-table" head={["Elixir", "Erlang/OTP", "Status"]}>
                <.pp_table_row :for={{elixir, otp, status} <- @tested_versions}>
                  <.pp_table_cell class="font-mono">{elixir}</.pp_table_cell>
                  <.pp_table_cell class="font-mono">{otp}</.pp_table_cell>
                  <.pp_table_cell>{status}</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>Anything older than Elixir 1.18 or Erlang/OTP 26 isn't supported.</p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                GPU and fonts
              </.pp_typography>
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
              <.pp_typography variant="title-large" tag="h3" class="mt-8">One line</.pp_typography>
              <p>
                On openSUSE, Fedora, Ubuntu/Debian, Arch and the distributions based on them:
              </p>
              <.code_block id="docs-one-line-cmd" code={@one_line_install} />
              <p>
                <a class="doc-link" href={@get_sh_url}>get.sh</a>
                finds out your distribution, shows the packages that are missing and the
                <code>sudo</code>
                command that installs them, and asks before running it. Then it downloads the latest
                release's source into <code>~/.local/src</code>, builds it and installs it into <code>~/.local</code>; it needs no root for that. Run it again to update. It only
                warns about Elixir: if yours is older than 1.18 (on OTP 26), it stops and says how to
                get a newer one with asdf. It's a short script: read it first, if you like.
              </p>
              <.doc_table id="get-sh-options-table" head={["Option", "What it does"]}>
                <.pp_table_row>
                  <.pp_table_cell><code>--dry-run</code></.pp_table_cell>
                  <.pp_table_cell>Says what it would do, and does nothing.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>--yes</code></.pp_table_cell>
                  <.pp_table_cell>
                    Installs the missing packages and stops a running guiltty without asking.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_VERSION=v0.18.1</code></.pp_table_cell>
                  <.pp_table_cell>A release other than the latest.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>PREFIX=/somewhere</code></.pp_table_cell>
                  <.pp_table_cell>Where to install, instead of <code>~/.local</code>.</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>
                Piped into <code>sh</code>, options go after <code>sh -s --</code>:
              </p>
              <.code_block id="docs-one-line-dry-run" code={@one_line_dry_run} />

              <.pp_typography variant="title-large" tag="h3" class="mt-10">
                Or by hand
              </.pp_typography>
              <p>The same thing, step by step.</p>
              <.pp_typography variant="title-medium" tag="h4" class="mt-6">
                1. What to install first
              </.pp_typography>
              <p>
                On these distributions, one command installs it all (it's what get.sh runs).
                openSUSE Tumbleweed has been tried all the way to a running guiltty; on the others,
                get.sh found these package names in fresh containers of each, but the build itself
                hasn't been tried.
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

              <.pp_typography variant="title-medium" tag="h4" class="mt-6">2. guiltty</.pp_typography>
              <.code_block id="docs-install-cmd" code={@install_command} />
              <p>
                <code>install.sh</code>
                checks for the tools above, builds a release and installs it into <code>~/.local</code>; it needs no root.
              </p>
              <.doc_table id="install-paths-table" head={["Where", "What"]}>
                <.pp_table_row>
                  <.pp_table_cell><code>~/.local/lib/guiltty/</code></.pp_table_cell>
                  <.pp_table_cell>the release</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>~/.local/bin/guiltty</code></.pp_table_cell>
                  <.pp_table_cell>the command</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>
                    <code>~/.local/share/applications/guiltty.desktop</code>
                  </.pp_table_cell>
                  <.pp_table_cell>the menu entry</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>
                    <code>~/.local/share/icons/hicolor/*/apps/guiltty.png</code>
                  </.pp_table_cell>
                  <.pp_table_cell>the icon</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>

              <.pp_typography variant="title-medium" tag="h4" class="mt-6">3. Run it</.pp_typography>
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
                  <p>Run the one line again, or, from a clone:</p>
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
              <.pp_typography variant="title-large" tag="h3" class="mt-8">Locked tabs</.pp_typography>
              <p>
                Closing a window ends its tabs, except the ones you lock with
                <.keys keys="Ctrl+Shift+L" />. They show a 🔒 and keep running, and the next
                <code>guiltty</code>
                brings that window back with them, where you left them.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                Closing a busy tab
              </.pp_typography>
              <p>
                <.keys keys="Ctrl+Shift+W" />
                closes the focused pane, and the tab with its last pane. On one that's running a
                program (vim, ssh, a build) it asks first: the tab bar says what's running, and
                pressing it again closes it. One waiting at its prompt closes at once.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">Marks</.pp_typography>
              <p>
                A tab you're not looking at shows ● when it prints something and 🔔 when it rings
                the bell (a build that ends with <code>; printf '\a'</code>, say), until you switch
                to it.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                Names and order
              </.pp_typography>
              <p>
                <.keys keys="Ctrl+Shift+R" />
                renames the tab: type a name, Enter. The name stays even when the program changes its
                title; an empty name gives the title back. <.keys keys="Ctrl+Shift+PgUp" /> and
                <.keys keys="Ctrl+Shift+PgDn" /> move the tab left and right.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                Where a new tab starts
              </.pp_typography>
              <p>
                A new window's first tab starts in the folder you ran <code>guiltty</code>
                in. Other new tabs follow <code>working_directory</code>: by default, where the
                current tab's shell is. A tab's shell gets its window's display (<code>DISPLAY</code>
                and the like), so GUI programs started from it open where that window is.
              </p>
            </.doc_section>

            <.doc_section id="split-panes" title="Split panes">
              <p>
                A tab can hold several shells, side by side or stacked. Each pane is a whole
                terminal, with its own scrollback, search, selection and images.
              </p>
              <.doc_table id="panes-table" head={["Keys", "What they do"]}>
                <.pp_table_row>
                  <.pp_table_cell>
                    <.keys keys="Ctrl+Shift+O" /> <.keys keys="Ctrl+Shift+E" />
                  </.pp_table_cell>
                  <.pp_table_cell>
                    Split the focused pane right, or down: the new pane takes half its room.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><.keys keys="Ctrl+Shift+Arrows" /></.pp_table_cell>
                  <.pp_table_cell>Focus the pane that way. A click works too.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><.keys keys="Alt+Shift+Arrows" /></.pp_table_cell>
                  <.pp_table_cell>
                    Move the separator nearest the focused pane, that way.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><.keys keys="Ctrl+Shift+W" /></.pp_table_cell>
                  <.pp_table_cell>
                    Close the focused pane. The tab closes with its last one; in a tab of one pane,
                    nothing changes.
                  </.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>
                Every key is rebindable (<code>split_right</code>, <code>split_down</code>, <code>focus_left</code>…, <code>resize_left</code>…), and the cheatsheet has a
                Panes card.
              </p>
              <p>
                The border between panes is a <code>:solid</code>
                line by default; <code>pane_border</code>
                makes it <code>:dashed</code>, <code>:double</code>
                or <code>:none</code>, <code>:thin</code>
                or <code>:thick</code>. Its colors, and the color along the focused pane, are in the
                theme.
              </p>
              <.code_block id="docs-pane-border" label="config.exs" code={@pane_border_example} />
            </.doc_section>

            <.doc_section id="ai" title="The AI key">
              <p>
                A pane runs any program, so an AI tool is just one more. Set the command in <code>ai</code>, and
                <.keys keys="Ctrl+Shift+Space" />
                opens it beside you, in the folder you were in. Press it again and you go back to
                where you were; again, and you return to it. <code>position</code>
                puts it to the <code>:right</code>
                (the default), <code>:down</code>, or in a <code>:tab</code>
                of its own.
              </p>
              <.code_block id="docs-ai-example" label="config.exs" code={@ai_example} />
              <ul>
                <li>
                  guiltty only starts the program and talks to no one: no API keys, no accounts, and
                  any tool that runs in a terminal works. No command is set by default, so the key
                  only says so until you pick one.
                </li>
                <li>
                  Only what you select goes to it. With text selected, the key pastes it at the
                  tool's prompt, without Enter: nothing is sent until you press it. Nothing else on
                  your screen leaves, and guiltty never runs what the answers suggest.
                </li>
                <li>
                  A tool that's still starting gets the text once it turns on bracketed paste, or
                  after 5 seconds with its line breaks turned into spaces, so they can't act as Enter.
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="scrollback" title="Scrollback, search, selection">
              <p>
                Each tab keeps 10,000 rows of scrollback by default (<code>scrollback</code>).
                <.keys keys="Shift+PgUp" /> and <.keys keys="Shift+PgDn" />
                scroll back and forward, as does the mouse wheel; <.keys keys="Shift+Home" /> and
                <.keys keys="Shift+End" /> jump to the oldest row and back to the prompt.
                <.keys keys="Ctrl+Shift+K" /> clears the scrollback; the screen stays.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">Search</.pp_typography>
              <p>
                <.keys keys="Ctrl+Shift+F" />
                searches the scrollback. Enter finds the next older match, Shift+Enter the next newer
                one, and Escape ends the search.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">Prompts</.pp_typography>
              <p>
                In a shell set up to mark its prompts (OSC 133), <.keys keys="Ctrl+Shift+Z" /> and
                <.keys keys="Ctrl+Shift+X" />
                jump to the previous and next prompt, so you can step through long output one
                command at a time.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                Selection and the clipboard
              </.pp_typography>
              <ul>
                <li>
                  Selecting with the mouse copies to the primary selection; a middle click pastes it.
                </li>
                <li>
                  <.keys keys="Ctrl+Shift+A" />
                  selects everything, as Select All does in an editor: the scrollback and the
                  screen, down to the last row with text (in vim or htop, that screen alone). Like a
                  mouse selection it goes to the primary selection.
                </li>
                <li>
                  <.keys keys="Ctrl+Shift+C" /> copies the selection to the clipboard, and
                  <.keys keys="Ctrl+Shift+V" /> or <.keys keys="Shift+Insert" /> paste it.
                </li>
                <li>
                  With text selected, a right click copies it to the clipboard and pastes it at the
                  prompt of the pane under the pointer: a quick way to take a path from one shell's
                  output to another's prompt.
                </li>
                <li>
                  In programs that use the mouse (vim, htop), hold Shift to select and to right click.
                </li>
                <li>
                  <code>copy_on_select</code>
                  changes what selecting does: <code>:clipboard</code>
                  also copies to the clipboard, <code>false</code>
                  copies nothing until <.keys keys="Ctrl+Shift+C" />.
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="images" title="Images">
              <p>
                guiltty supports the Kitty graphics protocol: programs that use it show pictures in
                the terminal. Images scroll with the text, and you can scroll back to them.
              </p>
              <ul>
                <li>Raw RGB, RGBA and PNG, zlib-compressed or not, sent in chunks.</li>
                <li>
                  Not supported: sixel, animation, Unicode placeholders, and images read from a file
                  path (<code>t=f</code>), which a remote program could use to read your files.
                </li>
                <li>
                  Programs can ask how big a cell is in pixels: guiltty sets the pixel size on the
                  terminal (<code>TIOCGWINSZ</code>) and answers <code>CSI 14 t</code>,
                  <code>CSI 16 t</code>
                  and <code>CSI 18 t</code>. It answers <code>CSI &gt; q</code>
                  (XTVERSION) with its name and version.
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="programs" title="What programs can do">
              <p>
                Programs see <code>TERM=xterm-256color</code>
                and expect what xterm does. guiltty passes 449 of esctest2's checks (the 79 left are
                explained in the book's chapter 10), and is tested in real sessions of tmux, htop and
                mc. It reports itself as a VT520.
              </p>
              <ul>
                <li>
                  <strong>Reflow.</strong>
                  Long lines rewrap when the window or a pane changes width, in the scrollback too,
                  and the cursor stays on the same character.
                </li>
                <li>
                  <strong>Keys.</strong>
                  Left Alt works as Meta (Alt+B is <code>ESC b</code>, so readline and Emacs move by
                  words); right Alt stays AltGr. Ctrl+Space, Ctrl+[, Ctrl+\, Ctrl+], Ctrl+^, Ctrl+_
                  and the Ctrl+digit row send what they do in xterm.
                </li>
                <li>
                  <strong>The Kitty keyboard protocol.</strong>
                  Neovim, Helix and the like can tell Ctrl+I from Tab and Shift+Enter from Enter, and
                  see key releases (flags 1, 2 and 8).
                </li>
                <li>
                  <strong>Hyperlinks (OSC 8).</strong>
                  <code>ls --hyperlink</code>
                  and the like. Ctrl+click opens http, https, mailto and file links, and the status
                  says where it went.
                </li>
                <li>
                  <strong>URLs in plain text.</strong>
                  Ctrl+click also opens a URL nobody marked, like the address
                  <code>mix phx.server</code>
                  prints; hold Ctrl and move the mouse over one to see it underlined. It finds URLs
                  that wrap onto the next row and leaves out the punctuation that ends a sentence.
                  <code>link_url: false</code>
                  turns it off.
                </li>
                <li>
                  <strong>The clipboard (OSC 52).</strong>
                  Copying in a program over ssh reaches your clipboard, from the focused pane.
                  <code>clipboard_write: false</code>
                  turns it off.
                </li>
                <li>
                  <strong>The working directory (OSC 7).</strong>
                  A new tab starts where a program says it is, when that's on this machine.
                </li>
                <li>
                  <strong>Colors, focus, frames.</strong>
                  Programs can set and ask for colors (OSC 4, 10, 11, 12), per pane, so vim can tell
                  a dark background from a light one. Focus events (mode 1004) and synchronized output
                  (mode 2026), so nothing shows half-drawn.
                </li>
                <li>
                  <strong>Memory.</strong>
                  A tab that runs out of memory (2 GB) is restarted alone, instead of taking every
                  tab with it.
                </li>
              </ul>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                What a program can't do
              </.pp_typography>
              <p>
                A program's output may come from a server at the far end of ssh, or a file you <code>cat</code>, so guiltty answers with numbers and fixed strings, never words a
                program chose.
              </p>
              <.doc_table id="programs-cant-table" head={["A program can't", "Because"]}>
                <.pp_table_row>
                  <.pp_table_cell>read the clipboard</.pp_table_cell>
                  <.pp_table_cell>it would get whatever you copied last</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>read the title or the screen</.pp_table_cell>
                  <.pp_table_cell>
                    it chose the title, and could read any screen. <code>screen_reports: true</code>
                    turns these on, for test suites.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>resize, move or iconify the window</.pp_table_cell>
                  <.pp_table_cell>it isn't its window</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>set the clipboard from the background</.pp_table_cell>
                  <.pp_table_cell>only the pane with the keyboard can</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>open a link by itself</.pp_table_cell>
                  <.pp_table_cell>
                    you Ctrl+click it; http, https, mailto and file only
                  </.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
            </.doc_section>

            <.doc_section id="broadcast" title="Broadcast">
              <p>
                Broadcast types into every tab in a group at once: the same change on five servers,
                say. Open a tab per server, <code>ssh</code>
                in each, and press <.keys keys="Ctrl+Shift+B" /> in each to put it in the group.
                What you type in one goes to all of them. Each window has its own group.
              </p>
              <p>
                <.keys keys="Ctrl+Shift+B" />
                takes every pane of the tab at once, so you can also split one tab, ssh in each
                pane, and type into all of them.
              </p>
              <ul>
                <li>
                  A tab can join only while it's running one of <code>broadcast_programs</code>
                  (by default <code>ssh</code>
                  and <code>mosh-client</code>).
                </li>
                <li>
                  If a connection drops, typing goes nowhere until that tab leaves the group, and the
                  tab bar shows <code>⚠ broadcast paused</code>
                  with the tab that was lost. A command meant for your servers doesn't land on your
                  own machine.
                </li>
                <li>
                  A local tab (your own shell) joins on purpose with a second
                  <.keys keys="Ctrl+Shift+B" />. It's marked 🏠 and isn't checked.
                </li>
              </ul>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                Keys go out, not commands
              </.pp_typography>
              <p>
                Broadcast sends the keys you press, the same bytes to every tab, and each server's
                shell decides what they do. Anything a shell writes for you can come out different on
                every server: Tab completes against each server's own files, a suggestion accepted
                with → comes from each server's own history, and ↑ or Ctrl+R bring back each
                server's own last commands. In a broadcast group, type the whole command or paste
                it, and look at one other tab before pressing Enter if it matters. tmux's
                <code>synchronize-panes</code>
                and ClusterSSH work the same way.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                A frozen connection isn't a lost one
              </.pp_typography>
              <p>
                guiltty notices an <code>ssh</code>
                that exited. One that's still running but whose connection stopped (the laptop
                slept, the Wi-Fi or VPN changed) still looks fine: keys wait in its buffers and that
                tab shows nothing until ssh gives up, which can take minutes. To make ssh give up
                within about 45 seconds, so the group pauses, add to <code>~/.ssh/config</code>:
              </p>
              <.code_block
                id="docs-ssh-alive"
                label="~/.ssh/config"
                code={@ssh_alive}
              />
            </.doc_section>

            <.doc_section id="keys" title="Keys">
              <p>
                These are the defaults, as they ship. Every one can be rebound in the config's <code>keys</code>, and
                <.keys keys="Ctrl+Shift+H" /> shows them as you bound them.
              </p>
              <.pp_card variant="outlined" class="doc-compact mt-5 min-[600px]:hidden">
                <.pp_list id="keys-list" aria-label="Default keys">
                  <%!-- The description goes in the headline, which wraps in full;
                        a three-line item's :secondary stops at two lines --%>
                  <.pp_list_item :for={{action, keys, what} <- @bindings} three_line>
                    <code>{action}</code>
                    <.pp_typography
                      variant="body-medium"
                      color="on-surface-variant"
                      tag="span"
                      class="mt-1 block"
                    >
                      {what}
                    </.pp_typography>
                    <:trailing>
                      <span class="flex flex-col items-end gap-1">
                        <.keys :for={key <- keys} keys={key_label(key)} />
                      </span>
                    </:trailing>
                  </.pp_list_item>
                </.pp_list>
              </.pp_card>
              <.doc_table
                id="keys-table"
                head={["Action", "Keys", "What it does"]}
                class="max-[599px]:hidden"
              >
                <.pp_table_row :for={{action, keys, what} <- @bindings}>
                  <.pp_table_cell><code>{action}</code></.pp_table_cell>
                  <.pp_table_cell>
                    <span class="flex flex-col items-start gap-1">
                      <.keys :for={key <- keys} keys={key_label(key)} />
                    </span>
                  </.pp_table_cell>
                  <.pp_table_cell>{what}</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">Fixed keys</.pp_typography>
              <p>
                Paste (<.keys keys="Ctrl+Shift+V" />, <.keys keys="Shift+Insert" />), middle-click
                paste and Shift-to-select aren't in <code>keys</code> and can't be rebound.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">Rebinding</.pp_typography>
              <p>
                Each action takes a list of keys. Names are letters, digits, <code>f1</code>
                to <code>f12</code>, <code>tab</code>, <code>enter</code>, <code>page_up</code>, <code>page_down</code>, <code>home</code>, <code>end</code>, <code>insert</code>, <code>delete</code>, <code>up</code>, <code>down</code>, <code>left</code>, <code>right</code>,
                <code>plus</code>
                (the + key), or a punctuation character like <code>=</code>
                or <code>-</code>, with any of the <code>ctrl+</code>, <code>shift+</code>
                and <code>alt+</code>
                modifiers. Actions you leave out keep their defaults.
              </p>
              <p>
                A punctuation key is named by what it types without Shift on your layout, so the
                same name can be a different key, or none, on another one. On a US keyboard
                <code>ctrl+shift+/</code>
                is the / ? key; on a Latin American one / is Shift+7, so nothing matches it, and
                that key is <code>ctrl+shift+'</code>. Letters are the same on every layout, which
                is why the defaults lean on them (<.keys keys="Ctrl+Shift+H" />
                for the cheatsheet) and on <code>plus</code>
                (<code>ctrl+plus</code>
                zooms in where + has a key of its own).
              </p>
              <.code_block id="docs-keys-example" label="config.exs" code={@keys_example} />
            </.doc_section>

            <%!-- ───────────────────────── Configuration ───────────────────────── --%>
            <.doc_section id="config-file" title="The config file">
              <p>
                The config file is <code>~/.config/guiltty/config.exs</code>
                (or the path in <code>GUILTTY_CONFIG</code>). <.keys keys="Ctrl+," />
                creates it from the example config, which documents every setting, and opens it: in a
                new tab running <code>$VISUAL</code>
                (or <code>$EDITOR</code>) if one is set, and that tab closes when you quit the
                editor; otherwise in your desktop's app for the file.
              </p>
              <p>
                guiltty reads the variable from its own environment, so set it where your session
                starts (<code>~/.profile</code>, or <code>~/.config/environment.d/</code>), not only
                in your shell's rc file.
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
              <.pp_card variant="outlined" class="doc-compact mt-5 min-[600px]:hidden">
                <.pp_list id="settings-list" aria-label="Settings">
                  <.pp_list_item :for={{name, default, accepts, notes} <- @settings} three_line>
                    <code>{name}</code>
                    <.pp_typography
                      variant="body-medium"
                      color="on-surface-variant"
                      tag="span"
                      class="mt-1 block"
                    >
                      {accepts}<span :if={notes}>. {notes}</span>
                    </.pp_typography>
                    <:trailing>
                      <%= case default do %>
                        <% {:text, text} -> %>
                          {text}
                        <% value -> %>
                          <code>{value}</code>
                      <% end %>
                    </:trailing>
                  </.pp_list_item>
                </.pp_list>
              </.pp_card>
              <.doc_table
                id="settings-table"
                head={["Setting", "Default", "Accepts"]}
                class="max-[599px]:hidden"
              >
                <%= for {name, default, accepts, notes} <- @settings do %>
                  <.pp_table_row>
                    <.pp_table_cell><code>{name}</code></.pp_table_cell>
                    <.pp_table_cell>
                      <%= case default do %>
                        <% {:text, text} -> %>
                          {text}
                        <% value -> %>
                          <code>{value}</code>
                      <% end %>
                    </.pp_table_cell>
                    <.pp_table_cell>
                      {accepts}
                      <span :if={notes} class="doc-cell-note">{notes}</span>
                    </.pp_table_cell>
                  </.pp_table_row>
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
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                Tab bar and pane border colors
              </.pp_typography>
              <.doc_table id="tab-colors-table" head={["Color", "What it colors"]}>
                <.pp_table_row>
                  <.pp_table_cell><code>tab_bar</code></.pp_table_cell>
                  <.pp_table_cell>the bar behind the tabs</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>tab_text</code></.pp_table_cell>
                  <.pp_table_cell>the other tabs' titles</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>tab_active</code></.pp_table_cell>
                  <.pp_table_cell>the active tab's background</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>tab_active_text</code></.pp_table_cell>
                  <.pp_table_cell>the active tab's title</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>tab_accent</code></.pp_table_cell>
                  <.pp_table_cell>
                    the line along the active tab (flat, minimal), or the filled tab's color (the
                    other styles)
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>pane_border</code></.pp_table_cell>
                  <.pp_table_cell>the border between split panes</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>pane_border_active</code></.pp_table_cell>
                  <.pp_table_cell>the border along the focused pane</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>
                Any you leave out are worked out from the theme: the tab colors to suit the tab
                style, the pane borders from the palette's bright black and blue.
              </p>
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
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty</code></.pp_table_cell>
                  <.pp_table_cell>
                    Opens a window, or brings back a closed one that kept locked tabs. Its first tab
                    starts in the folder you ran it in.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty stop</code></.pp_table_cell>
                  <.pp_table_cell>
                    Stops guiltty: every window and every tab, locked ones too.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty pid</code></.pp_table_cell>
                  <.pp_table_cell>Prints the running guiltty's process id.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty remote</code></.pp_table_cell>
                  <.pp_table_cell>An IEx shell inside the running guiltty.</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>
                guiltty's Erlang node listens on 127.0.0.1 only, is named <code>guiltty@127.0.0.1</code>, and takes its cookie from <code>~/.erlang.cookie</code>.
                <code>install.sh</code>
                stops if that file can be read by other users.
              </p>
            </.doc_section>

            <.doc_section id="environment" title="Environment variables">
              <.doc_table id="environment-table" head={["Variable", "What it does"]}>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_CONFIG</code></.pp_table_cell>
                  <.pp_table_cell>
                    The config file to use instead of <code>~/.config/guiltty/config.exs</code>.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_RENDERER</code></.pp_table_cell>
                  <.pp_table_cell>
                    <code>gl</code>
                    or <code>vulkan</code>, for a whole run, whatever the config says. Read when
                    guiltty starts.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>VISUAL</code>, <code>EDITOR</code></.pp_table_cell>
                  <.pp_table_cell>
                    The editor <.keys keys="Ctrl+," />
                    opens the config in, in a new tab. Set it where your session starts.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>PREFIX</code></.pp_table_cell>
                  <.pp_table_cell>
                    For <code>get.sh</code>
                    and <code>install.sh</code>: where to install instead of <code>~/.local</code>.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_VERSION</code></.pp_table_cell>
                  <.pp_table_cell>
                    For <code>get.sh</code>: a release other than the latest, like <code>v0.18.1</code>.
                  </.pp_table_cell>
                </.pp_table_row>
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
                <dt>The one line stops about Elixir</dt>
                <dd>
                  <p>
                    The build needs Elixir 1.18 or newer on Erlang/OTP 26 or newer, and get.sh says how
                    to get one with asdf. Then run the line again.
                  </p>
                </dd>
                <dt>An image doesn't show</dt>
                <dd>
                  <p>
                    The program has to use the Kitty graphics protocol. Sixel and animated images
                    aren't supported, and images sent as a file path are refused.
                  </p>
                </dd>
                <dt><.keys keys="Ctrl+," /> opens the config in the wrong app</dt>
                <dd>
                  <p>
                    Set <code>VISUAL</code>
                    or <code>EDITOR</code>
                    where your session starts (<code>~/.profile</code>, or <code>~/.config/environment.d/</code>), then restart guiltty: <code>guiltty stop</code>, then <code>guiltty</code>.
                  </p>
                </dd>
                <dt>Broadcast types nothing</dt>
                <dd>
                  <p>
                    If the tab bar says <code>⚠ broadcast paused</code>, a tab in the group lost its
                    connection: take it out with <.keys keys="Ctrl+Shift+B" />. If one tab just shows
                    nothing, its ssh may be frozen; see <a class="doc-link" href="#broadcast">Broadcast</a>.
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
              </dl>
            </.doc_section>

            <.doc_section id="hacking" title="Building from source">
              <p>To work on guiltty itself, from a clone:</p>
              <.code_block
                id="docs-hack-cmd"
                code={@hack_commands}
              />
              <p>
                <code>mix compile</code>
                also builds the C: the two NIFs and both renderers, each in a normal and a debug build.
                <code>make bench</code>
                measures throughput, and <code>AGENTS.md</code>
                lists every other command.
              </p>
            </.doc_section>

            <.doc_section id="learn-more" title="Learn more">
              <ul>
                <li>
                  <a class="doc-link" href={"#{@github}/tree/master/book"}>The book</a>
                  explains every part, with diagrams, from pseudoterminals to images.
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

      <.pp_fab
        id="docs-top"
        icon="hero-arrow-up"
        label="Back to top"
        size="default"
        position="fixed"
        class="right-4 bottom-4 z-30 sm:right-6 sm:bottom-6"
        phx-click={JS.dispatch("guiltty:scroll-top")}
      />

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
  attr :divider, :boolean, default: true, doc: "a divider above the section"
  slot :inner_block, required: true

  defp doc_section(assigns) do
    ~H"""
    <.pp_divider :if={@divider} class="my-14" />
    <section id={@id} class="doc-section">
      <.pp_typography variant="headline-small" tag="h2">
        <a href={"##{@id}"} class="doc-anchor">{@title}</a>
      </.pp_typography>
      {render_slot(@inner_block)}
    </section>
    """
  end

  attr :id, :string, required: true
  attr :head, :list, required: true

  attr :class, :any, default: nil, doc: "for the container, e.g. hiding it on phones"

  slot :inner_block, required: true

  defp doc_table(assigns) do
    ~H"""
    <.pp_table_container class={["mt-5", @class]}>
      <.pp_table id={@id}>
        <.pp_table_head>
          <.pp_table_row>
            <.pp_table_cell :for={h <- @head} variant="head">{h}</.pp_table_cell>
          </.pp_table_row>
        </.pp_table_head>
        <.pp_table_body>{render_slot(@inner_block)}</.pp_table_body>
      </.pp_table>
    </.pp_table_container>
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
