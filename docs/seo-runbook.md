# SEO / search visibility runbook — jozefasobkowicz.com

The WordPress site was indexed by Google via Yoast SEO + NextGEN Gallery.
The Jekyll rebuild loses several SEO features Yoast provided by default.
This runbook captures what's replaced, what's deliberately dropped, and
what work is needed to keep search visibility intact through the
WordPress → Jekyll cutover.

**Google Search Console:** the existing domain property
[`sc-domain:jozefasobkowicz.com`](https://search.google.com/search-console?resource_id=sc-domain%3Ajozefasobkowicz.com)
covers both `www` and apex — no re-registration needed. All post-cutover
GSC steps (submit sitemap, request indexing, remove outdated content) live
in [HANDOFF-PROMPT-DEVIATION.md § E](../HANDOFF-PROMPT-DEVIATION.md).

---

## Baseline (what's already in place)

- **[`jekyll-sitemap`](https://github.com/jekyll/jekyll-sitemap) 1.4.0** →
  emits `/sitemap.xml` (page URLs only, no images) + `/robots.txt`
  (auto-generated; points at the sitemap; no `Disallow` rules — leave
  it that way).
- **[`jekyll-seo-tag`](https://github.com/jekyll/jekyll-seo-tag)** → emits
  per-page `<title>`, `<meta name="description">`, canonical link, and
  Open Graph tags. Reads `page.description` if present, falls back to
  `site.description` otherwise.
- **Canonical host = apex** (`jozefasobkowicz.com`, no `www`). Enforced
  by:
  - [`CNAME`](../CNAME) → `jozefasobkowicz.com`
  - [`_config.yml`](../_config.yml) `url:` → `https://jozefasobkowicz.com`
  - GitHub Pages 301-redirects `www.jozefasobkowicz.com` → apex
    automatically when the CNAME is apex.
- **Per-page `description:` front-matter** — all four pages already
  have one (see checklist below for quality review, not addition).

---

## Decisions made — don't re-litigate

- **/tributes/ rename (was /blog/, originally /messages-from-loved-ones/):**
  the messages page URL, nav label, page heading all use "Tributes."
  Old WordPress URL `/messages-from-loved-ones/` will 404 after cutover
  and is scheduled for GSC removal (see DEVIATION § E).
- **Not preserving the old URL** via HTML stub / `<meta http-equiv="refresh">`.
  Considered; rejected. Adds a stub page for a URL Google will drop
  within a few crawl cycles regardless. Cleaner to remove via GSC.
- **Canonical host = apex** (fixed pre-cutover to match `CNAME`). See
  Baseline.
- **Deliberately dropped from Yoast** (accepted losses for a memorial):
  - **JSON-LD structured data** (`schema.org` Person / Article markup).
    Marginal SEO gain, meaningful maintenance surface. Not worth it.
  - **`<lastmod>` / `<priority>` in sitemap.** Google largely ignores
    priority; healthy re-crawl matters more than lastmod tracking.
  - **Server-side 301 redirect management.** Impossible on GitHub Pages
    (static hosting). This is why the retired URL is *removed*, not
    *redirected*.
  - **Yoast readability / focus-keyword tooling.** Authoring aid only;
    no impact on how Google sees the site.

---

## Before-cutover checklist

Do these before the DNS switchover so the new site's SEO is at parity
(or better) on day 1.

### 🔴 [NON-NEGOTIABLE] Image sitemap coverage

The gallery photos need to appear in a sitemap Google can consume,
otherwise photos won't rank in image search — a real traffic source
under NextGEN. Current state: **`_site/sitemap.xml` has ZERO image
tags.**

- [ ] Implement image-sitemap coverage. Two viable approaches:
  - **Custom `sitemap-images.xml.liquid`** at repo root that enumerates
    `site.static_files` filtered to `assets/img/photos/full/`. Emits one
    `<image:image>` per photo under the `/photos/` `<url>` entry. This
    is the recommended approach — no plugin, no per-page front-matter
    upkeep, scales with the gallery.
  - Per-page `image:` front-matter (only sensible for pages with 1–3
    representative images; not scalable to 215 photos).
- [ ] Verify: built file exists at `_site/sitemap-images.xml` and
      contains ~215 `<image:loc>` entries pointing at
      `https://jozefasobkowicz.com/assets/img/photos/full/*.jpg`.
- [ ] Update `robots.txt` to reference both sitemaps
      (jekyll-sitemap's auto-generated one may need overriding with a
      source-tracked `robots.txt` at repo root).
- [ ] Alternative if it's easier: submit both sitemaps separately to
      Google Search Console (see DEVIATION § E).

**Dynamic by design — no upkeep as photos come and go.** The Liquid
template runs on every `jekyll build`, enumerates whatever's currently
in `assets/img/photos/full/`, and emits the corresponding sitemap. Add
a new photo (per [README § Adding photos](../README.md#adding-photos))
→ next Actions build → sitemap includes it → Google discovers it on
the next crawl. Same pattern the site already uses for the home-page
featured slideshow and the `/photos/` gallery grid. No script to
re-run, no list to maintain.

### 🔴 [NON-NEGOTIABLE] /tributes/ rename

Already applied in code (nothing to do):

- [x] Nav label + page heading + permalink all say "Tributes."
- [ ] Post-cutover follow-up: the old `/messages-from-loved-ones/` URL
      will 404. Handle via GSC removal — see DEVIATION § E.

### 🟡 Default `og:image` (social preview card)

Currently no site-wide default. Shared links (iMessage / WhatsApp /
Facebook / Slack previews) will show an empty card.

- [ ] Choose the image. Options:
  - One of the featured photos in [assets/img/featured/](../assets/img/featured/)
    (`DSC_0655.jpg`, `scan0033.jpg`, `scan0022_edited.jpg`, `DSC_0802.jpg`).
  - A dedicated crop at Open Graph's recommended 1200×630 stored as
    `assets/img/og-default.jpg`.
- [ ] Configure via jekyll-seo-tag by adding a `defaults` block in
      [`_config.yml`](../_config.yml):
      ```yaml
      defaults:
        - scope: { path: "" }
          values:
            image: /assets/img/og-default.jpg   # or a featured photo path
      ```
- [ ] Optional per-page override via front-matter `image: /path/to.jpg`.
- [ ] Verify: `grep 'og:image' _site/tributes/index.html` returns a
      populated tag; the URL resolves to a real file.

### 🟡 `description:` quality audit

All four pages have descriptions; targets: 50–160 characters, natural
language, distinct per page.

Applied 2026-07-27:

- [x] [index.html](../index.html) — *"In loving memory of Jozefa
      Sobkowicz, February 25, 1935 – March 1, 2019."* (82 chars, kept
      as-is)
- [x] [about.md](../about.md) — *"The life of Jozefa Sobkowicz
      (1935–2019) — remembered by her family, from Poland and Ukraine
      to Canada."* (102 chars)
- [x] [photos.html](../photos.html) — *"A gallery of photographs of
      Jozefa Sobkowicz — family, portraits, and moments from her life
      across Poland, Ukraine and Canada."* (127 chars)
- [x] [tributes.html](../tributes.html) — *"Tributes from loved ones
      remembering Jozefa Sobkowicz."* (54 chars, kept as-is)

#### SEO principles applied (for future edits)

Use these when writing a description for a new page or refining an
existing one:

1. **Length in the sweet spot (~120–160 chars).** Google truncates SERP
   snippets around 155–160 characters — anything longer gets cut off
   with `...`. Shorter than ~50 chars looks anemic and Google may
   generate its own snippet from page content instead (unpredictable
   and often worse than what you'd write). It's fine for a description
   to be shorter than the sweet spot if it reads naturally at that
   length; don't pad.
2. **Unique per page.** Duplicate or near-identical descriptions across
   pages hurt SERP ranking — search algorithms treat them as low-value
   metadata. Every page's description should be distinguishable.
3. **Real words a person might search for**, woven into natural prose.
   Not keyword-stuffing. Examples of what was added in the round above:
   - `/about/`: `(1935–2019)` — years are searchable ("Jozefa Sobkowicz
     1935").
   - `/about/` + `/photos/`: geographic anchors `Poland`, `Ukraine`,
     `Canada` — actual search terms for family-history queries.
   - `/photos/`: `gallery`, `family`, `portraits`, `moments` — words
     someone looking for a photo archive would type.
4. **Natural prose, not a keyword dump.** No `keywords:` field, no
   dashes-and-commas lists. Modern search algorithms rank human
   language above keyword-stuffed pages. Read the description out loud
   before saving — if it doesn't sound like something a person would
   say describing the page, rewrite.

**Where descriptions surface:**
- Google search results (SERP snippet under the page title)
- Social media preview cards (iMessage, WhatsApp, Facebook, Slack) —
  the description pairs with `og:image` (see above) to form the card
- Anywhere a `<meta name="description">` reader consumes the page
  (Twitter, RSS enrichment tools, etc.)

### 🟢 Sitemap + robots.txt smoke check

Post-build, pre-cutover:

- [ ] `_site/sitemap.xml` lists all 4 pages with apex URLs (no `www`,
      matches CNAME).
- [ ] `_site/robots.txt` says `Sitemap: https://jozefasobkowicz.com/sitemap.xml`.
- [ ] `_site/sitemap-images.xml` (or equivalent) exists and lists all
      photo URLs (see NON-NEGOTIABLE above).
- [ ] Every built page has `<link rel="canonical">`, `<meta
      name="description">`, `<meta property="og:image">` in the head.

---

## Deliberate non-goals (things NOT to add)

- **HTML redirect stub at `/messages-from-loved-ones/`** — considered;
  rejected (see Decisions above).
- **`schema.org` JSON-LD** — see Decisions above.
- **Sitemap `<lastmod>` / `<priority>`** — see Decisions above.
- **Bing Webmaster Tools / Yandex / other search engines' owner
  consoles** — we DO run the full post-cutover workflow in Google
  Search Console (see DEVIATION § E2). What we're skipping here is the
  equivalent owner-console dance for *other* engines. Reason: memorial
  site with modest traffic; Bing / Yandex / etc. crawlers will still
  discover the new site via existing inbound links and Google's index
  eventually — just without the manual "submit sitemap + request
  indexing + remove outdated URLs" acceleration. If ever registered
  previously on Bing/Yandex, at minimum submit the new sitemap there
  too; otherwise skip.

---

## Also worth doing (out-of-scope for the runbook, don't forget)

- Update any external inbound links pointing to
  `/messages-from-loved-ones/` if you know of them — obituary sites,
  personal social profiles, funeral home page, family email footers.
  These are user-owned, one-time edits.
- A week after cutover: search *"Jozefa Sobkowicz"* in Google (fresh
  incognito) — confirm the new site surfaces with the current title +
  description, not the WordPress version.
