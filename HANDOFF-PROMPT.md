# Handoff prompt — paste this into your local Claude Code agent

You can hand the block below to Claude Code (running in this repo on your NixOS
machine). It has network access, your filesystem, and git, which the environment
that scaffolded this site did not.

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
  Messages (`blog.html`, data in `_data/messages.yml`).
- The gallery auto-builds from `assets/img/photos/full/` with optional matching
  `thumbs_*.jpg` in `assets/img/photos/thumbs/`. Home featured images come from
  `assets/img/featured/`.
- The old photos live on the WordPress server at
  `https://www.jozefasobkowicz.com/wp-content/gallery/photos/` (full) and
  `.../thumbs/thumbs_*.jpg` (thumbnails), spread across ~7 gallery pages.
- Comments: `messages_display` in `_config.yml` is `static` for now. I may switch
  to Giscus later.

**Tasks**

1. **Local build.** Enter the Nix dev shell (`nix develop`), run `bundle install`,
   then `bundle exec jekyll serve`. Confirm the site builds with no errors and all
   four pages render. Fix any Liquid/Gemfile issues you hit on NixOS (the Gemfile
   already pins the sassc converter and the flake forces native gems).

2. **Get the photos.** Download every image from the WordPress gallery. Try, in
   order: (a) SFTP/File Manager if I give you credentials, or (b) mirror the public
   URLs with `wget`/`curl` by walking the gallery pages 1–7 to collect filenames,
   then fetching both the full image and its `thumbs_` counterpart. Ask me for
   whatever you need. Save full images to `assets/img/photos/full/` and thumbnails
   to `assets/img/photos/thumbs/`.

3. **Optimise.** The full-size files are scans and may be large. Downscale to a
   sane max dimension and re-compress to keep the repo lean, e.g. with ImageMagick:
   `mogrify -resize '1600x1600>' -quality 82 assets/img/photos/full/*.jpg`
   (add `imagemagick` to the dev shell or run via `nix run nixpkgs#imagemagick`).
   Keep thumbnails small. Show me before/after total size.

4. **Featured photos.** Copy these four into `assets/img/featured/` (they were the
   home-page slideshow): `DSC_0655.jpg`, `scan0033.jpg`, `scan0022_edited.jpg`,
   `DSC_0802.jpg`. If any are missing, pick four good portraits and tell me.

5. **Proofread.** Open the Messages page and check the Polish and Ukrainian entries
   in `_data/messages.yml` against the live site
   (https://www.jozefasobkowicz.com/blog/). Flag anything that looks off; don't
   silently rewrite meaning.

6. **Publish.** Help me create a **public** GitHub repo, push `main`, and set
   **Settings → Pages → Source: GitHub Actions**. Confirm the Actions build passes
   and the site is live at the temporary `*.github.io` URL. Do NOT touch DNS yet.

7. **Custom domain (only when I say the temp site looks right).** Walk me through
   the GoDaddy DNS changes in `README.md` (four apex `A` records + `www` CNAME),
   verify propagation, then enabling **Enforce HTTPS**. Remind me to keep the
   domain registration and only cancel the GoDaddy **hosting** after the new site
   resolves. Confirm I have a local copy of any `@jozefasobkowicz.com` email before
   that.

8. **(Optional) Giscus.** If I decide I want a live comment thread, walk me through
   enabling Discussions, installing the Giscus app, filling the `giscus:` block in
   `_config.yml`, setting `messages_display`, seeding comments, and locking the
   discussion to prevent spam.

Work incrementally, keep commits small and descriptive, and run the local server
to visually check each change. Ask before anything irreversible.
