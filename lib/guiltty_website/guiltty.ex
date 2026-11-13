defmodule GuilttyWebsite.Guiltty do
  @moduledoc """
  Facts about guiltty that more than one page shows: where it lives, its
  themes, how to install it on each distribution and which Elixir and
  Erlang/OTP versions it's been tested on. They come from guiltty's
  README and `lib/guiltty/config.ex`; update them here when it releases.
  """

  @github "https://github.com/z7ealth/guiltty"

  @themes [
    {"guiltty", "guiltty"},
    {"tomorrow-night", "Tomorrow Night"},
    {"catppuccin-mocha", "Catppuccin Mocha"},
    {"catppuccin-latte", "Catppuccin Latte"},
    {"dracula", "Dracula"},
    {"gruvbox-dark", "Gruvbox Dark"},
    {"solarized-dark", "Solarized Dark"},
    {"nord", "Nord"},
    {"tokyo-night", "Tokyo Night"},
    {"one-dark", "One Dark"}
  ]

  # {slug, name, command, note}
  @distros [
    {"opensuse", "openSUSE Tumbleweed",
     "sudo zypper install gcc make pkg-config SDL3-devel freetype2-devel \\\n  fontconfig-devel harfbuzz-devel libpng16-devel vulkan-devel shaderc elixir erlang-epmd",
     "The one guiltty is developed on."},
    {"fedora", "Fedora 45+",
     "sudo dnf install gcc make pkgconf-pkg-config SDL3-devel freetype-devel \\\n  fontconfig-devel harfbuzz-devel libpng-devel vulkan-loader-devel vulkan-headers glslc elixir",
     "If Fedora's Elixir is older than 1.18 (elixir --version), leave out elixir and get Elixir and Erlang from asdf."},
    {"ubuntu", "Ubuntu 26.04+",
     "sudo apt install build-essential pkg-config libsdl3-dev libfreetype-dev \\\n  libfontconfig-dev libharfbuzz-dev libpng-dev libvulkan-dev glslc elixir erlang-dev",
     "Older Ubuntus have neither SDL3 nor GCC 15."},
    {"arch", "Arch Linux",
     "sudo pacman -Syu --needed base-devel sdl3 freetype2 fontconfig harfbuzz libpng \\\n  vulkan-icd-loader vulkan-headers shaderc elixir",
     "Everything is in the official repositories."}
  ]

  # {elixir, otp, what was done}
  @tested_versions [
    {"1.20.4", "29", "Developed on"},
    {"1.19.7", "28", "Builds, tests pass"},
    {"1.19.7", "26", "Builds, tests pass"},
    {"1.18.4", "26", "Builds, tests pass"}
  ]

  @doc "The repository."
  def github, do: @github

  @doc "A file or folder on master, as a GitHub link."
  def github_path(path), do: "#{@github}/blob/master/#{path}"

  @doc "The built-in themes: `{slug, name}`."
  def themes, do: @themes

  @doc "Install commands per distribution: `{slug, name, command, note}`."
  def distros, do: @distros

  @doc "Tested Elixir and Erlang/OTP versions: `{elixir, otp, status}`."
  def tested_versions, do: @tested_versions

  @raw "https://raw.githubusercontent.com/z7ealth/guiltty/master"

  @doc """
  The one-line install, with each downloader: `{slug, name, command}`.
  install.sh downloads the latest precompiled release (it uses wget itself
  when there's no curl) and asks before installing a missing library.
  """
  def one_line_installs,
    do: [
      {"curl", "curl", "curl -fsSL #{@raw}/install.sh | bash"},
      {"wget", "wget", "wget -qO- #{@raw}/install.sh | bash"}
    ]

  @doc "The curl one-line install."
  def one_line_install, do: "curl -fsSL #{@raw}/install.sh | bash"

  @doc "install.sh on GitHub, to read before piping it into a shell."
  def install_sh_url, do: github_path("install.sh")

  @doc "The releases page, with the precompiled tarballs."
  def releases_url, do: "#{@github}/releases"

  @doc "Building from source: the clone-and-install commands."
  def install_command, do: "git clone #{@github}.git\ncd guiltty\n./install.sh"
end
