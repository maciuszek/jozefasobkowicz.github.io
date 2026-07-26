# CLAUDE.md — jozefasobkowicz.com

Notes for future Claude sessions working on this repo. Kept short — link
to canonical sources rather than restate.

## What this is

Memorial site for **Jozefa Sobkowicz** (1935–2019). Static Jekyll site on
GitHub Pages, migrated from WordPress + NextGEN Gallery on GoDaddy shared
hosting. Four pages: Home, About, Photos, Tributes. Tone: respectful and
understated — this is a memorial, not a product.

## Environment (NixOS)

- Enter dev shell: `nix develop`. **The owner does not use direnv** — a
  cleanup task removes `.envrc`; don't propose direnv-related edits.
- `bundle install` is first-time only; skip on subsequent shells (gems live
  in `./vendor/`, git-ignored).
- Local preview: `bundle exec jekyll serve --livereload` → http://localhost:4000
- One-shot build check: `bundle exec jekyll build`.
- ImageMagick is not in the flake by design; [scripts/rebuild-photos.sh](scripts/rebuild-photos.sh)
  pulls it in via `nix shell nixpkgs#imagemagick` on demand.
- Ruby is already required for Jekyll; [scripts/print-paste-blocks.rb](scripts/print-paste-blocks.rb)
  uses only stdlib (`yaml`, `date`) — no new deps.

## Repo layout worth knowing

| Path | Purpose |
|------|---------|
| [_data/messages.yml](_data/messages.yml) | **Canonical tribute archive.** Enriched YAML (name, body, translation, defaulted-date and AI-translation markers, Translation Review Notes in the header). Under `messages_display: giscus` (current) NOT rendered on the site — the GitHub Discussion is. Source for `scripts/print-paste-blocks.rb`. |
| [originals/](originals/) | Full-res photo archive. **Git-ignored** — local only. Only [originals/README.txt](originals/README.txt) is tracked. |
| [assets/img/photos/{full,thumbs}/](assets/img/photos/) | Committed derivatives that the site actually serves. |
| [assets/img/featured/](assets/img/featured/) | 4 hand-picked photos for the home-page slideshow. |
| [assets/favicon.svg](assets/favicon.svg) | SVG favicon — rounded dark square with warm gold "JS". |
| [scripts/](scripts/) | `rebuild-photos.sh` (photo derivatives) + `print-paste-blocks.rb` (regenerate tribute paste blocks from `_data/messages.yml`). Not served. |
| [docs/](docs/) | Operational runbooks. Not served. |
| `staged_messages.md` | Git-ignored output of `scripts/print-paste-blocks.rb`. Never commit; regenerate on demand. |
| `photos.zip` | Git-ignored raw NextGEN dump from GoDaddy, the migration source-of-record. Local backup only. |

## Canonical docs — one topic, one home

Enforce this when adding anything new. Do NOT restate; link.

- Build / local use / photo pipeline / **tribute management workflow** →
  [README.md](README.md) (including the *Managing tributes* section)
- Local photo-archive policy → [originals/README.txt](originals/README.txt)
- GitHub repo / Pages / Actions / Discussions / Giscus →
  [docs/github-runbook.md](docs/github-runbook.md)
- DNS / custom domain / registrar / email hosting →
  [docs/dns-runbook.md](docs/dns-runbook.md)
- One-time WordPress → Jekyll migration record →
  [docs/godaddy-migration.md](docs/godaddy-migration.md)
- **Live migration checklist** (what's done, what's pending, future tweaks) →
  [HANDOFF-PROMPT-DEVIATION.md](HANDOFF-PROMPT-DEVIATION.md)
- Original browser-Claude handoff prompt (historical) →
  [HANDOFF-PROMPT.md](HANDOFF-PROMPT.md) — kept verbatim; do not edit.

## Decisions already made — don't re-litigate

- **Originals are git-ignored.** Not "in git but excluded from build" — not
  in git at all. `originals/` is local; backup is elsewhere. See
  [originals/README.txt](originals/README.txt). If serving high-res becomes
  a want, the path is object storage (R2/S3) via `photos_base_url` — not
  putting them back in git.
- **Giscus phase 1: seed then lock.** The tribute Discussion is seeded from
  the owner account and then **immediately locked** — the widget on
  `/tributes/` renders comments read-only, no new posts. Don't propose
  reopening for comments unless the user explicitly asks.
- **Featured photos are curated manually**, not auto-selected. Four files
  in [assets/img/featured/](assets/img/featured/); home page lists them
  alphabetically.
- **Page URL is `/tributes/`** (formerly `/blog/`). Nav label is "Tributes";
  matches the GitHub Discussion category name. The `HANDOFF-PROMPT.md`
  still says "blog" and "Messages" — that's the historical prompt, do not
  edit.
- **Tribute data lives in `_data/messages.yml`; paste blocks are regenerated
  via `scripts/print-paste-blocks.rb`.** YAML preserves original curated
  order; the script sorts chronologically at print time (ties = YAML
  declaration order). CSS classes and internal fields keep the "messages"
  name (e.g. `.message`, `messages_display`); page/URL/nav-label are
  "tributes". This split is intentional — don't propose renaming CSS
  classes. Full add-a-tribute workflow: [README § Managing tributes](README.md#managing-tributes).
- **AI translations flagged, not hidden.** Nine Polish entries have
  `translation_ai_generated: true`; six undated entries have
  `date_defaulted: true`. See the header of `_data/messages.yml` for the
  Translation Review Notes.

## Workflow with the user

- Finish one task → report → **STOP**. The user reviews and commits
  before proceeding. Do not auto-chain to the next task.
- Multi-select answers phrased in first person ("I'll do X") mean the user
  is claiming the item, not delegating it to you.
- User is on NixOS and drives the sequence; local execution is your role.

## Progress + remaining work

[HANDOFF-PROMPT-DEVIATION.md](HANDOFF-PROMPT-DEVIATION.md) is the live
checklist with 👤/🤖 attribution and ✓ marks. Consult it for authoritative
state.

Snapshot as of last update:
- Site is live at `https://v2.jozefasobkowicz.com/` (custom **subdomain**
  via CNAME, on `maciuszek/jozefasobkowicz.github.io` project-site repo).
- Tributes seeded to the GitHub Discussion and locked (phase 1 done).
- Remaining: apex DNS switchover to point `jozefasobkowicz.com` at GitHub
  Pages A records, enable HTTPS, cancel GoDaddy hosting (all in Section D
  of the deviation file), plus end-of-migration cleanups: review AI
  translations, remove direnv config, fill Recorded values in the
  runbooks, decide fate of `HANDOFF-PROMPT.md`, and optional revocations.
