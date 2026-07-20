# Jozefa Sobkowicz — memorial site (Jekyll)

A static rebuild of jozefasobkowicz.com, moving off WordPress/GoDaddy onto
Jekyll + GitHub Pages. Four sections: **Home**, **About**, **Photos**, **Messages**.

---

## Quick start (NixOS)

```bash
nix develop            # enters the dev shell (Ruby + build tools)
bundle install         # first time only; installs Jekyll into ./vendor
bundle exec jekyll serve --livereload
# open http://localhost:4000
```

If you use direnv, `direnv allow` will auto-load the same shell via `.envrc`.

---

## Where things live

| You want to change…      | Edit…                                             |
|--------------------------|---------------------------------------------------|
| Her name, dates, email   | `_config.yml`                                     |
| The About text           | `about.md`                                        |
| The tribute messages     | `_data/messages.yml`                              |
| Home-page featured photos | drop 4 images in `assets/img/featured/`          |
| The photo gallery         | drop images in `assets/img/photos/full/` (+ `thumbs/`) |
| Colours / fonts / layout | `assets/css/style.css`                            |

The gallery and featured grids build themselves from whatever image files are in
those folders — no list to maintain.

---

## Getting your content off WordPress

### 1. Back everything up first
In GoDaddy, take a full backup (files + database) **before** cancelling hosting.
Also, in WordPress: **Tools → Export → All content** to download the WXR `.xml`
(this holds your pages/posts text as a safety copy). Do not cancel hosting until
the new site is live and verified.

### 2. The photos (the important part)
Your gallery is the NextGEN Gallery plugin. The images live on the server at:

- Full size: `/wp-content/gallery/photos/*.jpg`
- Thumbnails: `/wp-content/gallery/photos/thumbs/thumbs_*.jpg`

Get them via **SFTP / GoDaddy File Manager** (most reliable): download the whole
`wp-content/gallery/photos/` folder. Then:

- Put the full-size `*.jpg` into `assets/img/photos/full/`
- Put the `thumbs_*.jpg` into `assets/img/photos/thumbs/`
- Copy 4 favourites into `assets/img/featured/`

Consider compressing the full-size scans (e.g. to ~1600px, quality ~82) so the
repo stays lean and the site loads fast. See the handoff prompt for a one-liner.

### 3. The text
The About page and all tribute messages have already been transcribed into this
repo (`about.md`, `_data/messages.yml`). Proofread the Polish/Ukrainian entries
against the original once.

---

## Messages: static list vs. Giscus

Controlled by `messages_display` in `_config.yml`: `static` (default), `giscus`,
or `both`.

- **static** — the curated list in `_data/messages.yml`. Preserves each sender's
  name, relation and city. No accounts, no spam. Recommended for the existing
  messages.
- **giscus** — a live GitHub-Discussions thread. To set up:
  1. Make the repo **public**, then enable **Settings → Discussions**.
  2. Install the Giscus app: https://github.com/apps/giscus
  3. Go to https://giscus.app, enter the repo, pick a category, and copy the
     `repo`, `repo_id`, `category`, and `category_id` values into `_config.yml`.
  4. Set `messages_display: giscus` (or `both`).
  5. Seed your recreation comments, then **lock the discussion** in GitHub to
     disable new posting while keeping everything visible. The email invite at
     the top of the page points new contributors to you.

---

## Deploying to GitHub Pages

1. Push this repo to GitHub (branch `main`), repo **public**.
2. **Settings → Pages → Build and deployment → Source: GitHub Actions.**
3. The included workflow (`.github/workflows/jekyll.yml`) builds and deploys on
   every push. Watch progress under the **Actions** tab.

## Custom domain (do this last, after the site works)

1. **Settings → Pages → Custom domain:** enter `jozefasobkowicz.com`, Save.
   (The `CNAME` file in this repo already sets this too.)
2. In **GoDaddy DNS**, point the domain at GitHub Pages:
   - Four `A` records for the apex `@` →
     `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - One `CNAME` for `www` → `<your-github-username>.github.io`
3. Back in **Settings → Pages**, tick **Enforce HTTPS** once the certificate is
   issued (can take up to a few hours).
4. Only after the new site resolves correctly, cancel the GoDaddy **hosting**
   plan. Keep the **domain registration**.

> Note: GitHub Pages IP addresses can change over time — confirm the current apex
> `A` records in GitHub's Pages docs before editing DNS.
