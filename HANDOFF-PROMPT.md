# Handoff prompt — paste this into your local Claude Code agent

Hand the block below to Claude Code (running in this repo on your NixOS machine).
It has network access, your filesystem, and git, which the environment that
scaffolded this site did not.

---

You are helping me finish migrating my grandmother's memorial site,
**jozefasobkowicz.com**, from WordPress/GoDaddy to this Jekyll + GitHub Pages
repository. The scaffold is already built (layouts, CSS, pages, and all tribute
text in `_data/messages.yml`). Your job is the network- and machine-dependent
work. I'm on NixOS. Read `README.md` first, then work through the tasks below,
pausing for my confirmation before anything destructive or anything needing my
credentials.

**Context you need**
- Sections: Home (`index.html`), About (`about.md`), Photos (`photos.html`),
  Messages (`blog.html`).
- Photos use a three-tier model. NEVER modify originals in place:
  - `originals/`                  full-resolution scans, kept verbatim (archive; git-tracked but excluded from the built site)
  - `assets/img/photos/full/`     display copies for the lightbox (~2560px), served
  - `assets/img/photos/thumbs/`   grid thumbnails (~600px square), served
  Home featured images come from `assets/img/featured/`.
- The old photos live on the WordPress server at
  `https://www.jozefasobkowicz.com/wp-content/gallery/photos/` (full) and
  `.../thumbs/thumbs_*.jpg`, across ~7 gallery pages.
- Messages: `messages_display` in `_config.yml` is `giscus`. The tributes will
  live in a locked GitHub Discussion on THIS repo, seeded from my account. The
  curated text in `_data/messages.yml` is the paste-source and a backup.

**Tasks**

1. **Local build.** Enter the Nix dev shell (`nix develop`), run `bundle install`,
   then `bundle exec jekyll serve`. Confirm all four pages build with no errors.
   Fix any Liquid/Gemfile issues you hit on NixOS (the Gemfile pins the sassc
   converter and the flake forces native gems).

2. **Download the photos as ORIGINALS.** Collect every image from the WordPress
   gallery and save the untouched full-size files into `originals/`. Try, in order:
   (a) SFTP / GoDaddy File Manager if I give credentials, or (b) walk gallery pages
   1–7, collect filenames, and fetch each full image with `wget`/`curl`. Do NOT
   re-encode or resize these — they are the archive. Report the total size of
   `originals/` when done.

3. **Generate served derivatives (non-destructive).** From `originals/`, create
   display copies and thumbnails WITHOUT altering the originals. Use ImageMagick
   (`nix run nixpkgs#imagemagick -- ...` or add it to the flake). For each file:
   - full:  resize to fit 2560x2560, quality ~88 → `assets/img/photos/full/<name>.jpg`
   - thumb: crop to a 600x600 square, quality ~80 → `assets/img/photos/thumbs/thumbs_<name>.jpg`
   Example (adapt/loop safely; read from originals, write to the derivative dirs):
     magick originals/NAME.jpg -auto-orient -resize '2560x2560>' -quality 88 assets/img/photos/full/NAME.jpg
     magick originals/NAME.jpg -auto-orient -resize '600x600^' -gravity center -extent 600x600 -quality 80 assets/img/photos/thumbs/thumbs_NAME.jpg
   Report total sizes for `full/` and `thumbs/`. The lightbox serves `full/`, so
   these should look excellent; nudge quality up if I ask.

4. **Featured photos.** Copy these four originals' DERIVATIVES (or make fresh
   2560px copies) into `assets/img/featured/` — they were the home-page slideshow:
   `DSC_0655`, `scan0033`, `scan0022_edited`, `DSC_0802`. If any are missing, pick
   four good portraits and tell me.

5. **Decide where originals live.** Once you report the `originals/` total:
   - If it's comfortably under ~1 GB and I want one versioned source of truth,
     keep `originals/` committed (it's already excluded from the built site).
   - If it's large, or I say so, move `originals/` OUT of the repo to object
     storage — AWS S3 or Cloudflare R2 (R2 has no egress fees) — and add it to
     `.gitignore`. Do NOT use Git LFS; GitHub Pages cannot serve LFS files.

6. **Seed the Messages thread (Giscus) on THIS repo — no second repo needed.**
   - Make the repo public, then enable **Settings → Discussions**.
   - Install the Giscus app (https://github.com/apps/giscus) for the repo.
   - At https://giscus.app, select the repo + a category, and copy `repo`,
     `repo_id`, `category`, `category_id` into the `giscus:` block in `_config.yml`.
   - Deploy (task 7) or run locally, open `/blog/`, and post each tribute from
     `_data/messages.yml` as a separate comment FROM MY ACCOUNT. Preserve
     attribution by starting each comment with a bold header, then the message,
     then any translation as a quote. Template:
       **Dianne Parwicki — Family friend, Etobicoke · March 4, 2019**

       Dear Bozena and family, ...
   - Proofread the Polish/Ukrainian entries against the live site as you go.
   - When all are posted, **lock the Discussion** in GitHub to disable new posts.
     The email invite at the top of `/blog/` directs future contributors to me.

7. **Publish.** Help me create the **public** GitHub repo, push `main`, and set
   **Settings → Pages → Source: GitHub Actions**. Confirm the Actions build passes
   and the site is live at the temporary `*.github.io` URL. Do NOT touch DNS yet.

8. **Custom domain (only when I confirm the temp site looks right).** Walk me
   through the GoDaddy DNS changes in `README.md` (four apex `A` records + `www`
   CNAME), verify propagation, then enable **Enforce HTTPS**. Keep the domain
   registration; only cancel the GoDaddy **hosting** after the new site resolves.
   Confirm I have a local copy of any `@jozefasobkowicz.com` email first.

Work incrementally, keep commits small and descriptive, and run the local server
to visually check each change. Ask before anything irreversible.
