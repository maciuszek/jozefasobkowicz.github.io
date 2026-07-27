# Task deviations from HANDOFF-PROMPT.md

Live tracker for the migration plan. The original 8-task list lives in
[HANDOFF-PROMPT.md](HANDOFF-PROMPT.md); this file captures what we
actually did, what's left, and — for the remaining tasks — who does each
step (you vs. me). Use to verify nothing's forgotten before we call the
migration done. Delete when everything is checked off.

Canonical procedures for the remaining work:
- [docs/github-runbook.md](docs/github-runbook.md) — repo, Pages,
  Discussions, Giscus
- [docs/dns-runbook.md](docs/dns-runbook.md) — DNS, custom domain,
  HTTPS, cleanup

**Notation**
- 👤 = manual step (you, in a browser / GitHub / GoDaddy dashboard)
- 🤖 = local step (Claude Code, in this repo)
- ✓ = done

---

## Completed (original tasks 1–5)

- ✓ 🤖 **Task 1 — Local build.** Nix dev shell + `bundle install` +
  `jekyll build` clean. Fixed a Jekyll excludes issue along the way.
- ✓ 👤+🤖 **Task 2 — Originals.** You supplied `photos.zip` (NextGEN
  dump); I extracted and sorted the `_backup` files into `originals/`
  (215 photos, 404 MiB). See
  [docs/godaddy-migration.md § Extraction procedure](docs/godaddy-migration.md#extraction-procedure-reference).
- ✓ 🤖 **Task 3 — Derivatives.** [scripts/rebuild-photos.sh](scripts/rebuild-photos.sh)
  produces `assets/img/photos/{full,thumbs}/` from `originals/`.
- ✓ 🤖 **Task 4 — Featured photos.** Four derivatives copied to
  [assets/img/featured/](assets/img/featured/).
- ✓ 👤 **Task 5 — Storage decision.** Originals are **git-ignored**,
  local-only, backed up via `photos.zip` + external drive/cloud.
  Object-storage path (R2/S3) stays open for later if wanted. See
  [originals/README.txt](originals/README.txt).

---

## Remaining work

**Order deviates from the original 1–8:** original Task 6 (Giscus)
depends on original Task 7 (repo on GitHub), so we execute **7 → 6 → 8**.
Checklist below is in actual execution order.

### A. Publish to GitHub Pages (original Task 7)

Canonical: [github-runbook.md § 1–2](docs/github-runbook.md#1-create-the-public-repo-and-push).

- [✓] 👤 Create a **public** repo on github.com. Do NOT initialize with
      README/.gitignore/license — we have all three.
- [✓] 👤 Locally: `git branch -m master main`, `git remote add origin …`,
      `git push -u origin main`.
- [✓] 👤 **Settings → Pages → Source: GitHub Actions.**
- [✓] 👤 Watch the **Actions** tab; first build takes 1–2 min.
- [✓] 👤 Walk the temp `*.github.io` URL: `/`, `/about/`, `/photos/`,
      `/tributes/` all render. `/tributes/` will show the Giscus placeholder —
      expected.

### B. Enable Discussions + wire up Giscus (original Task 6)

Canonical: [github-runbook.md § 3–4](docs/github-runbook.md#3-enable-discussions).

- [✓] 👤 **Settings → General → Features → Discussions:** enable.
- [✓] 👤 Create a category — recommended: **Tributes**, format
      **Announcement**.
- [✓] 👤 Install the Giscus app: https://github.com/apps/giscus →
      grant access to this repo only.
- [✓] 👤 At https://giscus.app, configure repo + category (mapping =
      pathname) and copy the four values: `repo`, `repo_id`, `category`,
      `category_id`.
- [✓] 🤖 Paste those four values into [_config.yml](_config.yml)'s
      `giscus:` block; commit + push. Actions redeploys.
- [✓] 👤 Reload `/tributes/` — the Giscus widget replaces the placeholder.

### C. Seed the tribute thread (original Task 6 cont'd)

Canonical: [github-runbook.md § 5–6](docs/github-runbook.md#5-seed-the-tribute-thread).

- [✓] 🤖 Enriched [_data/messages.yml](_data/messages.yml) with all the
      "matured" content (AI translations, defaulted dates, Translation
      Review Notes in the header). YAML is the canonical source of
      truth; entries stay in original WordPress order.
      [scripts/print-paste-blocks.rb](scripts/print-paste-blocks.rb)
      renders paste-ready markdown blocks from it, sorted
      chronologically at print time.
- [✓] 👤 Generate the paste blocks and seed them. From the repo root
      (inside `nix develop`):
      `./scripts/print-paste-blocks.rb > staged_messages.md` (the file
      is git-ignored). Open it,
      then — logged in as the repo owner — copy the content INSIDE each
      fenced block and paste into the Giscus composer at
      https://jozefasobkowicz.com/tributes/, one comment per block,
      18 total. (Historical: originally done on the transitional
      `v2.jozefasobkowicz.com` staging subdomain, since retired
      post-cutover. Giscus maps threads by pathname regardless of
      hostname, so the same Discussion is now visible at the apex URL.)
- [ ] 👤 Proofread AI translations in
      [_data/messages.yml](_data/messages.yml) — see the Translation
      Review Notes in the file's header comment. Edits made there
      propagate to future runs of the paste-blocks script; refinements
      to already-posted Giscus comments have to be applied directly on
      GitHub.
- [✓] 👤 Moderation posture = **Announcement category** (from Section B).
      Only maintainers can create Discussion threads, which is the
      primary spam mitigation. Per-thread `Lock conversation` was NOT
      applied — the option wasn't discoverable in the current GitHub UI
      for this category configuration, and the accepted posture is:
      sign-in friction + low memorial-site profile mean spam risk is
      minimal; any unwanted reply can be deleted individually. See
      [runbook § 6](docs/github-runbook.md#6-moderation-posture-announcement-category).

### D. Custom domain + DNS (original Task 8)

Canonical: [dns-runbook.md](docs/dns-runbook.md). Do this only after
the temp `*.github.io` site looks right.

- [✓] 👤 Pre-flight ([dns-runbook § 1](docs/dns-runbook.md#1-pre-flight)):
      confirm current GitHub Pages A-record IPs, back up any
      `@jozefasobkowicz.com` email you want to keep, verify
      [CNAME](CNAME) is `jozefasobkowicz.com`.
- [✓] 👤 **Settings → Pages → Custom domain:** confirm
      `jozefasobkowicz.com` is set (auto-populated on first Pages
      deploy from [CNAME](CNAME)).
- [✓] 👤 In GoDaddy DNS, replace apex records with the four GitHub
      Pages A records + `www` CNAME →
      [dns-runbook § 3](docs/dns-runbook.md#3-configure-godaddy-dns-records).
- [ ] 👤 Wait for propagation; verify with `dig`.
- [✓] 👤 **Settings → Pages → Enforce HTTPS:** tick (after cert issues).
- [ ] 👤 Cancel GoDaddy **hosting** — keep the **domain registration**.
      Decide on email hosting first ([dns-runbook § Email hosting](docs/dns-runbook.md#email-hosting-jozefasobkowiczcom)).
      **Cancelling hosting implicitly decommissions the WordPress backup
      at `old.jozefasobkowicz.com`** (the cPanel/WordPress server goes
      away). But the DNS records pointing at `107.180.26.81` persist as
      dead pointers until manually pruned — see the DNS pruning item in
      End-of-migration cleanup below.

### E. SEO / search visibility (post-cutover)

Canonical: [docs/seo-runbook.md](docs/seo-runbook.md). Two 🔴
NON-NEGOTIABLES to close **before** cutover (image sitemap + tributes
rename); everything else in this section runs in
[Google Search Console](https://search.google.com/search-console?resource_id=sc-domain%3Ajozefasobkowicz.com)
**after** the site is live on `jozefasobkowicz.com`. The existing
domain property already covers both apex + `www` — no re-registration.

#### E1. Before cutover (in the repo)

- [✓] 🤖 🔴 **Image sitemap** — implemented as
      [sitemap-images.xml](sitemap-images.xml) at repo root; enumerates
      `assets/img/photos/full/` dynamically at every build. Verified:
      `_site/sitemap-images.xml` emits 215 `<image:loc>` entries with
      absolute apex URLs, and `sitemap: false` front-matter keeps it
      out of the pages sitemap. See
      [seo-runbook § Image sitemap coverage](docs/seo-runbook.md#-non-negotiable-image-sitemap-coverage).
- [✓] 🤖 Added default **`og:image`** — `defaults:` block in
      [_config.yml](_config.yml) points every page at
      `/assets/img/featured/DSC_0655.jpg`. Verified: all 4 built pages
      emit `<meta property="og:image" content="https://jozefasobkowicz.com/assets/img/featured/DSC_0655.jpg">`.
      Per-page override still works via front-matter `image:` if a
      specific page ever needs a different card.
- [✓] 👤 Tightened thin `description:` front-matter on
      [photos.html](photos.html) and enriched [about.md](about.md);
      others kept as-is. SEO principles captured in
      [seo-runbook § SEO principles applied](docs/seo-runbook.md#seo-principles-applied-for-future-edits).
- [✓] 👤 Rebuilt + spot-checked: every built page has `<link
      rel="canonical">` (apex), `<meta name="description">` (distinct
      per page), `<meta property="og:image">` (defaulted to
      `DSC_0655.jpg`), and `sitemap-images.xml` enumerates all 215
      photos.

#### E2. After cutover (in Google Search Console)

Run these in order after DNS resolves + HTTPS is enforced.

- [✓] 👤 **Verify canonical host** — in a fresh incognito window,
      request `https://www.jozefasobkowicz.com/tributes/`; confirm it
      301-redirects to `https://jozefasobkowicz.com/tributes/` and
      displays the Jekyll site.
- [ ] 👤 **Remove the old Yoast sitemap** from Search Console, if
      registered (e.g. `sitemap_index.xml`). Sitemaps → old entry →
      *Remove sitemap*. Yoast generated it dynamically; it will 404
      once WordPress is gone.
- [✓] 👤 **Submit the new sitemap(s):**
      `https://jozefasobkowicz.com/sitemap.xml` (pages), and
      `https://jozefasobkowicz.com/sitemap-images.xml` (photos, if
      implemented as a separate file). Sitemaps → *Add a new sitemap*.
- [ ] 👤 **Request indexing** for the four canonical pages, via URL
      Inspection (one at a time):
      `/`, `/about/`, `/photos/`, `/tributes/`.
- [ ] 👤 **Remove outdated content** — via
      [Removals → Outdated Content](https://search.google.com/search-console/remove-outdated-content) —
      for URLs that now 404:
      - `/messages-from-loved-ones/` (retired; replaced by
        `/tributes/`).
      - Old NextGEN image paths under `/wp-content/gallery/…` — Google
        drops dead URLs on its own eventually; this just hurries it.
        If the index has many, focus on the highest-traffic entries
        surfaced in the Search Console index report.
- [ ] 👤 **No action needed for `/`, `/about/`, `/photos/`** (same
      URLs, new content). Stale snippets refresh automatically over
      the next few crawl cycles. Patience for a few weeks.
- [ ] 👤 **~1 week after cutover — verify** — revisit Search Console
      Coverage / Index. Confirm the four Jekyll URLs are indexed with
      current content, the retired URLs no longer surface, and the
      image sitemap was fetched. Investigate any surprises (sitemap
      not fetched, image sitemap ignored, unexpected 404s).

#### E3. Also worth doing (owner-side, one-time)

- [ ] 👤 Update any external inbound links pointing at
      `/messages-from-loved-ones/` — obituary sites, funeral home page,
      social profiles, personal email signatures, family group chats.
      One-time, out-of-scope for the repo; just don't forget.
- [ ] 👤 A week after cutover, search *"Jozefa Sobkowicz"* in Google
      (incognito) — confirm the new site appears with the current
      title + description, not the WordPress snippet.

---

## End-of-migration cleanup

Once everything above is checked off:

- [ ] 👤 Decide on `HANDOFF-PROMPT.md` at repo root — keep, gitignore,
      or delete. Currently tracked, kept as history.
- [ ] 👤 Delete this file (`HANDOFF-PROMPT-DEVIATION.md`). Its purpose
      ends here.
- [ ] 👤 **Prune the WordPress-era legacy DNS records at GoDaddy** —
      after cancelling GoDaddy hosting (Section D above), the site at
      `old.jozefasobkowicz.com` is implicitly dead (server gone), but
      the 10 legacy `.old` / `_domainconnect` DNS records at the
      registrar persist as dead pointers. Remove per
      [dns-runbook § Cleanup backlog](docs/dns-runbook.md#cleanup-backlog-post-wordpress-decommission).
      Post-prune the zone should have exactly 7 non-legacy records
      (4 apex A + `www` CNAME + `TXT google-site-verification` + NS/SOA
      as one registrar-default set). One-time task, GoDaddy DNS panel.
- [ ] 👤 Review the AI-generated translations in
      [_data/messages.yml](_data/messages.yml) — walk through the
      *Translation review notes* section in the file's header comment
      and refine as desired. Refinements should be applied in two
      places: (a) edit the AI translations in `_data/messages.yml` so
      the archive stays accurate and future re-seeds carry the
      corrections, and (b) edit the corresponding posted Giscus
      comments on GitHub so visitors see the refined text.
- [ ] 🤖 Remove direnv support (owner doesn't use it): delete
      [`.envrc`](.envrc), drop the `.direnv/` line from
      [`.gitignore`](.gitignore), and remove the `direnv allow` /
      `.envrc` mentions from [README.md](README.md) and
      [CLAUDE.md](CLAUDE.md).
- [ ] 👤 (Optional) Rename the parent repo directory on your machine to
      match the GitHub Pages convention `<owner>.github.io` if you're
      using a user site (e.g. `jozefasobkowicz.github.io`). Purely
      local — no impact on the repo contents or GitHub side.
- [ ] 👤 Fill in the **Recorded values** blanks in
      [docs/github-runbook.md](docs/github-runbook.md) and
      [docs/dns-runbook.md](docs/dns-runbook.md) so those docs become
      as-built records, not just plans.
- [ ] 👤 `rm -rf /tmp/photos-unzip.*` if still present (optional).
- [✓] 👤 (Optional) Revoke the **Giscus OAuth authorization** you
      granted during seeding — visit
      [github.com/settings/apps/authorizations](https://github.com/settings/apps/authorizations),
      find *Giscus*, click **Revoke**. Purely cosmetic on your
      "authorized apps" list; the discussion keeps working either way
      (the OAuth grant is only needed to POST as you, not to render
      existing comments). See
      [github-runbook § Optional: revoke your Giscus OAuth grant](docs/github-runbook.md#optional-revoke-your-giscus-oauth-grant).

---

## Future tweaks (post-migration, low priority)

Ideas parked for later. None block the migration; revisit when the mood
strikes.

### Favicon ([assets/favicon.svg](assets/favicon.svg))

Current: dark ink (`#2B2622`) rounded square, warm gold (`#C9AE73`) "JS"
in Georgia serif. Possible refinements:

- **Swap colors** — try paper (`#FBF8F2`) background with ink or gold
  letters for a lighter feel.
- **Different serif** — Baskerville, Playfair Display, EB Garamond,
  Cormorant. Just change `font-family` in the SVG.
- **Letter spacing** — add `letter-spacing="-0.02em"` (tighter) or
  positive value (airier) on the `<text>` element.
- **No square background** — remove the `<rect>` for free-floating "JS"
  letters on a transparent background.
- **Full-color match to Fraunces** — pre-render "JS" as SVG `<path>`
  elements using the site's actual Fraunces face. Requires external
  tooling (Inkscape / Fontforge / an online SVG text-to-path converter);
  the payoff is that the favicon glyph matches the headline face
  exactly.

Browsers cache favicons aggressively — hard-refresh (Ctrl+Shift+R) or a
private window is usually needed to see edits.

### SEO refinements (deferred)

Four small improvements considered during the pre-cutover analysis
against WordPress + Yoast + NextGEN Gallery. None block ranking or
cutover; captured here so they aren't lost. **Full context, exact
diffs, and — critically — verbatim samples of the WordPress state at
the time of comparison** (needed because once WordPress is offline
that reference is unrecoverable) live in
[docs/godaddy-migration.md § SEO comparison at cutover](docs/godaddy-migration.md#seo-comparison-at-cutover-2026-07-27).

- **Alt text on `<img>` tags in `/photos/`** — currently `alt=""` on
  all 215; replace with a generic `"Photograph of Jozefa Sobkowicz"`.
  Accessibility win, minor SEO signal.
- **`<image:title>` / `<image:caption>` on
  [sitemap-images.xml](sitemap-images.xml)** entries — WordPress had
  these (populated with filenames); we have `<image:loc>` only.
- **Remove duplicate `<title>` and `<meta name="description">`** from
  [_includes/head.html](_includes/head.html) — jekyll-seo-tag already
  emits both. Cosmetic dedup.
- **Yoast-equivalent `<meta name="robots">` snippet directives** in
  [_includes/head.html](_includes/head.html): the exact string is
  captured in the migration doc.

If any becomes a priority, promote it into
[docs/seo-runbook.md](docs/seo-runbook.md) as an active checklist item.
