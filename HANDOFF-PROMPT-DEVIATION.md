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

### C. Seed and lock the tribute thread (original Task 6 cont'd)

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
      https://v2.jozefasobkowicz.com/tributes/ (or the final URL, once
      cut over), one comment per block, 18 total.
- [ ] 👤 Proofread AI translations in
      [_data/messages.yml](_data/messages.yml) — see the Translation
      Review Notes in the file's header comment. Edits made there
      propagate to future runs of the paste-blocks script; refinements
      to already-posted Giscus comments have to be applied directly on
      GitHub.
- [ ] 👤 **Lock the Discussion** thread once all tributes are posted.
      This is the intended steady state for phase 1 (see
      [runbook § 6](docs/github-runbook.md#6-lock-the-discussion)).

### D. Custom domain + DNS (original Task 8)

Canonical: [dns-runbook.md](docs/dns-runbook.md). Do this only after
the temp `*.github.io` site looks right.

- [ ] 👤 Pre-flight ([dns-runbook § 1](docs/dns-runbook.md#1-pre-flight)):
      confirm current GitHub Pages A-record IPs, back up any
      `@jozefasobkowicz.com` email you want to keep, verify
      [CNAME](CNAME) is `jozefasobkowicz.com`.
- [ ] 👤 **Settings → Pages → Custom domain:** confirm
      `jozefasobkowicz.com` is set (auto-populated on first Pages
      deploy from [CNAME](CNAME)).
- [ ] 👤 In GoDaddy DNS, replace apex records with the four GitHub
      Pages A records + `www` CNAME →
      [dns-runbook § 3](docs/dns-runbook.md#3-configure-godaddy-dns-records).
- [ ] 👤 Wait for propagation; verify with `dig`.
- [ ] 👤 **Settings → Pages → Enforce HTTPS:** tick (after cert issues).
- [ ] 👤 Cancel GoDaddy **hosting** — keep the **domain registration**.
      Decide on email hosting first ([dns-runbook § Email hosting](docs/dns-runbook.md#email-hosting-jozefasobkowiczcom)).

---

## End-of-migration cleanup

Once everything above is checked off:

- [ ] 👤 Decide on `HANDOFF-PROMPT.md` at repo root — keep, gitignore,
      or delete. Currently tracked, kept as history.
- [ ] 👤 Delete this file (`HANDOFF-PROMPT-DEVIATION.md`). Its purpose
      ends here.
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
- [ ] 👤 (Optional) Revoke the **Giscus OAuth authorization** you
      granted during seeding — visit
      [github.com/settings/apps/authorizations](https://github.com/settings/apps/authorizations),
      find *Giscus*, click **Revoke**. Purely cosmetic on your
      "authorized apps" list; the locked discussion keeps working
      either way. See
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
