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
- Search-visibility / SEO / Google Search Console post-cutover
  actions → [docs/seo-runbook.md](docs/seo-runbook.md)
- One-time WordPress → Jekyll migration record →
  [docs/godaddy-migration.md](docs/godaddy-migration.md)
- **Task journal** (what's done, what's pending, future tweaks) →
  [TASKS.md](TASKS.md). Consolidates the earlier `HANDOFF-PROMPT.md`
  (browser Claude's original 8-task plan) and `HANDOFF-PROMPT-DEVIATION.md`
  (execution record); both remain in git history if the verbatim
  originals are ever needed. **Permanent file** — kept as an ongoing
  journal, not deleted at end of migration. Ticking every checkbox
  does NOT mean removing the file.
  - **Split of concerns:** runbooks own procedures / decisions /
    rationale (evergreen "how / why / what we chose"); TASKS.md owns
    the checklist and timeline (chronological "what happened when").
    No step should live *only* in TASKS.md — if it describes a
    procedure, that procedure belongs in a runbook.

## Decisions already made — don't re-litigate

- **Originals are git-ignored.** Not "in git but excluded from build" — not
  in git at all. `originals/` is local; backup is elsewhere. See
  [originals/README.txt](originals/README.txt). If serving high-res becomes
  a want, the path is object storage (R2/S3) via `photos_base_url` — not
  putting them back in git.
- **Giscus phase 1: seed + Announcement category.** Tribute Discussion
  seeded from the owner account. Protection is the **Announcement**
  category (only maintainers can create new threads); per-thread
  `Lock conversation` was NOT applied — the option wasn't discoverable
  in GitHub's UI for this category configuration, and the accepted
  posture is: low spam risk (memorial site + GitHub sign-in friction),
  any bad-faith reply can be deleted individually. Don't propose adding
  a formal thread lock or reopening the category to General unless the
  user explicitly asks.
- **Featured photos are curated manually**, not auto-selected. Four files
  in [assets/img/featured/](assets/img/featured/); home page lists them
  alphabetically.
- **Page URL is `/tributes/`** (formerly `/blog/`). Nav label is "Tributes";
  matches the GitHub Discussion category name. The original browser-Claude
  prompt (now in git history under `HANDOFF-PROMPT.md`) still says "blog"
  and "Messages" — that's historical context; TASKS.md preserves the
  rename explanation.
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
- **Giscus widget config choices (in `_config.yml` under `giscus:`):**
  - `reactions_enabled: "0"` — reactions header + emoji picker hidden;
    reduces interactive cruft above the tributes on a memorial page.
  - `input_position: "bottom"` — composer sits below the comment list
    so visitors read tributes top-first, action prompt after.
  - `theme: "preferred_color_scheme"` — auto light/dark based on the
    visitor's OS. Don't change without a specific reason.
- **No "email a tribute" invite on `/tributes/`.** Removed 2026-07-26:
  the Giscus composer accepts contributions from signed-in visitors, so
  a redundant email invite is dropped. `contact_email` still shows in
  the footer for general contact. If the discussion is ever formally
  locked, revisit whether an email invite belongs back on the page.
- **DNS: `www CNAME → maciuszek.github.io.`** (NOT `www CNAME →
  jozefasobkowicz.com`). Reason: GitHub's anycast CDN resolves by
  hostname, so `www` survives GitHub IP rotations without needing our
  DNS to change. Full three-point reasoning +
  alternative-considered-but-rejected in
  [docs/dns-runbook.md § DECISION — www CNAME target](docs/dns-runbook.md#decision--www-cname-target).
- **SEO pre-cutover work done, 2026-07-27** — apex canonical URL,
  dynamic image sitemap at [sitemap-images.xml](sitemap-images.xml)
  (215 entries), default `og:image` via `defaults:` block in
  [_config.yml](_config.yml), curated per-page descriptions. SEO
  principles for future edits captured in
  [docs/seo-runbook.md § SEO principles applied](docs/seo-runbook.md#seo-principles-applied-for-future-edits).
  Full head-to-head vs. WordPress + Yoast + NextGEN pinned in
  [docs/godaddy-migration.md § SEO comparison](docs/godaddy-migration.md#seo-comparison-at-cutover-2026-07-27),
  including raw samples that are unrecoverable once WordPress is
  offline. **User declared "SEO done" for pre-cutover.** Four small
  improvements are deferred (alt text on gallery `<img>`,
  `<image:title>`/`<image:caption>` on the image sitemap, dedup
  duplicate title/description head tags, Yoast-equivalent robots
  directive) — captured in
  [seo-runbook § Deferred improvements](docs/seo-runbook.md#deferred-improvements)
  + the migration-doc comparison section. **Do NOT re-propose these
  as urgent.**

## Workflow with the user

- Finish one task → report → **STOP**. The user reviews and commits
  before proceeding. Do not auto-chain to the next task.
- Multi-select answers phrased in first person ("I'll do X") mean the user
  is claiming the item, not delegating it to you.
- User is on NixOS and drives the sequence; local execution is your role.

## Progress + remaining work

[TASKS.md](TASKS.md) is the live checklist with 👤/🤖 attribution and
✓ marks. Consult it for authoritative state.

Snapshot (as of last audit; verify against [TASKS.md](TASKS.md)):
- Repo: `maciuszek/jozefasobkowicz.github.io` — a project site (owner
  already had `maciuszek.github.io` reserved), served via GitHub Actions
  build of Jekyll.
- **Main site: `https://jozefasobkowicz.com/`** — apex, GitHub Pages.
  `https://www.jozefasobkowicz.com/…` HTTP 301-redirects to the apex.
- **Backup path: `http://old.jozefasobkowicz.com/`** (also
  `http://www.old.jozefasobkowicz.com/` — WordPress's own canonical
  form) — the original WordPress site, still served from GoDaddy
  cPanel at `107.180.26.81`. Kept as a fallback during the migration
  window so anyone with a stale bookmark or in-flight search-engine
  index still reaches something. Serves over `http://` only (no TLS
  cert for the `old.` subdomain — expected). Scheduled for
  decommissioning + DNS cleanup once search engines have re-indexed
  and nobody's relying on it.
- Tributes seeded to the GitHub Discussion. Announcement category =
  maintainer-only thread creation; no formal per-thread lock (see
  decisions above).
- Remaining migration work (verify against [TASKS.md](TASKS.md) —
  authoritative):
  - [TASKS.md § F](TASKS.md#f-custom-domain--dns-original-task-8)
    final step: cancel GoDaddy **hosting** (keep the **domain
    registration**). Once hosting is cancelled, the `old.` subdomain
    also becomes dead — then the associated legacy DNS records get
    pruned per
    [dns-runbook § Cleanup backlog](docs/dns-runbook.md#cleanup-backlog-post-wordpress-decommission).
  - [TASKS.md § G2](TASKS.md#g2-after-cutover-in-google-search-console):
    remaining Google Search Console verification checkpoints — most
    G2 items were done 2026-07-27 (sitemap submission, request
    indexing, Removals for outdated content); what's left are
    calendar checks (~1–2 days, ~1 week, ~2 weeks) and removing the
    old Yoast sitemap from GSC.
  - [TASKS.md § End-of-migration cleanup](TASKS.md#end-of-migration-cleanup):
    review AI translations, remove direnv config, fill Recorded
    values, prune legacy DNS records. (TASKS.md itself stays — it's a
    permanent journal.)
  - Optional future tweaks: favicon variations (details in the
    comment at the top of [assets/favicon.svg](assets/favicon.svg))
    + 4 deferred SEO improvements (details in
    [docs/seo-runbook.md § Deferred improvements](docs/seo-runbook.md#deferred-improvements)).
    Both are indexed from [TASKS.md § Future tweaks](TASKS.md#future-tweaks-low-priority-backlog).
- **Historical: v2 subdomain retired.** `v2.jozefasobkowicz.com` was
  used as a transitional staging URL during pre-cutover testing and
  tribute seeding. Its CNAME record was removed at cutover; the URL
  no longer resolves. If you see it referenced in docs, that's
  historical context, not current state.
