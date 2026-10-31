# guiltty website

The landing page for [guiltty](https://github.com/z7ealth/guiltty), a GPU
terminal emulator written in Elixir. One Phoenix LiveView, built with
[PhoenixPaper](https://github.com/z7ealth/phoenix_paper) (Material 3), with
daisyUI loaded alongside to show the two don't interfere.

## Run it

```sh
mix setup
mix phx.server
```

Then open [localhost:4000](http://localhost:4000). `mix precommit` compiles
with warnings as errors, formats and runs the tests.

## Where things are

- `lib/guiltty_website_web/live/home_live.ex`: the page. Its content (the
  supervision tree, milestones, book chapters, keys, distros) is module
  attributes at the top; update them from guiltty's `CHANGELOG.md`,
  `README.md` and `book/` when it releases.
- `lib/guiltty_website_web/components/site_components.ex`: the terminal
  window, code blocks, the logo.
- `assets/css/site.css`: the site's own styles, including guiltty's theme
  palettes. `assets/css/phoenix_paper_theme.css` is generated:
  `mix phoenix_paper.gen.theme --seed "#7c3aed" --scheme vibrant`.
- `priv/static/fonts`: Roboto Flex and JetBrains Mono, both OFL.

## Deploy

The `Dockerfile` (from `mix phx.gen.release --docker`) builds a release
image; it needs no database.

```sh
docker build -t guiltty-website .
docker run -p 4000:4000 \
  -e SECRET_KEY_BASE="$(mix phx.gen.secret)" \
  -e PHX_HOST=your.domain \
  guiltty-website
```

`PHX_HOST` must be the domain people use, or LiveView refuses the
websocket. `PORT` changes the port (4000 by default). Put it behind a
proxy that terminates TLS: the app builds its URLs as `https://PHX_HOST`.
