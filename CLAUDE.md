# CLAUDE.md — jozefasobkowicz.com

Notes for future Claude sessions working on this repo. Kept short — link
to canonical sources rather than restate.

## What this is

Memorial site for **Jozefa Sobkowicz** (1935–2019). Static Jekyll site on
GitHub Pages, migrated from WordPress + NextGEN Gallery on GoDaddy shared
hosting. Four pages: Home, About, Photos, Messages. Tone: respectful and
understated — this is a memorial, not a product.

## Environment (NixOS)

- Enter dev shell: `nix develop` (or `direnv allow`).
- `bundle install` is first-time only; skip on subsequent shells (gems live
  in `./vendor/`, git-ignored).
- Local preview: `bundle exec jekyll serve --livereload` → http://localhost:4000
- One-shot build check: `bundle exec jekyll build`.
- ImageMagick is not in the flake by design; [scripts/rebuild-photos.sh](scripts/rebuild-photos.sh)
  pulls it in via `nix shell nixpkgs#imagemagick` on demand.

## Repo layout worth knowing

| Directory | Purpose |
|-----------|---------|
| [originals/](originals/) | Full-res photo archive. **Git-ignored** — local only. Only [originals/README.txt](originals/README.txt) is tracked. |
| [assets/img/photos/{full,thumbs}/](assets/img/photos/) | Committed derivatives that the site actually serves. |
| [assets/img/featured/](assets/img/featured/) | 4 hand-picked photos for the home-page slideshow. |
| [scripts/](scripts/) | Local tooling (not served). |
| [docs/](docs/) | Operational runbooks (not served). |

## Canonical docs — one topic, one home

Enforce this when adding anything new. Do NOT restate; link.

- Build / local use / photo pipeline → [README.md](README.md)
- Local photo-archive policy → [originals/README.txt](originals/README.txt)
- GitHub repo / Pages / Actions / Discussions / Giscus →
  [docs/github-runbook.md](docs/github-runbook.md)
- DNS / custom domain / registrar / email hosting →
  [docs/dns-runbook.md](docs/dns-runbook.md)
- One-time WordPress → Jekyll migration record →
  [docs/godaddy-migration.md](docs/godaddy-migration.md)

## Decisions already made — don't re-litigate

- **Originals are git-ignored.** Not "in git but excluded from build" — not
  in git at all. `originals/` is local; backup is elsewhere. See
  [originals/README.txt](originals/README.txt). If serving high-res becomes
  a want, the path is object storage (R2/S3) via `photos_base_url` — not
  putting them back in git.
- **Giscus phase 1: seed then lock.** The tribute Discussion is seeded from
  the owner account and then **immediately locked** — the widget on `/blog/`
  renders comments read-only, no new posts. Don't propose reopening for
  comments unless the user explicitly asks.
- **Featured photos are curated manually**, not auto-selected. Four files
  in [assets/img/featured/](assets/img/featured/); home page just lists
  them alphabetically.

## Workflow with the user

- Finish one task from the plan → report → **STOP**. The user reviews and
  commits before proceeding. Do not auto-chain to the next task.
- Multi-select answers phrased in first person ("I'll do X") mean the user
  is claiming the item, not delegating it to you.
- User is on NixOS and drives the sequence; local execution is your role.

## Pending cleanup at end of migration

- **`HANDOFF-PROMPT.md`** at repo root is stale — fully superseded by the
  three `docs/*.md` files. Slated for deletion once the site is fully live.
  When deleting, also remove the `- HANDOFF-PROMPT.md` line from
  `_config.yml`'s `exclude:` list (same commit).
- **`photos.zip`** at repo root is git-ignored and kept locally as the raw
  NextGEN dump / backup of record. Do not commit it; do not delete it
  unless the user says so.

## Remaining plan (as of last handoff)

1. Seed the Giscus tribute thread on GitHub, then lock it.
2. Publish the repo to GitHub Pages (public repo, Pages via Actions).
3. Configure GoDaddy DNS + custom domain + HTTPS, then cancel GoDaddy
   hosting.

Full procedures live in the runbooks above.
