# jozefasobkowicz.com — task journal

Living record of what's been done on the site and what's still on the
list. Each item points at the relevant runbook for *how* / *why*; this
file is the *what* and *when*.

**Origin:** Started 2026-07-27 as a consolidation of the earlier
`HANDOFF-PROMPT.md` (browser Claude's original 8-task migration plan)
and `HANDOFF-PROMPT-DEVIATION.md` (Claude Code's execution record).
Both older files were then deleted; git history preserves the verbatim
originals. Kept as a permanent journal — new items get appended over
time; ticking every checkbox does NOT mean deleting the file.

**Split of concerns:**
- **Runbooks in [docs/](docs/)** own procedures, decisions,
  rationale — the durable "how / why / what we chose".
- **This file** owns the checklist and the timeline — "what happened
  when, and who did it".
- No step lives *only* in this file. If a task item describes a
  procedure, that procedure belongs in a runbook.

**Runbooks referenced:**
- [docs/github-runbook.md](docs/github-runbook.md) — repo, Pages, Discussions, Giscus
- [docs/dns-runbook.md](docs/dns-runbook.md) — DNS, custom domain, HTTPS, cleanup
- [docs/seo-runbook.md](docs/seo-runbook.md) — search visibility + Search Console procedures
- [docs/godaddy-migration.md](docs/godaddy-migration.md) — historical migration record + SEO comparison
- [README.md](README.md) — build / local use / tribute management

**Notation**
- 👤 = manual step (you, in a browser / GitHub / GoDaddy dashboard)
- 🤖 = local step (Claude Code, in this repo)
- ✓ = done (with date)
- ! = missed critical item that would block a basic functional migration. **None flagged as of 2026-07-27.**

---

## Origin context (2026-07-20 handoff)

Scaffold was built in a **browser Claude session** (no filesystem /
network access) and handed off via `HANDOFF-PROMPT.md` (an 8-task
plan) to a local Claude Code agent on NixOS for execution. The
original 8 tasks:

1. Local Jekyll build in Nix dev shell
2. Download WordPress photos as originals
3. Generate served derivatives (full + thumbs) via ImageMagick
4. Copy featured photos to `assets/img/featured/`
5. Decide where originals live (git-tracked vs object storage)
6. Seed the Messages/Tributes thread on Giscus
7. Publish the repo to GitHub Pages
8. Custom domain + DNS cutover

**Execution deviated from the numeric order** — Task 6 (Giscus)
depends on Task 7 (repo on GitHub), so we ran **7 → 6 → 8**. The
lettered sections below use the actual execution order.

**Naming that changed mid-migration:** the original prompt called the
tributes page `blog.html` / URL `/blog/` / nav label "Messages".
Renamed to `tributes.html` / `/tributes/` / "Tributes" on 2026-07-26
to match the GitHub Discussion category. Old-name references gone
from the code; `docs/godaddy-migration.md` preserves the WordPress-era
context.

---

## A. Local build (original Task 1)

- [✓] 🤖 Nix dev shell + `bundle install` + `jekyll build` clean —
      **2026-07-20**. Fixed a Jekyll excludes issue along the way.

## B. Photos — originals, derivatives, featured, storage (original Tasks 2–5)

- [✓] 👤+🤖 **Originals** — **2026-07-20**. You supplied
      [photos.zip](photos.zip) (raw NextGEN dump); I extracted the
      `_backup` files into [originals/](originals/) (215 photos,
      ~404 MiB). Procedure: [godaddy-migration § Extraction procedure](docs/godaddy-migration.md#extraction-procedure-reference).
- [✓] 🤖 **Derivatives** — **2026-07-20**. Generated `assets/img/photos/{full,thumbs}/`
      from `originals/` via [scripts/rebuild-photos.sh](scripts/rebuild-photos.sh).
- [✓] 🤖 **Featured** — **2026-07-20**. Four derivatives
      (`DSC_0655`, `scan0033`, `scan0022_edited`, `DSC_0802`) copied
      to [assets/img/featured/](assets/img/featured/).
- [✓] 👤 **Storage decision** — **2026-07-26**. Originals are
      git-ignored, local-only. Backup = `photos.zip` + external
      drive/cloud. See [originals/README.txt](originals/README.txt);
      object-storage path stays open via `photos_base_url` in
      [_config.yml](_config.yml).

## C. Publish to GitHub Pages (original Task 7)

Procedure: [github-runbook § 1–2](docs/github-runbook.md#1-create-the-public-repo-and-push).

- [✓] 👤 Public repo created on github.com — **2026-07-25**.
      `maciuszek/jozefasobkowicz.github.io` (project site, not user
      site).
- [✓] 👤 Local branch renamed `master` → `main` and pushed —
      **2026-07-25**.
- [✓] 👤 **Settings → Pages → Source: GitHub Actions** —
      **2026-07-25**. First build passed in ~1–2 min.
- [✓] 👤 Walked the temp `*.github.io` URL — all 4 pages render,
      `/tributes/` shows Giscus placeholder as expected — **2026-07-25**.

## D. Enable Discussions + wire up Giscus (original Task 6)

Procedure: [github-runbook § 3–4](docs/github-runbook.md#3-enable-discussions).

- [✓] 👤 Discussions enabled + **Tributes** category created (format:
      **Announcement**) — **2026-07-25**.
- [✓] 👤 Giscus app installed on this repo — **2026-07-25**.
- [✓] 👤+🤖 Giscus IDs pulled from https://giscus.app and pasted into
      [_config.yml](_config.yml) — **2026-07-25**. Widget replaces
      the placeholder on `/tributes/`.

## E. Seed the tribute thread (original Task 6 cont'd)

Procedure: [github-runbook § 5–6](docs/github-runbook.md#5-seed-the-tribute-thread).

- [✓] 🤖 Enriched [_data/messages.yml](_data/messages.yml) with AI
      translations (9 Polish entries), defaulted March-1-2019 dates
      (6 undated entries), Translation Review Notes in the file
      header — **2026-07-26**.
- [✓] 👤 Seeded the Discussion — **2026-07-26**. 18 comments posted
      via the Giscus composer, one per entry, using
      `./scripts/print-paste-blocks.rb` output. Originally seeded on
      the transitional `v2.jozefasobkowicz.com` staging subdomain;
      Giscus maps by pathname, so the thread was picked up at the
      apex after cutover.
- [ ] 👤 Proofread AI translations in
      [_data/messages.yml](_data/messages.yml) — see the *Translation
      Review Notes* section in the file header. **Two-place update
      needed**: edit the YAML archive AND the corresponding posted
      Giscus comments (neither auto-syncs). Non-blocking — tributes
      are already readable.
- [✓] 👤 Moderation posture = Announcement category, no per-thread
      lock — **2026-07-26**. See
      [github-runbook § 6](docs/github-runbook.md#6-moderation-posture-announcement-category)
      for reasoning.

## F. Custom domain + DNS (original Task 8)

Procedure: [dns-runbook](docs/dns-runbook.md).

- [✓] 👤 Pre-flight ([dns-runbook § 1](docs/dns-runbook.md#1-pre-flight))
      — **2026-07-27**.
- [✓] 👤 GitHub Pages Custom domain confirmed as `jozefasobkowicz.com`
      (auto-populated from [CNAME](CNAME)) — **2026-07-27**.
- [✓] 👤 GoDaddy DNS: 4 apex A records + `www` CNAME set per
      [dns-runbook § 3](docs/dns-runbook.md#3-configure-godaddy-dns-records)
      — **2026-07-27**.
- [✓] 👤 Propagation verified with `dig`: apex → 4 GitHub Pages IPs;
      `www` CNAME → `maciuszek.github.io.` — **2026-07-27**.
- [✓] 👤 **Enforce HTTPS** enabled after Let's Encrypt cert issued —
      **2026-07-27**.
- [ ] 👤 **Cancel GoDaddy hosting** (keep the domain registration).
      Procedure + ordered sequence:
      [dns-runbook § Cancel GoDaddy hosting](docs/dns-runbook.md#cancel-godaddy-hosting).
      Decide email hosting first
      ([dns-runbook § Email hosting](docs/dns-runbook.md#email-hosting-jozefasobkowiczcom)).

## G. SEO / search visibility (post-cutover)

Procedures: [seo-runbook](docs/seo-runbook.md).

### G1. Before cutover (in the repo)

- [✓] 🤖 🔴 **Image sitemap** at [sitemap-images.xml](sitemap-images.xml)
      — 215 `<image:loc>` entries, dynamic from
      `assets/img/photos/full/` — **2026-07-27**. See
      [seo-runbook § Image sitemap coverage](docs/seo-runbook.md#-non-negotiable-image-sitemap-coverage).
- [✓] 🤖 Default **og:image** set via `defaults:` in [_config.yml](_config.yml)
      — **2026-07-27**.
- [✓] 👤 Per-page `description:` audit + tightening — **2026-07-27**.
      Principles: [seo-runbook § SEO principles applied](docs/seo-runbook.md#seo-principles-applied-for-future-edits).
- [✓] 🤖 Smoke check (canonical apex, description, og:image, sitemap
      counts) — **2026-07-27**.

### G2. After cutover (in Google Search Console)

Procedures: [seo-runbook § Post-cutover procedures](docs/seo-runbook.md#post-cutover-procedures).

- [✓] 👤 Verified canonical host: `https://www.jozefasobkowicz.com/tributes/`
      HTTP 301 → apex — **2026-07-27**.
- [ ] 👤 Remove the old Yoast sitemap from GSC (if registered).
      Non-blocking — will 404 naturally once WordPress hosting is
      cancelled.
- [✓] 👤 Submitted both sitemaps (`sitemap.xml` + `sitemap-images.xml`)
      to Search Console — **2026-07-27**.
- [✓] 👤 Requested indexing for the 4 canonical pages via URL
      Inspection — **2026-07-27**. `/tributes/` returned "Soft 404" on
      first pass (Giscus/JS rendering); accept-and-wait decision
      captured in [seo-runbook § Deliberate non-goals](docs/seo-runbook.md#deliberate-non-goals-things-not-to-add).
- [✓] 👤 Removals submitted — **2026-07-27**. 4 requests all *Temporarily
      Remove URL*:
      1. Single URL: `https://jozefasobkowicz.com/messages-from-loved-ones/`
      2. Single URL: `https://jozefasobkowicz.com/blog/`
      3. Prefix: `https://jozefasobkowicz.com/wp-content/gallery/`
      4. Prefix: `https://jozefasobkowicz.com/wp-content/uploads/`

      *A single `/wp-content/` prefix would have collapsed 3+4 into one
      request; the two-narrower-prefix form was submitted first and
      processed successfully. Procedure + guidance:
      [seo-runbook § Post-cutover: Removals](docs/seo-runbook.md#post-cutover-removals).*
- [ ] 👤 **~1–2 days after submission** — confirm all 4 Removals moved
      *Processing request* → *Approved*.
- [ ] 👤 **~1 week after cutover** — verify indexing + coverage per
      [seo-runbook § Post-cutover: Verification schedule](docs/seo-runbook.md#post-cutover-verification-schedule).
- [ ] 👤 **~2 weeks after cutover** — re-check `/tributes/` Soft 404
      per same schedule section. Exit condition for the accept-and-wait
      decision.

### G3. Also worth doing (owner-side, one-time)

- [ ] 👤 Update external inbound links pointing at
      `/messages-from-loved-ones/` — obituary sites, funeral home
      page, social profiles, personal email signatures, family group
      chats. Out-of-scope for the repo; just don't forget.
- [ ] 👤 A week after cutover, incognito-search *"Jozefa Sobkowicz"*
      in Google — confirm the new site appears with current title +
      description.

---

## End-of-migration cleanup

Wrap-up items to knock out once everything above settles. TASKS.md
itself is not deleted at the end — it stays as an ongoing journal.

- [ ] 👤 **Prune WordPress-era legacy DNS records** at GoDaddy after
      cancelling hosting (F). Procedure + full record list:
      [dns-runbook § Cleanup backlog](docs/dns-runbook.md#cleanup-backlog-post-wordpress-decommission).
- [ ] 👤 Review AI-generated translations in
      [_data/messages.yml](_data/messages.yml). See § E above.
- [ ] 🤖 Remove direnv support — delete [`.envrc`](.envrc), drop
      `.direnv/` from [`.gitignore`](.gitignore), strip `direnv allow`
      / `.envrc` mentions from [README.md](README.md) and
      [CLAUDE.md](CLAUDE.md). Owner never adopted direnv; only reason
      it exists is the original scaffold assumed it.
- [ ] 👤 (Optional) Rename local repo directory to `<owner>.github.io`
      convention. Purely local — no repo impact.
- [ ] 👤 Fill **Recorded values** blanks in
      [docs/github-runbook.md](docs/github-runbook.md) and
      [docs/dns-runbook.md](docs/dns-runbook.md) so those docs become
      as-built records, not just plans.
- [ ] 👤 `rm -rf /tmp/photos-unzip.*` if still present (optional).
- [✓] 👤 (Optional) Revoked the Giscus OAuth authorization —
      **2026-07-26**. Cosmetic; discussion keeps working. See
      [github-runbook § Optional: revoke your Giscus OAuth grant](docs/github-runbook.md#optional-revoke-your-giscus-oauth-grant).

---

## Future tweaks (low-priority backlog)

Nice-to-haves parked for later. **Details live in the referenced
runbooks / files;** this section is just the index.

- **Favicon variations** (colors, serif choice, letter spacing,
  transparent background, Fraunces path-render). Options listed in
  the comment at the top of [assets/favicon.svg](assets/favicon.svg).
- **4 deferred SEO improvements** (alt text on `/photos/` `<img>`,
  `<image:title>`/`<image:caption>` on sitemap-images.xml, dedup
  duplicate `<title>`/`<meta description>` from head.html, Yoast-
  equivalent robots snippet directives). Full context + exact diffs +
  verbatim WordPress reference in
  [seo-runbook § Deferred improvements](docs/seo-runbook.md#deferred-improvements)
  (and further detail in
  [godaddy-migration § SEO comparison](docs/godaddy-migration.md#seo-comparison-at-cutover-2026-07-27)).
