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

- [ ] 👤 Create a **public** repo on github.com. Do NOT initialize with
      README/.gitignore/license — we have all three.
- [ ] 👤 Locally: `git branch -m master main`, `git remote add origin …`,
      `git push -u origin main`.
- [ ] 👤 **Settings → Pages → Source: GitHub Actions.**
- [ ] 👤 Watch the **Actions** tab; first build takes 1–2 min.
- [ ] 👤 Walk the temp `*.github.io` URL: `/`, `/about/`, `/photos/`,
      `/blog/` all render. `/blog/` will show the Giscus placeholder —
      expected.

### B. Enable Discussions + wire up Giscus (original Task 6)

Canonical: [github-runbook.md § 3–4](docs/github-runbook.md#3-enable-discussions).

- [ ] 👤 **Settings → General → Features → Discussions:** enable.
- [ ] 👤 Create a category — recommended: **Tributes**, format
      **Announcement**.
- [ ] 👤 Install the Giscus app: https://github.com/apps/giscus →
      grant access to this repo only.
- [ ] 👤 At https://giscus.app, configure repo + category (mapping =
      pathname) and copy the four values: `repo`, `repo_id`, `category`,
      `category_id`.
- [ ] 🤖 Paste those four values into [_config.yml](_config.yml)'s
      `giscus:` block; commit + push. Actions redeploys.
- [ ] 👤 Reload `/blog/` — the Giscus widget replaces the placeholder.

### C. Seed and lock the tribute thread (original Task 6 cont'd)

Canonical: [github-runbook.md § 5–6](docs/github-runbook.md#5-seed-the-tribute-thread).

- [ ] 👤 Logged in as the repo owner, post each entry from
      [_data/messages.yml](_data/messages.yml) as a separate comment
      via the Giscus composer. Use the bold-header attribution format
      (see runbook).
- [ ] 👤 (Optional pre-work I can do) — I can pre-format the tributes
      into paste-ready blocks so seeding is copy-paste, not
      re-type-and-format. Say the word.
- [ ] 👤 Proofread Polish/Ukrainian entries against `_data/messages.yml`.
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
