defmodule GuilttyWebsiteWeb.DocsLive do
  @moduledoc """
  The documentation: installing, using and configuring guiltty, on one
  page with a sidebar. Everything here comes from guiltty's README,
  `priv/config.example.exs`, `lib/guiltty/config.ex` and its book; keep it
  to what those say.
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

  # The sidebar: {group, [{id, title}]}. Each id is a section on the page.
  @toc [
    {"Getting started",
     [
       {"overview", "Overview"},
       {"self-healing", "Self-healing"},
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

  # The windows-and-tabs showcase: {scene, chip label, chip icon}.
  @tab_scenes [
    {"marks", "Marks", "hero-bell"},
    {"locked", "Locked tabs", "hero-lock-closed"},
    {"password", "Password lock", "hero-key"},
    {"busy", "Busy tabs", "hero-exclamation-triangle"},
    {"rename", "Rename", "hero-pencil-square"}
  ]

  # Every action in `keys:`, with its defaults, from @default_keys in
  # lib/guiltty/config.ex: {action, [key], what it does}.
  @bindings [
    {"new_window", ["ctrl+shift+n"], "A new window, with its own tabs."},
    {"new_tab", ["ctrl+shift+t"], "A new tab."},
    {"close_tab", ["ctrl+shift+w"],
     "Close the pane (the tab with its last). Asks first if busy."},
    {"next_tab", ["ctrl+page_down", "ctrl+tab"], "The next tab."},
    {"prev_tab", ["ctrl+page_up", "ctrl+shift+tab"], "The previous tab."},
    {"move_tab_left", ["ctrl+shift+page_up"], "Move the tab left."},
    {"move_tab_right", ["ctrl+shift+page_down"], "Move the tab right."},
    {"rename_tab", ["ctrl+shift+r"], "Rename the tab. Empty restores the title."},
    {"scroll_page_up", ["shift+page_up"], "Scroll back a page."},
    {"scroll_page_down", ["shift+page_down"], "Scroll forward a page."},
    {"scroll_top", ["shift+home"], "Scroll to the oldest row."},
    {"scroll_bottom", ["shift+end"], "Scroll back to the prompt."},
    {"clear_scrollback", ["ctrl+shift+k"], "Drop the tab's scrollback; the screen stays."},
    {"search", ["ctrl+shift+f"], "Search the scrollback."},
    {"prev_prompt", ["ctrl+shift+z"], "Jump to the previous prompt (OSC 133)."},
    {"next_prompt", ["ctrl+shift+x"], "Jump to the prompt after the view."},
    {"copy", ["ctrl+shift+c"], "Copy the selection to the clipboard."},
    {"select_all", ["ctrl+shift+a"], "Select the scrollback and the screen."},
    {"zoom_in", ["ctrl+=", "ctrl+shift+=", "ctrl+plus"], "Bigger text."},
    {"zoom_out", ["ctrl+-"], "Smaller text."},
    {"zoom_reset", ["ctrl+0"], "The configured size again."},
    {"open_config", ["ctrl+,"], "Open the config file, creating it if needed."},
    {"cheatsheet", ["ctrl+shift+h", "ctrl+shift+/"], "Every key, as you bound it."},
    {"lock_tab", ["ctrl+shift+l"], "Lock the tab, so it outlives its window."},
    {"broadcast", ["ctrl+shift+b"], "Toggle the tab in the broadcast group."},
    {"ai", ["ctrl+shift+space", "super+shift+f23"],
     "Open the AI tool, and go back. super+shift+f23 is the laptop AI key."},
    {"split_right", ["ctrl+shift+o"], "Split right."},
    {"split_down", ["ctrl+shift+e"], "Split down."},
    {"focus_left", ["ctrl+shift+left"], "Focus the pane to the left."},
    {"focus_right", ["ctrl+shift+right"], "Focus the pane to the right."},
    {"focus_up", ["ctrl+shift+up"], "Focus the pane above."},
    {"focus_down", ["ctrl+shift+down"], "Focus the pane below."},
    {"resize_left", ["alt+shift+left"], "Move the separator left."},
    {"resize_right", ["alt+shift+right"], "Move it right."},
    {"resize_up", ["alt+shift+up"], "Move it up."},
    {"resize_down", ["alt+shift+down"], "Move it down."}
  ]

  # Every setting, from defaults/0 and the checks in lib/guiltty/config.ex:
  # {setting, default, accepts, notes}. A {:text, _} default is words, not
  # a value.
  @settings [
    {"font", ~s([family: "monospace", size: 12]), "family: any fontconfig name; size: 6 to 96",
     nil},
    {"theme", ~s("guiltty"), "a built-in name, or your own colors", "See Themes."},
    {"cursor", "[style: :block, blink: false, password_lock: true]",
     "style: :block, :bar or :underline", "password_lock: a lock while a password is read."},
    {"window: padding", "6", "0 to 100", "Pixels around the text."},
    {"window: columns, rows", "80, 24", "10 to 1000, 3 to 1000",
     "The size of a new window, in cells."},
    {"window: opacity", "1.0", "0.1 to 1.0", "Needs a compositor. New windows."},
    {"shell", {:text, "your login shell"}, ~s([command: "/usr/bin/zsh", args: ["-l"]]),
     "The program each new tab runs."},
    {"working_directory", ":inherit", ":inherit, :home or a path", nil},
    {"copy_on_select", "true", "true, :clipboard or false", nil},
    {"wheel_lines", "3", "1 to 50", "Rows the mouse wheel scrolls per step."},
    {"bold_is_bright", "true", "true or false", nil},
    {"broadcast_programs", ~s(["ssh", "mosh-client"]), "a list of program names", nil},
    {"tab_bar", ":bottom", ":bottom or :top", nil},
    {"pane_border", "[style: :solid, thickness: :thin, dim_inactive: true]",
     "style: :solid, :dashed, :double or :none; thickness: :thin or :thick; dim_inactive: true or false",
     "dim_inactive: the panes without the focus are dimmed."},
    {"tab_style", ":powerline", ":flat, :powerline, :rounded, :minimal or :separators",
     "See Tab styles."},
    {"ligatures", "true", "true or false", nil},
    {"ai", "[command: nil, position: :right, lock: true]",
     ~s(command: a program, like "your-ai-tool"; position: :right, :down or :tab; lock: true or false),
     "lock: its tab is locked while the tool runs."},
    {"clipboard_write", "true", "true or false", "OSC 52 from programs."},
    {"link_url", "true", "true or false", "Ctrl+click plain URLs."},
    {"screen_reports", "false", "true or false", "For test suites only."},
    {"visualizer", "true", "true or false",
     "Bars in the tab bar that move with your music. Needs PipeWire."},
    {"renderer", ":vulkan", ":vulkan or :gl", "New windows."},
    {"scrollback", "10_000", "0 to 1,000,000", "New tabs."},
    {"keys", {:text, "see Keys"}, "action: [key, ...]", nil}
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
    {"powerline", "Colored blocks joined by arrows. The default."},
    {"flat", "Side by side, the active one lighter, with a line along its edge."},
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

  # Installing without install.sh: what it does, step by step (the README's
  # "Entirely by hand").
  @by_hand_libraries [
    {"openSUSE",
     "sudo zypper install fontconfig libfreetype6 libharfbuzz0 libpng16-16 libvulkan1"},
    {"Fedora", "sudo dnf install fontconfig freetype harfbuzz libpng vulkan-loader"},
    {"Ubuntu, Debian",
     "sudo apt install libfontconfig1 libfreetype6 libharfbuzz0b libpng16-16 libvulkan1"},
    {"Arch, Manjaro",
     "sudo pacman -Syu --needed fontconfig freetype2 harfbuzz libpng vulkan-icd-loader"}
  ]

  @by_hand_install ~S"""
  v=0.28.0
  mkdir -p ~/.local/lib ~/.local/bin ~/.local/share/applications
  cp -a guiltty-$v-x86_64-linux/release ~/.local/lib/guiltty
  ln -sf ~/.local/lib/guiltty/lib/guiltty-$v/priv/guiltty ~/.local/bin/guiltty
  for s in 16 24 32 48 64 128 256; do
    install -D -m 644 ~/.local/lib/guiltty/lib/guiltty-$v/priv/icons/guiltty-$s.png \
      ~/.local/share/icons/hicolor/${s}x$s/apps/guiltty.png
  done
  cat > ~/.local/share/applications/guiltty.desktop <<EOF
  [Desktop Entry]
  Type=Application
  Name=guiltty
  GenericName=Terminal
  Comment=A GPU terminal emulator in Elixir and C
  Exec=$HOME/.local/bin/guiltty
  Icon=guiltty
  Terminal=false
  Categories=System;TerminalEmulator;
  StartupWMClass=guiltty
  StartupNotify=false
  EOF
  """

  @hack_commands ~S"""
  mix deps.get
  mix guiltty        # a window from the source tree
  mix test
  iex -S mix         # the same, with an iex shell alongside
  """

  # The commands that control a running guiltty, from @commands in
  # lib/guiltty/command.ex: {command, what it does}.
  @shell_commands [
    {"window --new", "Open a new window."},
    {"window --list", "List the windows, their tabs and panes, with ids."},
    {"tab --new", "Open a tab after the active one."},
    {"tab --close", "Close the tab, every pane in it."},
    {"tab --next, --prev", "Go to the next or previous tab."},
    {"tab --go N", "Go to tab N (1 is the first)."},
    {"tab --rename NAME", ~s(Name the tab; "" gives the program's title back.)},
    {"tab --lock, --unlock", "Keep the tab running when its window closes, or not."},
    {"pane --split-right", "Split the pane, the new one on the right."},
    {"pane --split-down", "Split the pane, the new one below."},
    {"pane --close", "Close the pane."},
    {"pane --focus DIRECTION", "Move the focus left, right, up or down."},
    {"theme --set NAME", "A built-in theme until the config file changes (drac is enough)."},
    {"theme --list", "List the built-in themes."}
  ]

  @script_example ~S"""
  id=$(guiltty pane --split-right)     # prints the new pane's id
  guiltty tab --rename build
  guiltty pane --pane "$id" --close
  guiltty theme --set drac             # dracula, in every window
  """

  @pane_border_example ~S"""
  pane_border: [style: :dashed, thickness: :thick, dim_inactive: false]
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
    font: [family: "monospace", size: 12],

    # A built-in theme by name: "guiltty" (the icon's lavender on
    # near-black, what guiltty uses without a config), "tomorrow-night",
    # "catppuccin-mocha", "dracula", "gruvbox-dark", "solarized-dark",
    # "nord", "tokyo-night", "one-dark" or "catppuccin-latte" (light).
    theme: "guiltty",

    # :block, :bar or :underline. Programs can change it while they run (vim
    # shows a bar in insert mode); it comes back when they're done.
    # password_lock: a lock in place of the cursor while a program (sudo,
    # ssh) reads a password with echo off.
    cursor: [style: :block, blink: false, password_lock: true],

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
    #   :flat        side by side, the active one lighter, with
    #                a line along its edge
    #   :powerline   (the default) colored blocks joined by arrows
    #   :rounded     pills with round ends, the active one filled
    #   :minimal     no bar: titles on the terminal's background, the line
    #                under the active one
    #   :separators  titles between thin bars, the active one filled
    # Their colors are in theme: (tab_bar, tab_active, ... above).
    tab_style: :powerline,

    # The border between split panes (Ctrl+Shift+O / E): one cell wide, a
    # line of style :solid, :dashed, :double or :none (blank), :thin or
    # :thick. Its colors are in theme: (pane_border, pane_border_active).
    # dim_inactive: the panes without the focus have their text dimmed, so you
    # see where you'd type; false keeps them as bright as the focused one.
    pane_border: [style: :solid, thickness: :thin, dim_inactive: true],

    # Join ->, !=, |>, => and the like into one symbol, when the font has
    # ligatures (JetBrains Mono and Fira Code do; Source Code Pro doesn't).
    ligatures: true,

    # How guiltty draws: :vulkan, or :gl (OpenGL). If Vulkan can't start
    # (no driver, no GPU that can show the window), guiltty says so and
    # draws with OpenGL. Applies to windows opened after a change.
    # GUILTTY_RENDERER=gl (or vulkan) in guiltty's environment wins over
    # this, to try the other one for a run: `guiltty release stop`, then
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
      # Opens the AI tool set below, and goes back. Many newer laptops have
      # an AI key, usually right of the space bar: it sends Super+Shift+F23, so it
      # works here too.
      ai: ["ctrl+shift+space", "super+shift+f23"],
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
    # With lock (the default), its tab is locked while the tool runs, so closing
    # the window doesn't end it; the lock goes when the tool exits.
    # ai: [command: "", position: :right, lock: true],

    # Programs can put text on the clipboard (OSC 52), from the focused pane.
    # They can never read it.
    # clipboard_write: true,

    # Ctrl+click opens URLs in plain text (http, https, mailto, file), like the
    # one a server prints when it starts. Hold Ctrl to see them underlined.
    # Links a program marks (OSC 8) open either way.
    # link_url: true,

    # Answer DECRQCRA and the title reports, for terminal test suites. Leave it
    # off: these let a program read your screen, even from the far end of ssh.
    # screen_reports: false,

    # Bars in the tab bar that dance to whatever your speakers play (Spotify,
    # a video...). Needs PipeWire. While it's on, guiltty records the sound
    # output (never the microphone) to measure it; false turns that off.
    # visualizer: true
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
     |> assign(:tab_scenes, @tab_scenes)
     |> assign(:install_command, Guiltty.install_command())
     |> assign(
       :one_line_options,
       String.replace_suffix(Guiltty.one_line_install(), "| bash", "| bash -s -- --yes")
     )
     |> assign(
       :one_line_uninstall,
       String.replace_suffix(Guiltty.one_line_install(), "| bash", "| bash -s -- --uninstall")
     )
     |> assign(
       :one_line_prefix,
       String.replace_suffix(Guiltty.one_line_install(), "| bash", "| PREFIX=/opt/guiltty bash")
     )
     |> assign(:install_sh_url, Guiltty.install_sh_url())
     |> assign(:releases_url, Guiltty.releases_url())
     |> assign(:manual_install, Guiltty.manual_install())
     |> assign(:by_hand_libraries, @by_hand_libraries)
     |> assign(:by_hand_install, String.trim(@by_hand_install))
     |> assign(:custom_theme, String.trim(@custom_theme))
     |> assign(:tab_styles, @tab_styles)
     |> assign(:keys_example, String.trim(@keys_example))
     |> assign(:pane_border_example, String.trim(@pane_border_example))
     |> assign(:ai_example, String.trim(@ai_example))
     |> assign(:shell_commands, @shell_commands)
     |> assign(:script_example, String.trim(@script_example))
     |> assign(:ssh_alive, String.trim(@ssh_alive))
     |> assign(:hack_commands, String.trim(@hack_commands))
     |> assign(:example_config, String.trim(@example_config))
     |> assign(:tree, @tree)
     |> assign(:status, Map.new(@tree, &{elem(&1, 0), :up}))
     |> assign(
       :pids,
       @tree |> Enum.with_index() |> Map.new(fn {t, i} -> {elem(t, 0), 212 + i * 7} end)
     )
     |> assign(:next_pid, 400)
     |> assign(:kills, 0)
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

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="docs" data-term-theme="guiltty" class="mx-auto max-w-6xl px-6 py-12 sm:py-16">
        <header class="max-w-2xl">
          <.pp_breadcrumbs>
            <:item href="/">Home</:item>
            <:item>Docs</:item>
          </.pp_breadcrumbs>
          <.pp_typography variant="display-small" emphasized tag="h1" class="mt-4">
            Documentation
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
                guiltty is a GPU-accelerated terminal for Linux. Elixir runs the parser, screen,
                tabs and config; C does the PTY, the hot path and the pixels, with a renderer
                (Vulkan or OpenGL) in its own OS process.
              </p>
              <p>
                Tried on openSUSE Tumbleweed (X11 and Wayland, AMD GPU). Other distributions and
                GPUs should work.
              </p>
            </.doc_section>

            <.doc_section id="self-healing" title="Self-healing">
              <p>
                Every tab and every window is its own supervision tree. Kill a process below and
                watch what its supervisor restarts: the tab stays, the screen heals.
              </p>
              <div class="doc-demo grid gap-4 xl:grid-cols-[1.4fr_1fr] [&>*]:min-w-0">
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
                      # click a <span class="t-red">⚡</span> process to kill it
                    </div>
                    <div :for={{dom_id, entry} <- @streams.log} id={dom_id} class="log-line">
                      <span class="t-dim">{entry.time}</span>
                      <span class={if(entry.kind == :exit, do: "t-red", else: "t-green")}>
                        {if entry.kind == :exit, do: "✗", else: "↻"}
                      </span>
                      {entry.text}
                    </div>
                  </div>
                  <div class="mt-3 t-dim">
                    killed: <span id="kill-count" class="t-magenta tabular-nums">{@kills}</span>
                  </div>
                </.terminal>
              </div>
              <p>
                In the real thing, <code>kill -9</code>
                the renderer and its window comes back with
                every tab. How it works is in <a
                  class="doc-link"
                  href={"#{@github}/blob/master/book/12-beam-advantage.org"}
                >
                  the book's chapter 12</a>.
              </p>
            </.doc_section>

            <.doc_section id="requirements" title="Requirements">
              <p>
                The precompiled release needs x86_64 Linux with glibc 2.36+ (Ubuntu 24.04+, Debian
                12+, current Fedora, Arch, openSUSE). It bundles Erlang and SDL3, plus the usual
                desktop libraries: fontconfig, FreeType, HarfBuzz, libpng. The installer offers to
                install any that are missing.
              </p>
              <p>
                A GPU driver with OpenGL 3.3 is enough; Vulkan 1.3 is used when available. For the
                best text, install a Nerd Font, Noto Color Emoji and Noto Sans CJK.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">
                To build from source
              </.pp_typography>
              <.doc_table id="requirements-table" head={["What", "Why"]}>
                <.pp_table_row>
                  <.pp_table_cell>Elixir 1.18+, Erlang/OTP 26+</.pp_table_cell>
                  <.pp_table_cell>guiltty and its release</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>GCC 15+, make, pkg-config</.pp_table_cell>
                  <.pp_table_cell>the C is C23 and uses <code>#embed</code></.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>
                    SDL3, FreeType, fontconfig, HarfBuzz, libpng (dev files)
                  </.pp_table_cell>
                  <.pp_table_cell>window, input, text, images</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>Vulkan loader and headers, glslc</.pp_table_cell>
                  <.pp_table_cell>the Vulkan renderer and its shaders</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell>PipeWire (dev files)</.pp_table_cell>
                  <.pp_table_cell>
                    the visualizer (only its headers: it's loaded when it runs)
                  </.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <.doc_table id="docs-versions-table" head={["Elixir", "Erlang/OTP", "Tested"]}>
                <.pp_table_row :for={{elixir, otp, status} <- @tested_versions}>
                  <.pp_table_cell class="font-mono">{elixir}</.pp_table_cell>
                  <.pp_table_cell class="font-mono">{otp}</.pp_table_cell>
                  <.pp_table_cell>{status}</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
            </.doc_section>

            <.doc_section id="install" title="Install">
              <.one_line_tabs id="docs-one-line" class="mt-5" />
              <p>
                <a class="doc-link" href={@install_sh_url}>install.sh</a>
                downloads the latest release (about 10 MB) into <code>~/.local</code>, no root.
                Then run <code>guiltty</code>
                or open it from your app menu. If the command isn't found, log in again.
              </p>
              <p>
                It also offers to create your config file, <code>~/.config/guiltty/config.exs</code>,
                from the example that lists every setting. If you already have one, it asks
                before replacing it.
              </p>
              <.doc_table id="install-options-table" head={["Option", "What it does"]}>
                <.pp_table_row>
                  <.pp_table_cell><code>--yes</code></.pp_table_cell>
                  <.pp_table_cell>
                    Don't ask: install libraries, stop a running guiltty, create a missing config (never replace yours).
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>--uninstall</code></.pp_table_cell>
                  <.pp_table_cell>Remove guiltty. Your config stays.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_VERSION=v0.26.2</code></.pp_table_cell>
                  <.pp_table_cell>A release other than the latest.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>PREFIX=/somewhere</code></.pp_table_cell>
                  <.pp_table_cell>Install somewhere other than <code>~/.local</code>.</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>Options go after <code>bash -s --</code>, variables before <code>bash</code>:</p>
              <.code_block id="docs-one-line-options" code={@one_line_options} />

              <.pp_typography variant="title-large" tag="h3" class="mt-10">
                From a downloaded release
              </.pp_typography>
              <p>
                Get the tarball from the <a class="doc-link" href={@releases_url}>releases page</a>:
              </p>
              <.code_block id="docs-manual-install" code={@manual_install} />

              <.pp_typography variant="title-large" tag="h3" class="mt-10">
                Entirely by hand
              </.pp_typography>
              <p>What <code>install.sh</code> does, step by step. First the libraries:</p>
              <.doc_table id="by-hand-libraries-table" head={["Distribution", "Command"]}>
                <.pp_table_row :for={{distro, cmd} <- @by_hand_libraries}>
                  <.pp_table_cell>{distro}</.pp_table_cell>
                  <.pp_table_cell><code>{cmd}</code></.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>
                Then, from the unpacked tarball (the command must be a link, not a copy):
              </p>
              <.code_block id="docs-by-hand-install" code={@by_hand_install} />

              <.pp_typography variant="title-large" tag="h3" class="mt-10">
                From source
              </.pp_typography>
              <p>
                Install the <a class="doc-link" href="#requirements">build requirements</a>, then
                run <code>install.sh</code> in a clone:
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
              <.code_block id="docs-install-cmd" code={@install_command} />
            </.doc_section>

            <.doc_section id="update" title="Update and uninstall">
              <dl class="doc-defs">
                <dt>Update</dt>
                <dd>
                  <p>
                    Run the one line again, or <code>git pull && ./install.sh</code>
                    in a clone. It asks before stopping a running guiltty.
                  </p>
                </dd>
                <dt>Uninstall</dt>
                <dd>
                  <.code_block id="docs-uninstall-cmd" code={@one_line_uninstall} />
                </dd>
                <dt>Install somewhere else</dt>
                <dd>
                  <.code_block id="docs-prefix-cmd" code={@one_line_prefix} />
                </dd>
              </dl>
            </.doc_section>

            <%!-- ───────────────────────── Using guiltty ───────────────────────── --%>
            <.doc_section id="windows-and-tabs" title="Windows and tabs">
              <p>
                Each window has its own tabs; closing one never touches the others.
                <code>guiltty</code>
                or <.keys keys="Ctrl+Shift+N" /> opens another.
              </p>
              <div id="tabs-demo" data-scene="marks" class="tabs-demo doc-demo">
                <div class="flex flex-wrap gap-2" role="group" aria-label="Tab feature">
                  <.pp_chip
                    :for={{scene, label, icon} <- @tab_scenes}
                    id={"tabs-scene-#{scene}"}
                    variant="filter"
                    group="tabs-scene"
                    selected={scene == "marks"}
                    on_toggle={JS.set_attribute({"data-scene", scene}, to: "#tabs-demo")}
                  >
                    <:icon><.icon name={icon} class="size-4.5" /></:icon>
                    {label}
                  </.pp_chip>
                </div>

                <div class="tabs-stage mt-4">
                  <div class="tabs-closed" aria-hidden="true">
                    <.pp_icon name="hero-lock-closed" size="none" class="size-5" />
                    <span>window closed · the 🔒 tab keeps running</span>
                    <code>$ guiltty</code>
                  </div>
                  <.terminal id="tabs-terminal" title="guiltty" class="tabs-term">
                    <div class="tabs-scene" data-for="marks">
                      <.p10k_prompt />
                      <div><span class="p10k-frame">╰─</span> git log --oneline -3</div>
                      <div><span class="t-yellow">a1f09c2</span> Lock the tab, not the window</div>
                      <div><span class="t-yellow">7d3e815</span> Marks for background tabs</div>
                      <div><span class="t-yellow">0c44b7e</span> Rename with Ctrl+Shift+R</div>
                      <div><span class="p10k-frame">╰─</span> <span class="t-cursor"></span></div>
                    </div>
                    <div class="tabs-scene" data-for="locked">
                      <div class="t-dim">Erlang/OTP 28 [erts-16.0] [64-bit] [smp:16:16]</div>
                      <div class="mt-1">Interactive Elixir (1.19.0) - press Ctrl+C to exit</div>
                      <div><span class="t-green">iex(1)&gt;</span> Node.self()</div>
                      <div class="t-magenta">:"dev@localhost"</div>
                      <div>
                        <span class="t-green">iex(2)&gt;</span> :timer.tc(fn -&gt; Work.run() end)
                      </div>
                      <div>
                        &#123;<span class="t-yellow">1_204_331</span>, <span class="t-cyan">:ok</span>&#125;
                      </div>
                      <div>
                        <span class="t-green">iex(3)&gt;</span> <span class="t-cursor"></span>
                      </div>
                    </div>
                    <div class="tabs-scene" data-for="password">
                      <.p10k_prompt />
                      <div><span class="p10k-frame">╰─</span> sudo pacman -Syu</div>
                      <div>
                        [sudo] password for you:
                        <span class="password-lock">
                          <.pp_icon name="hero-lock-closed-micro" size="none" class="size-3.5" />
                        </span>
                      </div>
                    </div>
                    <div class="tabs-scene" data-for="busy">
                      <div><span class="t-cyan">import</span> Config</div>
                      <div>&nbsp;</div>
                      <div><span class="t-cyan">config</span> :guiltty,</div>
                      <div>&nbsp;&nbsp;tab_style: <span class="t-magenta">:powerline</span>,</div>
                      <div>
                        &nbsp;&nbsp;theme:
                        <span class="t-green">"tokyo-night"</span><span class="t-cursor"></span>
                      </div>
                      <div class="t-blue">~</div>
                      <div class="t-blue">~</div>
                      <div class="vim-status"><b>-- INSERT --</b><span>config.exs [+]</span></div>
                    </div>
                    <div class="tabs-scene" data-for="rename">
                      <.p10k_prompt />
                      <div><span class="p10k-frame">╰─</span> ./deploy.sh production</div>
                      <div class="t-green">✓ build 3.2s</div>
                      <div class="t-green">✓ upload 1.1s</div>
                      <div>… migrating</div>
                    </div>

                    <:tab_bar>
                      <span class="tabs-scene tabs-bar" data-for="marks">
                        <span class="term-tab is-active">~/src</span>
                        <span class="term-tab"><span class="tab-mark t-cyan">●</span> mix test</span>
                        <span class="term-tab"><span class="tab-mark">🔔</span> ssh web-1</span>
                        <span class="term-tab"><span class="tab-mark t-green">✓</span> make</span>
                      </span>
                      <span class="tabs-scene tabs-bar" data-for="locked">
                        <span class="term-tab is-active">🔒 iex -S mix</span>
                        <span class="term-tab">~/src</span>
                      </span>
                      <span class="tabs-scene tabs-bar" data-for="password">
                        <span class="term-tab is-active">sudo pacman -Syu</span>
                        <span class="term-tab">~/src</span>
                      </span>
                      <span class="tabs-scene tabs-bar" data-for="busy">
                        <span class="term-tab is-active">vim config.exs</span>
                        <span class="term-tab">~/src</span>
                        <span class="tabs-status is-warning">vim is running: press again to close</span>
                      </span>
                      <span class="tabs-scene tabs-bar" data-for="rename">
                        <span class="term-tab">~/src</span>
                        <span class="term-tab is-active">
                          <span class="rename-typed">deploy</span><span class="rename-caret"></span>
                        </span>
                        <span class="tabs-status">rename tab: deploy</span>
                      </span>
                    </:tab_bar>
                  </.terminal>
                </div>

                <p class="tabs-caption">
                  <span class="tabs-scene" data-for="marks">
                    Background tabs: <b>●</b>
                    new output, <b>🔔</b>
                    the bell, <b>✓</b>/<b>✗</b>
                    a command that ended.
                  </span>
                  <span class="tabs-scene" data-for="locked">
                    <.keys keys="Ctrl+Shift+L" /> and the tab outlives its window.
                  </span>
                  <span class="tabs-scene" data-for="password">
                    A lock in place of the cursor while a program reads a password.
                  </span>
                  <span class="tabs-scene" data-for="busy">
                    <.keys keys="Ctrl+Shift+W" /> on a busy tab asks first: press again to close.
                  </span>
                  <span class="tabs-scene" data-for="rename">
                    <.keys keys="Ctrl+Shift+R" /> names the tab; empty brings the title back.
                  </span>
                </p>
              </div>
              <ul>
                <li>
                  <strong>Locked tabs.</strong> <.keys keys="Ctrl+Shift+L" /> keeps a tab running
                  after its window closes; the next <code>guiltty</code> brings it back.
                </li>
                <li>
                  <strong>Password lock.</strong>
                  A lock replaces the cursor while <code>sudo</code>
                  or <code>ssh</code>
                  reads a password.
                </li>
                <li>
                  <strong>Busy tabs.</strong> <.keys keys="Ctrl+Shift+W" /> asks first when a tab is
                  running something (vim, ssh, a build).
                </li>
                <li>
                  <strong>Marks.</strong> A background tab shows ● on output and 🔔 on the bell.
                </li>
                <li>
                  <strong>Names and order.</strong> <.keys keys="Ctrl+Shift+R" /> renames a tab;
                  <.keys keys="Ctrl+Shift+PgUp" /> and <.keys keys="Ctrl+Shift+PgDn" /> move it.
                </li>
                <li>
                  <strong>New tabs</strong> start where the current shell is
                  (<code>working_directory</code>).
                </li>
              </ul>
            </.doc_section>

            <.doc_section id="split-panes" title="Split panes">
              <p>
                Several shells in one tab. Each pane is a full terminal with its own scrollback,
                search and selection.
              </p>
              <.terminal
                id="panes-terminal"
                title="mix phx.server"
                tabs={[{"mix phx.server", true}]}
                class="doc-demo"
                body_class="panes-body"
              >
                <div class="pane pane-dim">
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
              <.doc_table id="panes-table" head={["Keys", "What they do"]}>
                <.pp_table_row>
                  <.pp_table_cell>
                    <.keys keys="Ctrl+Shift+O" /> <.keys keys="Ctrl+Shift+E" />
                  </.pp_table_cell>
                  <.pp_table_cell>Split right, or down</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><.keys keys="Ctrl+Shift+Arrows" /></.pp_table_cell>
                  <.pp_table_cell>Focus that way (or click)</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><.keys keys="Alt+Shift+Arrows" /></.pp_table_cell>
                  <.pp_table_cell>Move the separator</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><.keys keys="Ctrl+Shift+W" /></.pp_table_cell>
                  <.pp_table_cell>Close the pane</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <p>
                The panes without the focus are dimmed, their colors kept but fainter, so you see
                where you'd type. The border and the dimming are set with <code>pane_border</code>:
              </p>
              <.code_block id="docs-pane-border" label="config.exs" code={@pane_border_example} />
            </.doc_section>

            <.doc_section id="ai" title="The AI key">
              <p>
                <.keys keys="Ctrl+Shift+Space" /> (or a laptop's AI key) opens your AI tool in a pane
                beside you, with the selected text at its prompt. Press it again to go back.
              </p>
              <.terminal
                id="ai-terminal"
                title="your-ai-tool"
                tabs={[{"your-ai-tool", true}]}
                class="doc-demo"
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
              <.code_block id="docs-ai-example" label="config.exs" code={@ai_example} />
              <p>
                guiltty only starts the program: no API keys, no accounts, any terminal tool works.
                Only your selection is sent, and never with Enter.
              </p>
              <p>
                While the tool runs, its tab is locked (🔒): closing the window by accident doesn't
                end it. The lock goes when the tool exits; <code>lock: false</code> turns it off.
              </p>
            </.doc_section>

            <.doc_section id="scrollback" title="Scrollback, search, selection">
              <.terminal id="search-terminal" title="search" class="doc-demo">
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
              <ul>
                <li>
                  10,000 rows per tab (<code>scrollback</code>). <.keys keys="Shift+PgUp" />,
                  <.keys keys="Shift+PgDn" />, <.keys keys="Shift+Home" />, <.keys keys="Shift+End" />
                  scroll; <.keys keys="Ctrl+Shift+K" /> clears.
                </li>
                <li>
                  <.keys keys="Ctrl+Shift+F" /> searches: Enter for older, Shift+Enter for newer.
                </li>
                <li>
                  <.keys keys="Ctrl+Shift+Z" /> and <.keys keys="Ctrl+Shift+X" /> jump between
                  prompts (shells that mark them with OSC 133).
                </li>
                <li>
                  Selecting copies to the primary selection; middle click pastes.
                  <.keys keys="Ctrl+Shift+C" /> copies to the clipboard, <.keys keys="Ctrl+Shift+V" />
                  pastes.
                </li>
                <li>
                  A right click on a selection pastes it at the prompt under the pointer.
                </li>
                <li>In vim or htop, hold Shift to select.</li>
              </ul>
            </.doc_section>

            <.doc_section id="images" title="Images">
              <div class="doc-demo grid gap-6 sm:grid-cols-[auto_1fr] sm:items-center">
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
                <p class="mt-0!">
                  guiltty speaks the Kitty graphics protocol: PNG and raw RGB(A), scrolling with the
                  text. Not supported: sixel, animation, and file paths (<code>t=f</code>), which
                  would let a remote program read your files.
                </p>
              </div>
            </.doc_section>

            <.doc_section id="programs" title="What programs can do">
              <p>
                guiltty is <code>xterm-256color</code>, passes 449 esctest2 checks and is tested
                with tmux, htop and mc.
              </p>
              <ul>
                <li>Long lines rewrap on resize, scrollback included.</li>
                <li>Left Alt is Meta; right Alt stays AltGr.</li>
                <li>Kitty keyboard protocol: Ctrl+I differs from Tab, Shift+Enter from Enter.</li>
                <li>Ctrl+click opens links (OSC 8) and plain URLs (<code>link_url</code>).</li>
                <li>Programs can copy to your clipboard over ssh (OSC 52), never read it.</li>
                <li>Colors (OSC 4/10/11/12), focus events, synchronized output, OSC 7.</li>
                <li>A tab that runs out of memory (2 GB) restarts alone.</li>
              </ul>
              <p>
                Programs can't read the clipboard, the title or the screen, resize the window, or
                open links by themselves. <code>screen_reports: true</code>
                enables screen reads for test suites.
              </p>
              <p class="unicode-sample" aria-hidden="true">Ωμέγα 🧙‍♂️⚗️  ╭─╮ ▓▒░ |&gt; -&gt; !=</p>
            </.doc_section>

            <.doc_section id="broadcast" title="Broadcast">
              <p>
                <.keys keys="Ctrl+Shift+B" />
                adds a tab (all its panes) to the window's broadcast group: what you type goes to
                every tab in it. Useful for the same change on several servers.
              </p>
              <ul>
                <li>
                  Only tabs running <code>broadcast_programs</code>
                  (<code>ssh</code>, <code>mosh-client</code>) join. A local tab joins with a second
                  press, marked 🏠.
                </li>
                <li>
                  If a connection drops, typing stops (<code>⚠ broadcast paused</code>), so nothing
                  lands on your own machine.
                </li>
                <li>
                  Keys are sent, not commands: Tab completion and history differ per server. Type or
                  paste the whole command.
                </li>
              </ul>
              <p>
                To notice a frozen ssh within about 45 seconds, add to <code>~/.ssh/config</code>:
              </p>
              <.code_block id="docs-ssh-alive" label="~/.ssh/config" code={@ssh_alive} />
            </.doc_section>

            <.doc_section id="keys" title="Keys">
              <p>
                The defaults. Rebind any in <code>keys</code>; <.keys keys="Ctrl+Shift+H" />
                shows your current bindings.
              </p>
              <.pp_card variant="outlined" class="doc-compact mt-5 min-[600px]:hidden">
                <.pp_list id="keys-list" aria-label="Default keys">
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
              <p>
                Paste (<.keys keys="Ctrl+Shift+V" />, <.keys keys="Shift+Insert" />) is fixed.
              </p>
              <.pp_typography variant="title-large" tag="h3" class="mt-8">Rebinding</.pp_typography>
              <p>
                Combine <code>ctrl+</code>, <code>shift+</code>, <code>alt+</code>,
                <code>super+</code>
                with a letter, digit, <code>f1</code>–<code>f24</code>, a named
                key (<code>page_up</code>, <code>enter</code>…), <code>plus</code>
                or a punctuation character. Punctuation is named by what it types without Shift on
                your layout.
              </p>
              <.code_block id="docs-keys-example" label="config.exs" code={@keys_example} />
            </.doc_section>

            <%!-- ───────────────────────── Configuration ───────────────────────── --%>
            <.doc_section id="config-file" title="The config file">
              <p>
                <code>~/.config/guiltty/config.exs</code>
                (or <code>GUILTTY_CONFIG</code>), plain Elixir: the last expression is a keyword
                list. <.keys keys="Ctrl+," />
                creates and opens it in <code>$VISUAL</code>/<code>$EDITOR</code>.
              </p>
              <p>
                Saved changes apply live. If something's wrong, the tab bar shows the error and the
                previous config stays.
              </p>
              <p>
                Every setting, at its default and explained, is in
                <a class="doc-link" href={@example_url} id="config-example-link">
                  <code>priv/config.example.exs</code>
                </a>
                on GitHub.
              </p>
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
              <p>Pick a built-in theme to preview it:</p>
              <div id="theme-demo" data-term-theme="guiltty" class="doc-demo">
                <div class="flex flex-wrap gap-2" role="group" aria-label="Terminal theme">
                  <.pp_chip
                    :for={{slug, name} <- @themes}
                    id={"theme-#{slug}"}
                    variant="filter"
                    group="term-theme"
                    selected={slug == "guiltty"}
                    on_toggle={JS.set_attribute({"data-term-theme", slug}, to: "#theme-demo")}
                  >
                    {name}
                  </.pp_chip>
                </div>
                <.terminal
                  id="theme-terminal"
                  title="~/.config/guiltty/config.exs"
                  class="theme-term mt-4"
                >
                  <div class="space-y-3">
                    <div>
                      <span class="t-white">[</span><br />
                      &nbsp;&nbsp;<span class="t-cyan">font:</span>
                      <span class="t-white">[</span><span class="t-cyan">family:</span>
                      <span class="t-green">"JetBrainsMono Nerd Font"</span>,
                      <span class="t-cyan">size:</span>
                      <span class="t-yellow">14</span><span class="t-white">]</span>,<br />
                      &nbsp;&nbsp;<span class="t-cyan">theme:</span>
                      <span class="t-green">"<span :for={{slug, _} <- @themes} class={"theme-name theme-name-#{slug}"}>{slug}</span>"</span>,<br />
                      &nbsp;&nbsp;<span class="t-cyan">cursor:</span>
                      <span class="t-white">[</span><span class="t-cyan">style:</span>
                      <span class="t-magenta">:block</span><span class="t-white">]</span><br />
                      <span class="t-white">]</span>
                    </div>
                    <div class="palette" aria-label="The theme's 16 ANSI colors">
                      <span
                        :for={i <- 0..15}
                        class="palette-swatch"
                        style={"background: var(--t-#{i})"}
                      ></span>
                    </div>
                    <div class="truecolor" aria-hidden="true"></div>
                  </div>
                </.terminal>
              </div>
              <p>
                Or define your own. Colors you leave out come from <code>name:</code>, so you can
                tweak a built-in theme:
              </p>
              <.code_block id="docs-theme-example" label="config.exs" code={@custom_theme} />
            </.doc_section>

            <.doc_section id="tab-styles" title="Tab styles">
              <p><code>tab_style</code> sets how tabs look. Colors follow your theme.</p>
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
              <p>
                With many tabs, titles shrink to fit; past that the bar scrolls to keep the active
                tab in view, with a count of the hidden tabs at each end (<code>‹3</code>, <code>5›</code>). Click a count to go to the next hidden tab.
              </p>
              <p>
                At the right of the bar, 16 bars move with whatever your speakers play (Spotify,
                a video, anything), bass on the left. To measure it, guiltty records the sound
                output, never the microphone. It needs PipeWire; without it there are just no bars.
                <code>visualizer: false</code>
                turns it off.
              </p>
            </.doc_section>

            <.doc_section id="fonts" title="Fonts and ligatures">
              <p>
                <code>font: [family: "JetBrains Mono", size: 14]</code>
                takes any fontconfig name. Missing characters (emoji, icons, CJK) come from
                fallback fonts.
              </p>
              <p>
                Ligatures like <code>-&gt;</code>, <code>!=</code>, <code>|&gt;</code>
                are on when the font has them; <code>ligatures: false</code>
                turns them off.
                Powerline glyphs are drawn by guiltty, so they line up even without a Nerd Font.
              </p>
            </.doc_section>

            <.doc_section id="renderer" title="Vulkan or OpenGL">
              <div class="pixel-compare doc-demo" aria-hidden="true">
                <div class="pixel-pane"><span class="pp-label-medium">guiltty_vk</span></div>
                <span class="pp-title-medium text-pp-primary">=</span>
                <div class="pixel-pane"><span class="pp-label-medium">guiltty_gl</span></div>
              </div>
              <p>
                Vulkan 1.3 by default, OpenGL when Vulkan can't start. Both draw the same pixels,
                checked by a test that replays frames through each.
              </p>
              <p>
                Force one with <code>renderer: :gl</code>
                (new windows) or <code>GUILTTY_RENDERER=gl</code>
                (whole run: <code>guiltty release stop</code>
                first).
              </p>
            </.doc_section>

            <.doc_section id="example-config" title="Example config">
              <p>As it ships, every setting at its default.</p>
              <.code_block id="docs-example-config" label="config.exs" code={@example_config} />
            </.doc_section>

            <%!-- ───────────────────────── Reference ───────────────────────── --%>
            <.doc_section id="command" title="The guiltty command">
              <p>
                A small client that asks the running guiltty for a window (starting it if needed),
                like <code>emacsclient</code>.
              </p>
              <.doc_table id="command-table" head={["Command", "What it does"]}>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty</code></.pp_table_cell>
                  <.pp_table_cell>Open a window, or bring back one with locked tabs.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty help</code></.pp_table_cell>
                  <.pp_table_cell>List every command.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty version</code></.pp_table_cell>
                  <.pp_table_cell>Print the version.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty release stop</code></.pp_table_cell>
                  <.pp_table_cell>Stop guiltty, every tab included.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty release pid</code></.pp_table_cell>
                  <.pp_table_cell>Print its process id.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>guiltty release remote</code></.pp_table_cell>
                  <.pp_table_cell>An IEx shell inside it.</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>

              <.pp_typography variant="title-large" tag="h3" class="mt-10" id="command-control">
                From a shell or a script
              </.pp_typography>
              <p>
                <code>guiltty NOUN --ACTION</code>
                does what the keys do, on the pane it's typed in (every shell guiltty starts has <code>GUILTTY_PANE</code>).
                <code>--pane ID</code>
                picks another; from outside guiltty, it goes to the window last used.
              </p>
              <.doc_table id="shell-commands-table" head={["guiltty …", "What it does"]}>
                <.pp_table_row :for={{command, what} <- @shell_commands}>
                  <.pp_table_cell class="whitespace-nowrap"><code>{command}</code></.pp_table_cell>
                  <.pp_table_cell>{what}</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
              <.code_block id="docs-script-example" label="script.sh" code={@script_example} />
            </.doc_section>

            <.doc_section id="environment" title="Environment variables">
              <.doc_table id="environment-table" head={["Variable", "What it does"]}>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_CONFIG</code></.pp_table_cell>
                  <.pp_table_cell>Another config file.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_PANE</code></.pp_table_cell>
                  <.pp_table_cell>
                    Set by guiltty in each shell: its pane's id, for <code>guiltty pane …</code>.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_RENDERER</code></.pp_table_cell>
                  <.pp_table_cell>
                    <code>gl</code> or <code>vulkan</code> for a whole run.
                  </.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>VISUAL</code>, <code>EDITOR</code></.pp_table_cell>
                  <.pp_table_cell>The editor <.keys keys="Ctrl+," /> opens.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>PREFIX</code></.pp_table_cell>
                  <.pp_table_cell>Where <code>install.sh</code> installs.</.pp_table_cell>
                </.pp_table_row>
                <.pp_table_row>
                  <.pp_table_cell><code>GUILTTY_VERSION</code></.pp_table_cell>
                  <.pp_table_cell>Which release <code>install.sh</code> installs.</.pp_table_cell>
                </.pp_table_row>
              </.doc_table>
            </.doc_section>

            <.doc_section id="troubleshooting" title="Troubleshooting">
              <dl class="doc-defs">
                <dt><code>guiltty: command not found</code></dt>
                <dd>
                  <p>Log in again, or add <code>~/.local/bin</code> to your <code>PATH</code>.</p>
                </dd>
                <dt>It uses OpenGL, not Vulkan</dt>
                <dd>
                  <p>
                    No Vulkan 1.3 driver (common in VMs). That's fine; <code>renderer: :gl</code>
                    skips the attempt.
                  </p>
                </dd>
                <dt>The tab bar shows a red error</dt>
                <dd>
                  <p>The config has a mistake at that line; fix and save.</p>
                </dd>
                <dt>A setting changed nothing</dt>
                <dd>
                  <p>
                    <code>opacity</code>
                    and <code>renderer</code>
                    apply to new windows, <code>scrollback</code>
                    to new tabs.
                  </p>
                </dd>
                <dt>Emoji or CJK show as boxes</dt>
                <dd>
                  <p>Install a Nerd Font, Noto Color Emoji and Noto Sans CJK.</p>
                </dd>
                <dt>glibc is too old</dt>
                <dd>
                  <p>The release needs glibc 2.36+; build from source or upgrade.</p>
                </dd>
                <dt>A command is refused right after updating</dt>
                <dd>
                  <p>
                    The guiltty still running is the old one: close its windows once (or <code>guiltty release stop</code>).
                  </p>
                </dd>
                <dt>Broadcast types nothing</dt>
                <dd>
                  <p>
                    A tab lost its connection: take it out with <.keys keys="Ctrl+Shift+B" />.
                  </p>
                </dd>
              </dl>
            </.doc_section>

            <.doc_section id="hacking" title="Building from source">
              <.code_block id="docs-hack-cmd" code={@hack_commands} />
              <p>
                <code>make bench</code>
                measures throughput; <code>AGENTS.md</code>
                lists every other command.
              </p>
            </.doc_section>

            <.doc_section id="learn-more" title="Learn more">
              <ul>
                <li>
                  <a class="doc-link" href={"#{@github}/tree/master/book"}>The book</a>: how every
                  part works.
                </li>
                <li>
                  <a class="doc-link" href={Guiltty.github_path("CHANGELOG.md")}>Changelog</a>
                  and <a class="doc-link" href={Guiltty.github_path("DEVLOG.md")}>devlog</a>.
                </li>
                <li>
                  <a class="doc-link" href={Guiltty.github_path("LICENSE")}>MIT License</a>.
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
