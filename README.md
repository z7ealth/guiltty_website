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
  supervision tree, milestones, book chapters, keys, distros, tested
  Elixir/OTP versions) is module attributes at the top.
- `lib/guiltty_website_web/components/site_components.ex`: the terminal
  window, code blocks, the logo.
- `assets/css/site.css`: the site's own styles, including guiltty's theme
  palettes. `assets/css/phoenix_paper_theme.css` is generated:
  `mix phoenix_paper.gen.theme --seed "#7c3aed" --scheme vibrant`.
- `priv/static/fonts`: Roboto Flex and JetBrains Mono, both OFL.

## When guiltty releases

Everything on the page comes from guiltty's `CHANGELOG.md`, `README.md`,
`book/` and `lib/guiltty/config.ex`. In `home_live.ex`:

- the hero badge (version and headline) and, for a big feature, a chip;
- `@milestones`, and the "milestones implemented" count;
- `@chapters` for a new book chapter (titles are each file's `#+TITLE`),
  the chapter count, and the book section's last chapter;
- `@keys` from `@default_keys` in `lib/guiltty/config.ex`;
- `@distros` and `@tested_versions` from the README's install section;
- `@tree` and `@crashes` if book chapter 12's supervision tree changed;
- feature cards whose wording the CHANGELOG or README contradicts.

Keep the claims to what guiltty's own docs say: no "never", no numbers
without what they were measured against.

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

`PHX_HOST` is the site's domain. LiveView accepts its websocket from that
domain and its `www.` subdomain (`config/runtime.exs`); add other origins
with `CHECK_ORIGIN` (comma-separated `https://…` URLs). `PORT` changes the
port (4000 by default).

Put it behind a proxy that terminates TLS (Azure, Fly, Caddy, nginx…): the
app builds its URLs as `https://PHX_HOST`, redirects plain HTTP to HTTPS,
and trusts the proxy's `X-Forwarded-Proto` header to tell them apart.

`bin/guiltty_website remote` opens an IEx shell on the running node, from
inside the container (`docker exec -it <container> bin/guiltty_website remote`).
