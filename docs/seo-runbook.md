# SEO / search visibility runbook — jozefasobkowicz.com

The WordPress site was indexed by Google via Yoast SEO + NextGEN Gallery.
The Jekyll rebuild loses several SEO features Yoast provided by default.
This runbook captures what's replaced, what's deliberately dropped, and
what work is needed to keep search visibility intact through the
WordPress → Jekyll cutover.

**Google Search Console:** the existing domain property
[`sc-domain:jozefasobkowicz.com`](https://search.google.com/search-console?resource_id=sc-domain%3Ajozefasobkowicz.com)
covers both `www` and apex — no re-registration needed. Post-cutover
GSC procedures live in this runbook under
[Post-cutover procedures](#post-cutover-procedures); [TASKS.md § G](../TASKS.md#g-seo--search-visibility-post-cutover)
records what was actually run and when.

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
  and is scheduled for GSC removal (see
  [Post-cutover: Removals](#post-cutover-removals)).
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

- [x] Implemented via **[sitemap-images.xml](../sitemap-images.xml)** at
      repo root — Liquid template that enumerates `site.static_files`
      filtered to `assets/img/photos/full/`. Emits one `<image:image>`
      per photo under a single `<url>` entry for `/photos/`. No plugin,
      no per-page front-matter upkeep; scales as photos are added.
- [x] Verified 2026-07-27: `_site/sitemap-images.xml` exists with 215
      `<image:loc>` entries under `https://jozefasobkowicz.com/assets/img/photos/full/*.jpg`.
      `sitemap: false` front-matter keeps it out of jekyll-sitemap's
      output.
- [ ] Update `robots.txt` to reference both sitemaps — **deferred, not
      needed.** Superseded by the alternative below: both sitemaps
      submitted directly to Google Search Console. Would only matter
      for search engines other than Google, which we're not
      prioritizing (see *Deliberate non-goals*).
- [x] Alternative taken 2026-07-27: both sitemaps submitted separately
      to Google Search Console (TASKS.md § G2).

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
- [x] Post-cutover follow-up done 2026-07-27: `/messages-from-loved-ones/`
      submitted to GSC Removals tool. See TASKS.md § G2.

### 🟡 Default `og:image` (social preview card)

Currently no site-wide default. Shared links (iMessage / WhatsApp /
Facebook / Slack previews) will show an empty card.

- [x] Chose [assets/img/featured/DSC_0655.jpg](../assets/img/featured/DSC_0655.jpg)
      — safe landscape from the featured set (no dedicated 1200×630
      crop needed for a memorial site).
- [x] Configured via a `defaults:` block in
      [`_config.yml`](../_config.yml) pointing every page at
      `/assets/img/featured/DSC_0655.jpg`.
- [ ] Optional per-page override via front-matter `image: /path/to.jpg`
      — mechanism in place; not currently used by any page.
- [x] Verified 2026-07-27: all 4 built pages emit
      `<meta property="og:image" content="https://jozefasobkowicz.com/assets/img/featured/DSC_0655.jpg">`.

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

Verified 2026-07-27:

- [x] `_site/sitemap.xml` lists all 4 pages with apex URLs (no `www`,
      matches CNAME).
- [x] `_site/robots.txt` says `Sitemap: https://jozefasobkowicz.com/sitemap.xml`.
- [x] `_site/sitemap-images.xml` exists with 215 `<image:loc>` entries
      (see NON-NEGOTIABLE above).
- [x] Every built page has `<link rel="canonical">` (apex), `<meta
      name="description">` (distinct per page), and `<meta
      property="og:image">` in the head.

---

## Post-cutover procedures

Run these after DNS resolves + HTTPS is enforced. TASKS.md § G2
records what was actually run and when; this section documents *how*.

### Verify canonical host

In a fresh incognito window, request
`https://www.jozefasobkowicz.com/tributes/`. Expected:
HTTP 301 → `https://jozefasobkowicz.com/tributes/`, then the Jekyll
site renders with a valid TLS certificate. If the redirect doesn't
happen, GitHub Pages hasn't seen the CNAME as apex — check
Settings → Pages → Custom domain.

### Submit new sitemaps

Google Search Console → **Sitemaps** → *Add a new sitemap*. Submit
both:

- `https://jozefasobkowicz.com/sitemap.xml` (page URLs — 4 entries)
- `https://jozefasobkowicz.com/sitemap-images.xml` (215 image entries)

Two entries rather than one because our image sitemap is a separate
file (see NON-NEGOTIABLE above for why).

### Remove the old Yoast sitemap

If a Yoast-generated sitemap (e.g. `sitemap_index.xml`) was ever
registered in Search Console, remove it here: **Sitemaps** → find the
old entry → *Remove sitemap*. Once WordPress hosting is cancelled the
URL will 404 and Google will drop it naturally within a few crawl
cycles; manual removal just accelerates.

### Request indexing (new + renamed URLs)

Google Search Console → **URL Inspection** (top search bar) → paste
the full URL → wait for fetch → **Request indexing**. Do this for the
four canonical Jekyll URLs. Suggested order (highest priority first,
so the brand-new URL gets crawled soonest):

1. `https://jozefasobkowicz.com/tributes/` — new URL, replaces the
   retired `/messages-from-loved-ones/`
2. `https://jozefasobkowicz.com/`
3. `https://jozefasobkowicz.com/photos/`
4. `https://jozefasobkowicz.com/about/`

Google throttles to ~10 requests/day per property — 4 URLs is well
within limits.

**Known behavior: `/tributes/` returns "Soft 404" on first-pass URL
Inspection.** Root cause: Giscus renders comments inside a
JavaScript-injected iframe, so Google's first-pass crawler sees
near-empty HTML (intro paragraph + empty `<div class="giscus">`
placeholder). Google's JS-rendering pass runs asynchronously and may
reclassify + index the page days-to-weeks later. See
[Deliberate non-goals](#deliberate-non-goals-things-not-to-add) for
the accept-and-wait decision + exit condition.

### Post-cutover: Removals

Retire indexed URLs that no longer exist on the new site (WordPress-era
pages + NextGEN images). **Tool:** the site-owner **Removals** tool at
[search.google.com/search-console/removals?resource_id=sc-domain%3Ajozefasobkowicz.com](https://search.google.com/search-console/removals?resource_id=sc-domain%3Ajozefasobkowicz.com).
Do NOT use the public [Remove Outdated Content](https://search.google.com/search-console/remove-outdated-content)
tool — that's for non-owners and requires approval; Google's own
callout on that page points site owners at Removals ("faster and
doesn't require approval").

**Inside the tool:** default **Temporary Removals** tab → **New Request**
→ default **Temporarily Remove URL** sub-tab (not *Clear Snippet* —
that just refreshes the cached description without removing the
result). Two request types:

- **Remove this URL only** — hides a single URL for ~6 months.
- **Remove all URLs with this prefix** — hides everything under a
  path prefix for ~6 months (the wildcard option — much better for
  large sets like the NextGEN image tree).

One request covers all URL variations (`http`/`https`, `www`/non-`www`)
— you don't submit separate requests per variant. Google typically
approves site-owner Removals within 24 hours; status flows
*Processing request* → *Approved* → *Complete*.

**URLs to remove for this site:**

1. Single URL: `https://jozefasobkowicz.com/messages-from-loved-ones/`
   — retired WordPress page; replaced by `/tributes/`.
2. Single URL: `https://jozefasobkowicz.com/blog/` — WordPress's other
   entry point for the same content; Yoast's post-sitemap listed both.
3. Prefix: `https://jozefasobkowicz.com/wp-content/` — covers NextGEN
   gallery images (`/wp-content/gallery/*`), WordPress uploads
   (`/wp-content/uploads/*`, including the featured photos Yoast had
   in `page-sitemap.xml`), plus themes/plugins/cache paths. All 404
   on GitHub Pages.

**Don't use this tool for `/`, `/about/`, `/photos/`** — those URLs
still serve real content on the new site. Request Indexing (above) is
the right mechanism for those, which triggers a re-crawl and refreshes
Google's cached snippet naturally.

**Why it's effectively permanent even though the tool is
"temporary":** Removals is a ~6-month hide, but since our old URLs
now return 404 on GitHub Pages, Google's crawler drops them from the
index naturally within that window. So the hide is temporary; the
removal is permanent. No follow-up action needed beyond confirming
each request moves to *Approved*.

### Post-cutover: Verification schedule

Passive calendar checkpoints — do these after the actions above, then
walk away and revisit at the intervals below. TASKS.md § G2 tracks
which have been done.

**~1–2 days after Removals submission:** revisit the Removals tool.
All submitted requests should have moved from *Processing request* →
*Approved*. If any is *Denied*, click through for the reason
(usually URL syntax or a scope mismatch) and resubmit.

**~1 week after cutover:** revisit Search Console **Coverage / Index**.
Confirm:

- The four Jekyll URLs are indexed with current content.
- Retired URLs no longer surface in fresh queries.
- The image sitemap was fetched (Sitemaps → status).

Investigate any surprises — sitemap not fetched, image sitemap
ignored, unexpected 404s on live URLs. Then run an incognito Google
search for *"Jozefa Sobkowicz"* — the top result should be the new
site with the current title + description, not the WordPress snippet.

**~2 weeks after cutover: `/tributes/` Soft 404 re-check.** Re-run
URL Inspection on `https://jozefasobkowicz.com/tributes/`.

- If it now indexes cleanly, Google's JS-rendering pass caught up.
  Nothing more to do.
- If it still shows Soft 404, revisit the accept-and-wait decision in
  [Deliberate non-goals](#deliberate-non-goals-things-not-to-add).
  The fix path: flip `messages_display` in
  [`_config.yml`](../_config.yml) to `both` (adds server-rendered
  tribute list above the widget) or `static` (drops widget entirely,
  cleaner SEO but changes the visitor experience).

---

## Deferred improvements

Four small SEO improvements considered during the pre-cutover
analysis against WordPress + Yoast + NextGEN Gallery. None block
ranking or cutover; user parked them for later consideration. TASKS.md
*Future tweaks* has short pointers back here.

**Full context, exact diffs, and — critically — verbatim samples of
the WordPress state at the time of comparison** (unrecoverable once
WordPress is offline) live in
[docs/godaddy-migration.md § SEO comparison at cutover](godaddy-migration.md#seo-comparison-at-cutover-2026-07-27).
That's the reference doc; this section just summarises.

1. **Alt text on `<img>` tags in `/photos/`** — currently `alt=""` on
   all 215 images; replace with a generic
   `alt="Photograph of Jozefa Sobkowicz"`. Accessibility win, minor
   SEO signal.
2. **`<image:title>` / `<image:caption>` on
   [sitemap-images.xml](../sitemap-images.xml)** entries — WordPress
   had these (populated with filenames); we emit `<image:loc>` only.
3. **Remove duplicate `<title>` and `<meta name="description">`** from
   [_includes/head.html](../_includes/head.html) — jekyll-seo-tag
   already emits both. Cosmetic dedup; both currently render, which
   is harmless but noisy in view-source.
4. **Yoast-equivalent `<meta name="robots">` snippet directives** in
   [_includes/head.html](../_includes/head.html) — exact string
   captured in the migration doc.

If any of these becomes a priority, move it up into the pre-cutover
checklist (or a new "Post-cutover improvements" checklist) with a `[ ]`
box.

---

## Deliberate non-goals (things NOT to add)

- **Server-render the tribute list to solve Giscus Soft 404** —
  observed 2026-07-27: Google's URL Inspection classifies `/tributes/`
  as "Soft 404" on first pass because Giscus renders inside a
  JS-injected iframe, leaving the initial HTML nearly empty (intro
  paragraph + placeholder div). Considered flipping
  `messages_display` in `_config.yml` to `static` (drop the widget,
  server-render tributes from `_data/messages.yml`) or `both`
  (duplicate the content). **Decided to accept** — SEO on
  `/tributes/` isn't critical for a memorial site (visitors find the
  site by name → land on `/` → navigate). Google's JS-rendering pass
  may reclassify + index the page asynchronously; if it hasn't after
  ~2 weeks, revisit and switch modes.
- **HTML redirect stub at `/messages-from-loved-ones/`** — considered;
  rejected (see Decisions above).
- **`schema.org` JSON-LD** — see Decisions above.
- **Sitemap `<lastmod>` / `<priority>`** — see Decisions above.
- **Bing Webmaster Tools / Yandex / other search engines' owner
  consoles** — we DO run the full post-cutover workflow in Google
  Search Console (see TASKS.md § G2). What we're skipping here is the
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
