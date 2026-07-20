# Jozefa Sobkowicz — memorial site (Jekyll)

A static rebuild of jozefasobkowicz.com, moving off WordPress/GoDaddy onto
Jekyll + GitHub Pages. Four sections: **Home**, **About**, **Photos**, **Messages**.

---

## Quick start (NixOS)

```bash
nix develop            # enters the dev shell (Ruby + build tools)
bundle install         # first time only; installs Jekyll into ./vendor
bundle exec jekyll serve --livereload
# open http://localhost:4000
```

If you use direnv, `direnv allow` will auto-load the same shell via `.envrc`.

---

## Where things live

| You want to change…      | Edit…                                             |
|--------------------------|---------------------------------------------------|
| Her name, dates, email   | `_config.yml`                                     |
| The About text           | `about.md`                                        |
| The tribute messages     | `_data/messages.yml`                              |
| Home-page featured photos | drop 4 images in `assets/img/featured/`          |
| The photo gallery         | drop images in `assets/img/photos/full/` (+ `thumbs/`) |
| Colours / fonts / layout | `assets/css/style.css`                            |

The gallery and featured grids build themselves from whatever image files are in
those folders — no list to maintain.

---

## Getting your content off WordPress

### 1. Back everything up first
In GoDaddy, take a full backup (files + database) **before** cancelling hosting.
Also, in WordPress: **Tools → Export → All content** to download the WXR `.xml`
(this holds your pages/posts text as a safety copy). Do not cancel hosting until
the new site is live and verified.

### 2. The photos (the important part)
Your gallery is the NextGEN Gallery plugin. The images live on the server at:

- Full size: `/wp-content/gallery/photos/*.jpg`
- Thumbnails: `/wp-content/gallery/photos/thumbs/thumbs_*.jpg`

Get them via **SFTP / GoDaddy File Manager** (most reliable): download the whole
`wp-content/gallery/photos/` folder. Save the untouched full-size files into
`originals/` (your archive — see "Images" below), then generate served copies
into `assets/img/photos/full/` and `assets/img/photos/thumbs/`. The handoff
prompt has the exact, non-destructive commands.

### 3. The text
The About page and all tribute messages have already been transcribed into this
repo (`about.md`, `_data/messages.yml`). Proofread the Polish/Ukrainian entries
against the original once.

---

## Messages (Giscus)

`messages_display` in `_config.yml` is set to `giscus`. The tributes live in a
GitHub **Discussion on this same repository** (no second repo needed), seeded
from your account and then locked so no new comments can be posted. Setup:

1. Make the repo **public**, then enable **Settings → Discussions**.
2. Install the Giscus app: https://github.com/apps/giscus
3. At https://giscus.app, enter the repo, pick a category, and copy the `repo`,
   `repo_id`, `category`, and `category_id` values into the `giscus:` block in
   `_config.yml`.
4. Open `/blog/`, and post each tribute from `_data/messages.yml` as a comment.
   Start each with a bold attribution line so the sender is credited even though
   the comment is from your account, e.g.:

   > **Dianne Parwicki — Family friend, Etobicoke · March 4, 2019**
   >
   > Dear Bozena and family, ...

5. When all are posted, **lock the Discussion** in GitHub. Comments stay visible;
   new posting is disabled. The email invite at the top of `/blog/` points future
   contributors to you.

`_data/messages.yml` stays in the repo as your paste-source and a text backup.
(If you ever want the built-in static list back, set `messages_display: static`.)

---

## Images: quality, sizes, storage, limits

Two separate things — don't conflate them:

- **Originals** (`originals/`) — full-resolution scans kept **byte-for-byte**,
  never re-encoded. This is your quality-at-rest archive. It's git-tracked for
  backup but **excluded from the built site** (see `exclude:` in `_config.yml`),
  so it never counts toward the served-site limit or gets sent to visitors.
- **Derivatives** (`assets/img/photos/`) — the copies the site serves:
  `full/` (~2560px, for the lightbox) and `thumbs/` (~600px squares, for the
  grid). Sharp on any screen, fast to load.

**GitHub limits (confirmed):** a published Pages site must be **≤ 1 GB**; source
repos have a **recommended 1 GB** soft limit; bandwidth is a soft **100 GB/month**;
individual files are capped at **100 MB**. Optimized derivatives for ~200 photos
sit far under these. Originals only affect repo size (soft), not the served site.

**Do not use Git LFS** for images here — GitHub Pages cannot serve LFS files (it
returns the pointer, not the image).

**Object storage (future).** GitHub has no general object-store/CDN product for
this. If the archive grows or you want lossless display without the 1 GB Pages
ceiling, move images to **AWS S3** or **Cloudflare R2** (R2 has no egress fees).
Then set `photos_base_url` in `_config.yml` and switch the gallery from folder-
scanning to a small `_data/photos.yml` manifest listing filenames + captions.
Nothing in the current setup blocks this move.

---

## Deploying to GitHub Pages

1. Push this repo to GitHub (branch `main`), repo **public**.
2. **Settings → Pages → Build and deployment → Source: GitHub Actions.**
3. The included workflow (`.github/workflows/jekyll.yml`) builds and deploys on
   every push. Watch progress under the **Actions** tab.

## Custom domain (do this last, after the site works)

1. **Settings → Pages → Custom domain:** enter `jozefasobkowicz.com`, Save.
   (The `CNAME` file in this repo already sets this too.)
2. In **GoDaddy DNS**, point the domain at GitHub Pages:
   - Four `A` records for the apex `@` →
     `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - One `CNAME` for `www` → `<your-github-username>.github.io`
3. Back in **Settings → Pages**, tick **Enforce HTTPS** once the certificate is
   issued (can take up to a few hours).
4. Only after the new site resolves correctly, cancel the GoDaddy **hosting**
   plan. Keep the **domain registration**.

> Note: GitHub Pages IP addresses can change over time — confirm the current apex
> `A` records in GitHub's Pages docs before editing DNS.
