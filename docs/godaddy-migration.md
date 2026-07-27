# WordPress/GoDaddy → Jekyll migration record

Historical record of the one-time migration of **jozefasobkowicz.com**
from WordPress on GoDaddy shared hosting to a Jekyll static site on
GitHub Pages. Preserved so anyone auditing the site later can see where
each piece of content came from.

**Migrated:** July 2026
**From:** WordPress + NextGEN Gallery on GoDaddy shared hosting
**To:** Jekyll on GitHub Pages (this repo), custom domain preserved

For ongoing operations after the switchover, see:
- [github-runbook.md](github-runbook.md) — repo, Pages, Actions, Giscus
- [dns-runbook.md](dns-runbook.md) — DNS, custom domain, HTTPS, renewal

---

## What was on the WordPress site

- **Home / About** — WordPress pages of prose about Jozefa.
- **Photos** — a NextGEN Gallery of 215 photos (family, portraits, life
  events). Full-size + thumbnail pairs stored under
  `wp-content/gallery/photos/`.
- **Messages** — a page of tribute comments from family and friends,
  plus 600+ moderation-queue spam entries (discarded).

---

## What moved (and how)

### Text
- Home / About text: manually re-typed into [`index.html`](../index.html)
  and [`about.md`](../about.md).
- Tribute messages: transcribed into
  [`_data/messages.yml`](../_data/messages.yml). Polish/Ukrainian
  entries preserved verbatim. Attribution + dates preserved. This file
  is the paste-source for seeding the GitHub Discussion thread — see
  [github-runbook.md § Seed the tribute thread](github-runbook.md#5-seed-the-tribute-thread).

### Photos
- **Source:** downloaded the entire `wp-content/gallery/photos/` folder
  via GoDaddy File Manager as a zip (`photos.zip`, ~710 MB). The zip is
  git-ignored and kept locally as the backup of record.
- **NextGEN quirk:** each image existed as a pair — `NAME.jpg` (a
  smaller display copy created by the plugin) and `NAME.jpg_backup`
  (the original as uploaded, preserved by NextGEN under that suffix).
  The `_backup` file was the higher-quality version and became the
  in-repo original.
- **Result:** 215 unique photos, each written to `originals/<name>.jpg`
  as a byte-clean copy (with `_backup` suffix stripped).
- **Resolution note:** NextGEN's "originals" turned out to be ~1800 px,
  not multi-thousand-pixel scans. If higher-res scans surface later,
  drop them into `originals/` and rerun the derivative script — see
  [README § Adding photos](../README.md#adding-photos).
- **Archive policy:** `originals/` is git-ignored and backed up outside
  git. Full details in [`originals/README.txt`](../originals/README.txt).

#### Extraction procedure (reference)

The zip was sorted into `originals/` by Claude Code (the local CLI agent)
after inspecting the archive's structure and applying the NextGEN quirk
above. If you ever need to redo this from a fresh `photos.zip`, the
essence was:

```bash
# 1. Extract to a scratch directory outside the repo.
SCRATCH=$(mktemp -d -t photos-unzip.XXXXXX)
unzip -q photos.zip -d "$SCRATCH"
# → yields $SCRATCH/photos/ containing pairs like NAME.jpg + NAME.jpg_backup,
#   plus cache/ and thumbs/ subfolders and a few singleton .jpg files.

# 2. For every *.jpg_backup, drop the suffix and copy to originals/.
#    (In this migration every image had a _backup counterpart; there were
#    no singleton plain-jpgs. If there were, they'd be copied as-is.)
for f in "$SCRATCH"/photos/*.jpg_backup; do
  base=$(basename "$f" .jpg_backup)
  cp -n "$f" originals/"$base".jpg
done

# 3. Generate the derivatives that the site actually serves.
./scripts/rebuild-photos.sh
```

Explicitly discarded from the zip:
- `cache/` — regenerable NextGEN cache
- `thumbs/` — NextGEN's thumbnails; we generate our own at 600² from
  the originals
- plain `NAME.jpg` files — NextGEN's downscaled display copies,
  superseded by the higher-quality `_backup` versions

### Custom domain
The `jozefasobkowicz.com` registration stayed at GoDaddy. Only the
WordPress hosting was cancelled. Switchover procedure and ongoing DNS
management: [dns-runbook.md](dns-runbook.md).

---

## What was NOT migrated

- The WordPress database itself (not needed — the site is now static).
- NextGEN Gallery plugin state (categories, ordering metadata).
- Spam comments in the moderation queue.
- WordPress user accounts, plugins, themes.

---

## SEO comparison at cutover (2026-07-27)

Documented for the historical record: how the Jekyll site's SEO
metadata compared to the WordPress site (Yoast SEO + NextGEN Gallery)
at the moment of cutover. Ongoing SEO work — sitemap submission,
outdated-content removal — lives in [seo-runbook.md](seo-runbook.md).

### Executive summary

**Net improvement, not regression, on the fundamentals.** The single
biggest win: WordPress had NO `<meta name="description">` tag on any
page (Yoast couldn't fill it — nobody had set page descriptions in WP
admin, so Google was auto-generating snippets from post excerpts,
including raw HTML entities like `[&hellip;]`). Jekyll has curated,
unique descriptions per page. Similar story for `og:image` — WordPress
had it on `/` only; Jekyll has it on all four pages.

Small cosmetic edges that Yoast provided and we didn't reproduce
(Twitter reading-time badge, robots snippet-size directives,
per-image titles wrapping filenames) are effectively noise for a
memorial site.

### Head-to-head (fetched 2026-07-27)

| Metric | WordPress + Yoast (old) | Jekyll + jekyll-seo-tag (new) |
|---|---|---|
| `<meta name="description">` | ❌ Absent on all pages | ✅ Present, curated, unique per page (54–127 chars) |
| `og:description` | ⚠️ On 3/5 pages; content auto-generated from excerpts | ✅ On all 4 pages; matches curated description |
| `og:image` | ⚠️ On `/` only | ✅ On all 4 pages (default: `DSC_0655.jpg`) |
| JSON-LD structured data | ⚠️ Rich schema graph but `description: ""` (empty) | ✅ Compact WebPage schema with description, image, url |
| `<meta name="robots">` snippet directives | ✅ `max-snippet:-1, max-image-preview:large, max-video-preview:-1` | ❌ Not emitted (Google uses defaults) |
| Twitter reading-time meta | ✅ Present | ❌ Not emitted |
| Canonical URL host | www.jozefasobkowicz.com | apex `jozefasobkowicz.com` (matches CNAME) |
| Duplicate `<title>` / `<meta description>` tags | 1 each | 2 each (head.html + jekyll-seo-tag both emit) |

### Sitemap comparison

**WordPress (Yoast):** `sitemap_index.xml` → 4 sub-sitemaps
(`post-sitemap.xml`, `page-sitemap.xml`, `ngg_tag-sitemap.xml`,
`author-sitemap.xml`). The page-level image data lived inline in
`page-sitemap.xml`, wrapped in each page's `<url>` entry:

- **219 `<image:image>`** entries total.
- Metadata per image: `<image:loc>` + `<image:title>` + `<image:caption>`
  — but title and caption are just the **filenames** (`scan0013`,
  `march-2021`, `scan0029_edited`), NOT human-readable descriptions.
- The 4 home-page featured images had `<image:loc>` only (no title).

**Jekyll:** `sitemap.xml` (jekyll-sitemap auto-gen, 4 page URLs) +
`sitemap-images.xml` (custom template, dynamic):

- **215 `<image:loc>`** entries under the `/photos/` URL entry.
- No `<image:title>` / `<image:caption>` — parity gap vs. Yoast, but a
  low-value one since Yoast's were just filenames.

### Per-image HTML rendering on `/photos/`

- **WordPress:** 35 `<img>` tags in HTML; the remaining ~180 photos
  paginate in via NextGEN JS. Alt/title attributes limited to NextGEN's
  defaults.
- **Jekyll:** all **215** `<img>` tags emitted at once (no
  pagination), `loading="lazy"` for browser-level defer. `alt=""` on
  every image — technically empty. **This is a parity gap** — see
  potential improvements below.

### Potential improvements (deferred, low-priority)

Captured for future maintenance; none block the cutover, none change
Google's ranking meaningfully. If any becomes a priority, promote to
[seo-runbook.md](seo-runbook.md) as an active checklist item.

Each item below includes what parity with the old WordPress site
looked like — needed because once WordPress is offline, that reference
state is unrecoverable.

1. **Alt text on `<img>` tags in `/photos/`** — currently `alt=""`
   (215 tags, all empty). Add a generic-but-honest placeholder via
   the existing Liquid loop in [photos.html](../photos.html):
   ```liquid
   <img src="..." alt="Photograph of Jozefa Sobkowicz" loading="lazy">
   ```
   *WordPress parity:* NextGEN emitted `<img>` tags whose alt/title
   were derived from the original filename (e.g. `alt="scan0013"`) —
   equally uninformative but non-empty. A generic "Photograph of
   Jozefa Sobkowicz" is more accessible than either.
2. **`<image:title>` / `<image:caption>` on
   [sitemap-images.xml](../sitemap-images.xml)** — currently emits
   `<image:loc>` only. Wrap each entry:
   ```xml
   <image:image>
     <image:loc>{{ photo.path | absolute_url }}</image:loc>
     <image:title>Photograph of Jozefa Sobkowicz</image:title>
     <image:caption>Photograph of Jozefa Sobkowicz</image:caption>
   </image:image>
   ```
   *WordPress parity:* Yoast's page-sitemap.xml included the same two
   tags but populated them with the filename (see sample below —
   `<image:title><![CDATA[scan0029_edited]]></image:title>`). Our
   generic label is at least as informative and consistent across
   entries.
3. **Remove duplicate `<title>` and `<meta name="description">`** by
   dropping the manual ones in
   [_includes/head.html](../_includes/head.html) and letting
   jekyll-seo-tag emit them alone. The manual tags to remove:
   ```html
   <title>{% if page.title %}{{ page.title }} — {{ site.title }}{% else %}{{ site.title }}{% endif %}</title>
   <meta name="description" content="{{ page.description | default: site.description }}">
   ```
   jekyll-seo-tag's `{% seo %}` invocation already emits both. Current
   result: 2 title tags and 2 description tags per page — cosmetically
   ugly, functionally harmless (browsers use the first `<title>`,
   Google usually the first `<meta name="description">`).
4. **Yoast-equivalent `<meta name="robots">`** in
   [_includes/head.html](../_includes/head.html) — verbatim from
   what Yoast emitted:
   ```html
   <meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1">
   ```
   Tells Google to allow arbitrarily long snippets and large image
   previews in SERPs. jekyll-seo-tag intentionally doesn't emit this
   (Google's defaults are conservative).

### Raw samples captured (2026-07-27)

Pinned here because once WordPress is offline, none of this is
reproducible. Preserved verbatim from live-fetch on the date above,
so the improvements above can be validated later without needing the
old site.

**WordPress `sitemap_index.xml` top-level:**
```xml
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>http://www.jozefasobkowicz.com/post-sitemap.xml</loc>
    <lastmod>2020-08-13T23:39:28+00:00</lastmod>
  </sitemap>
  <sitemap>
    <loc>http://www.jozefasobkowicz.com/page-sitemap.xml</loc>
    <lastmod>2021-02-25T15:12:29+00:00</lastmod>
  </sitemap>
  <sitemap>
    <loc>http://www.jozefasobkowicz.com/ngg_tag-sitemap.xml</loc>
  </sitemap>
  <sitemap>
    <loc>http://www.jozefasobkowicz.com/author-sitemap.xml</loc>
    <lastmod>2020-08-13T14:37:30+00:00</lastmod>
  </sitemap>
</sitemapindex>
```

**Sample entries from `page-sitemap.xml`** — image structure used by
Yoast/NextGEN. Note the filename-only titles/captions:
```xml
<url>
  <loc>https://www.jozefasobkowicz.com/</loc>
  <lastmod>2020-09-02T13:48:42+00:00</lastmod>
  <image:image>
    <image:loc>http://www.jozefasobkowicz.com/wp-content/uploads/2020/08/DSC_0655.jpg</image:loc>
  </image:image>
  <image:image>
    <image:loc>http://www.jozefasobkowicz.com/wp-content/uploads/2020/08/scan0033.jpg</image:loc>
  </image:image>
  <!-- 2 more featured images, no title/caption on home page -->
</url>
<url>
  <loc>https://www.jozefasobkowicz.com/photos/</loc>
  <lastmod>2021-02-25T15:12:29+00:00</lastmod>
  <image:image>
    <image:loc>https://www.jozefasobkowicz.com/wp-content/gallery/photos/scan0029_edited.jpg</image:loc>
    <image:title><![CDATA[scan0029_edited]]></image:title>
    <image:caption><![CDATA[scan0029_edited]]></image:caption>
  </image:image>
  <!-- ~215 more gallery photos in the same structure -->
</url>
```

**Yoast's per-page `<meta name="robots">` directive** (verbatim from
all crawled pages):
```html
<meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1" />
```

**Yoast's JSON-LD schema graph** (structure sample from `/`):
```json
{
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "WebSite",  "@id": ".../#website",  "url": "...", "name": "Jozefa Sobkowicz", "description": "", "potentialAction": [...] },
    { "@type": "ImageObject", "@id": ".../#primaryimage", "url": "http://.../wp-content/uploads/2020/08/DSC_0655-1024x683.jpg" },
    { "@type": "WebPage", "@id": ".../#webpage", "url": "...", "name": "Home - Jozefa Sobkowicz", "isPartOf": {...} }
  ]
}
```
Note the empty `description: ""` on the WebSite node — the WordPress
site owner had never set a description in Yoast, so Google was
generating snippets from the page body content.

**Yoast Twitter reading-time metadata** (present on content pages):
```html
<meta name="twitter:label1" content="Est. reading time" />
<meta name="twitter:data1" content="1 minute" />
```

**Old URLs that will 404 after cutover** — confirmed live at time of
capture:
- `https://www.jozefasobkowicz.com/blog/` (HTTP 200)
- `https://www.jozefasobkowicz.com/messages-from-loved-ones/` (HTTP 200)
- `https://www.jozefasobkowicz.com/wp-content/gallery/photos/*.jpg` (many)
- `https://www.jozefasobkowicz.com/wp-content/uploads/2020/08/*.jpg` (multiple)

Removal via GSC after cutover — see
[seo-runbook.md](seo-runbook.md) + DEVIATION § E2.

---

## Backup artifacts to preserve

Keep these outside the repo indefinitely — they're the migration's
archaeological record and are not reproducible from the current site:

- **`photos.zip`** — the raw NextGEN gallery dump. The `_backup` files
  in it are the actual source; the rest (`cache/`, `thumbs/`, plain
  `.jpg`) is regenerable or noise.
- **WordPress WXR XML export** — `Tools → Export → All content` in
  WordPress. Plain XML of every page/post text. Safety copy in case
  any text didn't make it into the Jekyll site.
- **GoDaddy account backup** — the full site + database backup taken
  before cancelling hosting.

Recommended storage: an external drive AND a cloud folder (iCloud /
Drive / Backblaze / whatever). Redundant on purpose. Losing these means
the migration is irreversible.

---

## Why the move

- WordPress on shared hosting was over-engineered for four largely
  static pages + a photo gallery.
- Ongoing hosting cost, security patching, plugin maintenance, and
  spam moderation weren't sustainable for a memorial that should just
  quietly exist.
- Jekyll on GitHub Pages: free, effectively zero maintenance, content
  is plain text in a versioned repo, gallery is regenerable from
  originals.
- Tributes moved to GitHub Discussions (Giscus) — durable, lockable,
  no server-side spam to moderate.

---

## Undo (theoretical)

You can't restore the WordPress site from this repo alone. The GoDaddy
account backup + `photos.zip` above are the only path back. Restore
them to any WordPress host (not necessarily GoDaddy). Keep those
backups accordingly.
