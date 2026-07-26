# Jozefa Sobkowicz — memorial site (Jekyll)

A static rebuild of jozefasobkowicz.com, moving off WordPress/GoDaddy onto
Jekyll + GitHub Pages. Four sections: **Home**, **About**, **Photos**, **Tributes**.

---

## Quick start (NixOS)

```bash
nix develop                              # enters the dev shell (Ruby + build tools)
bundle install                           # first-time setup; also after any Gemfile change
bundle exec jekyll serve --livereload    # dev server at http://localhost:4000
# or, for a one-shot build without a server:
bundle exec jekyll build                 # writes _site/
```

`bundle install` writes gems into `./vendor/` (git-ignored). Once that exists you
can skip it on subsequent shells. If you use direnv, `direnv allow` auto-loads
the same shell via `.envrc`.

Regenerating photo derivatives after adding/removing images in `originals/`:

```bash
./scripts/rebuild-photos.sh              # rebuilds assets/img/photos/{full,thumbs}/
```

See [Adding photos](#adding-photos) below.

---

## Where things live

| You want to change…      | Edit…                                             |
|--------------------------|---------------------------------------------------|
| Her name, dates, email   | `_config.yml`                                     |
| The About text           | `about.md`                                        |
| The tribute messages     | `_data/messages.yml`                              |
| Home-page featured photos | drop 4 images in `assets/img/featured/`          |
| The photo gallery         | drop originals in `originals/`, run `./scripts/rebuild-photos.sh` (see [Adding photos](#adding-photos)) |
| Colours / fonts / layout | `assets/css/style.css`                            |

The gallery and featured grids build themselves from whatever image files are in
those folders — no list to maintain.

---

## Images: quality, sizes, storage, limits

Two separate things — don't conflate them:

- **Originals** (`originals/`) — full-resolution scans kept byte-for-byte,
  never re-encoded. Git-ignored and lives on your machine only; see
  [`originals/README.txt`](originals/README.txt) for the archive policy and
  backup options.
- **Derivatives** (`assets/img/photos/`) — the copies the site serves:
  `full/` (~2560px, for the lightbox) and `thumbs/` (~600px squares, for the
  grid). Sharp on any screen, fast to load. **These are committed** so the
  site builds without needing the local originals.

**GitHub limits (confirmed):** a published Pages site must be **≤ 1 GB**; source
repos have a **recommended 1 GB** soft limit; bandwidth is a soft **100 GB/month**;
individual files are capped at **100 MB**. Optimized derivatives for ~200 photos
sit far under these.

**Do not use Git LFS** for images here — GitHub Pages cannot serve LFS files (it
returns the pointer, not the image).

**Object storage (future).** GitHub has no general object-store/CDN product for
this. If the archive grows or you want lossless display without the 1 GB Pages
ceiling, move images to **AWS S3** or **Cloudflare R2** (R2 has no egress fees).
Then set `photos_base_url` in `_config.yml` and switch the gallery from folder-
scanning to a small `_data/photos.yml` manifest listing filenames + captions.
Nothing in the current setup blocks this move.

### Adding photos

The gallery on `/photos/` scans `assets/img/photos/full/` and `thumbs/` at build
time — but you don't drop images there directly. You drop originals into
`originals/` and generate the served copies from them, so the archive stays
byte-clean and the served copies stay optimized.

1. Copy the new photo(s) into `originals/` as `<name>.jpg` (lowercase `.jpg`
   extension; any base name is fine — no captions file to update).
2. Regenerate the derivatives:
   ```bash
   ./scripts/rebuild-photos.sh
   ```
   Idempotent — safe to re-run at any time. It reads every JPEG in `originals/`
   and writes `assets/img/photos/full/<name>.jpg` (2560px max, q88) plus
   `assets/img/photos/thumbs/thumbs_<name>.jpg` (600² center-crop, q80).
3. Preview locally with `bundle exec jekyll serve` and open `/photos/`.
4. Commit `originals/…` and `assets/img/photos/…` together.

To **remove** a photo, delete it from `originals/` **and** from both
`assets/img/photos/full/` and `assets/img/photos/thumbs/` (the script only
writes, it doesn't clean up stale derivatives).

The four **home-page featured** images are separate and manually curated: put
whatever four you want in `assets/img/featured/`. They're not run through the
script; the home page just picks up whatever is there.

---

## Operational docs

Everything platform-side lives in standalone docs so this README stays focused
on building and using the repo:

- **[docs/github-runbook.md](docs/github-runbook.md)** — repo, Pages, Actions
  build, Discussions, Giscus. Setup + ongoing maintenance + handoff.
- **[docs/dns-runbook.md](docs/dns-runbook.md)** — custom domain, GoDaddy DNS
  records, HTTPS, annual renewal, email-hosting decisions.
- **[docs/godaddy-migration.md](docs/godaddy-migration.md)** — one-time
  historical record of the WordPress → Jekyll migration.

Comments on `/tributes/` are backed by GitHub Discussions via Giscus — see the
GitHub runbook for setup.
