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
