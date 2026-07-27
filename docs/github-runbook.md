# GitHub runbook — jozefasobkowicz.com

Everything that lives on **github.com** for this site: the repo, GitHub Pages,
Discussions, the Giscus comment app, and the Actions build. This is the
durable record for state that isn't in source control — so a future maintainer
(or you, six months from now) can rebuild or audit without guessing.

**Scope:** GitHub only. DNS records (GoDaddy), the domain registration, and
`@jozefasobkowicz.com` email hosting are separate concerns — see
[dns-runbook.md](dns-runbook.md).

As you complete each step below, fill in the **Recorded values** blanks so
this doc becomes an as-built record, not just a plan.

---

## Prerequisites

- A GitHub account that will own the repo. The Discussion tributes are seeded
  from this account, and the Giscus app is installed under it. **Do not lose
  access to this account.**
- Local clone with a working `nix develop` shell; `bundle exec jekyll build`
  passes cleanly.
- SSH key or personal access token configured for pushing to GitHub.

**Recorded values:**
- GitHub username / org: __________________________________________
- Repo name: _____________________________________________________
- Repo URL: ______________________________________________________

---

## 1. Create the public repo and push

1. On https://github.com → **New repository**.
   - **Owner:** the account above.
   - **Name:** e.g. `jozefasobkowicz` (this becomes part of the temporary
     `*.github.io` URL until the custom domain is live).
   - **Visibility: Public.** Required for GitHub Pages on the free plan and
     for Giscus to fetch the discussion.
   - Do **not** initialize with README / .gitignore / license — this repo
     already has all three.
2. The local branch is currently `master`; GitHub's default is `main`. Rename
   before pushing so they line up:
   ```bash
   git branch -m master main
   git remote add origin git@github.com:<owner>/<repo>.git
   git push -u origin main
   ```

**Verification:**
- [ ] Repo is visible at `https://github.com/<owner>/<repo>`
- [ ] Default branch is `main`
- [ ] All commits pushed (compare `git log` locally vs. the repo page)

---

## 2. Enable Pages via GitHub Actions

1. **Settings → Pages**
2. **Build and deployment → Source: GitHub Actions.**
   Do **not** pick "Deploy from a branch" — the included
   [.github/workflows/jekyll.yml](../.github/workflows/jekyll.yml) is the
   canonical build.
3. The workflow triggers on push. First run takes ~1–2 minutes; watch the
   **Actions** tab for green.
4. Once green, the temp site is at:
   - `https://<owner>.github.io/<repo>/` (project site), or
   - `https://<owner>.github.io/` (only if the repo is named
     `<owner>.github.io`).

**Verification:**
- [ ] Actions build passes
- [ ] Temp URL loads all four pages: `/`, `/about/`, `/photos/`, `/tributes/`
- [ ] Photos gallery grid shows all images (currently 215)
- [ ] Home page featured slideshow shows 4 images
- [ ] `/tributes/` renders the Giscus placeholder message (Giscus not configured yet — that's Step 4)

**Recorded values:**
- Temp URL: ______________________________________________________

---

## 3. Enable Discussions

1. **Settings → General → Features → Discussions:** tick to enable.
2. Under the top-nav **Discussions** tab, create a category for tributes:
   - **Name:** `Tributes` (or your preference)
   - **Format:** `Announcement` — only maintainers can start new threads,
     which is what we want. (Alternatively `General` if you'd rather rely on
     manual per-thread locking.)
3. Optional: create a single pinned thread inside the category (e.g. "In
   memory of Jozefa") that the site will map every `/tributes/` visit to via
   Giscus's pathname mapping. Or let Giscus lazily create it on first visit.

**Recorded values:**
- Category name: _________________________________________________
- Category format (Announcement / General): _____________________

---

## 4. Install Giscus and wire it up

1. Install the Giscus app: https://github.com/apps/giscus →
   **Configure → Only select repositories → pick this repo.**
2. Go to https://giscus.app and fill in:
   - Repository: `<owner>/<repo>`
   - Page ↔ Discussions Mapping: **pathname**
   - Discussion Category: the one created in Step 3
   - Features: **turn reactions OFF** — a memorial page reads better
     without an emoji-picker header above the tributes.
   - Theme: doesn't matter here — `_config.yml` sets it
3. From the generated `<script>` block, copy four values:
   `data-repo`, `data-repo-id`, `data-category`, `data-category-id`.
4. Paste into [_config.yml](../_config.yml)'s `giscus:` block. The four
   values below are examples; the other three settings
   (`reactions_enabled`, `theme`, `input_position`) are the deliberate
   memorial-site choices for this repo — see the [CLAUDE.md
   Decisions section](../CLAUDE.md#decisions-already-made--dont-re-litigate)
   for reasoning:
   ```yaml
   giscus:
     repo: "<owner>/<repo>"
     repo_id: "R_kg..."
     category: "Tributes"
     category_id: "DIC_kw..."
     mapping: "pathname"
     reactions_enabled: "0"           # hide emoji reactions row
     theme: "preferred_color_scheme"  # auto light/dark from visitor OS
     input_position: "bottom"         # composer below the tribute list
     lang: "en"
   ```
5. Commit + push. Wait for Actions to redeploy (~1–2 min). Reload `/tributes/` —
   the widget should render (empty until Step 5).

**Verification:**
- [ ] Giscus widget appears on `/tributes/`, not the placeholder
- [ ] Widget shows "0 comments" and a signed-in composer (when logged in)

**Recorded values:**
- `repo_id`: _____________________________________________________
- `category_id`: _________________________________________________

---

## 5. Seed the tribute thread

While logged into GitHub as the owner account, open the deployed `/tributes/`
and, via the Giscus composer, post each entry from
[_data/messages.yml](../_data/messages.yml) as a **separate comment**.

For a copy-paste-ready rendering (attribution header + body + translation
blockquote already formatted, sorted chronologically), from the repo root
inside `nix develop`:

```bash
./scripts/print-paste-blocks.rb > staged_messages.md   # git-ignored
```

Open the file, copy the content INSIDE each fenced code block, paste into
the composer, click *Comment*, repeat. This is the standard seeding path.
The script is a pure read of `_data/messages.yml` — safe to re-run at any
time (see [Managing tributes](../README.md#managing-tributes) in the
README).

The first time you click **Sign in with GitHub** in the composer,
GitHub prompts you to authorize Giscus with three permissions:

- **Verify your GitHub identity**
- **Know what resources you can access**
- **Act on your behalf** — needed so comments are posted as *you*
  (with your avatar and name) rather than as a generic Giscus bot.
  This is the only way to preserve per-user attribution.

Giscus's actions are bounded by the App installation from Step 4:
Discussions read/write on this repo only — no code, no settings,
nothing outside this repo. The grant is visible at
[github.com/settings/apps/authorizations](https://github.com/settings/apps/authorizations)
and revocable any time (see
[Optional: revoke your Giscus OAuth grant](#optional-revoke-your-giscus-oauth-grant)).
Preserve attribution — Giscus attributes every comment to your account, so
start each one with a bold header:

```
**<Name> — <Role/Location> · <Date>**

<message body>
```

For entries that include a translation:

```
> **English translation:**
> <translation body>
```

Proofread the Polish/Ukrainian entries once against `_data/messages.yml`.

`_data/messages.yml` stays in the repo as the paste-source and a text backup;
it's not displayed while `messages_display: giscus`, but it's the archive.

**Verification:**
- [ ] Every entry from `_data/messages.yml` is posted
- [ ] Each comment has the bold attribution header
- [ ] Polish/Ukrainian text renders correctly

---

## 6. Moderation posture (Announcement category)

**The Discussion category is `Announcement` — this is the primary
protection.** Only maintainers can create new threads in the category, so
non-maintainers can't spawn parallel tribute threads. The single existing
thread (auto-created by Giscus for `/tributes/`) is where all seeded
comments live and where any future replies would land.

**On per-thread `Lock conversation`:** in the current GitHub UI, a
`Lock conversation` option is not reliably discoverable at the thread
level for Announcement-category discussions. That's OK — the accepted
posture for this site is:

- Sign-in friction (GitHub sign-in + Giscus OAuth) filters most bot spam.
- Any unwanted reply from a signed-in visitor can be deleted directly on
  GitHub (Discussion → the comment → ⋯ → *Delete*).
- No thread lock means signed-in visitors CAN legitimately add a tribute
  reply if they choose — a small back-door contribution path that fits a
  memorial's intent.

If bot spam ever becomes a real problem: look for a `Lock` option in the
thread's top-right kebab menu (⋯, at the discussion header — not any
comment-level menu). If GitHub eventually exposes it, use it. Failing
that, restricting the category to a more locked-down configuration is
the escalation.

**Verification:**
- [ ] Discussion category is `Announcement`.
- [ ] Only owner-authored threads exist in the category.

---

## Ongoing maintenance

### Add or edit a tribute

Full walkthrough (with copy-paste commands) lives in
[README § Managing tributes](../README.md#managing-tributes). Short
version:

1. Update [_data/messages.yml](../_data/messages.yml) in a commit — the
   canonical text archive.
2. For a *new* tribute, generate the paste block with
   `./scripts/print-paste-blocks.rb` and copy the block for your new
   entry.
3. Sign in on `/tributes/` as the repo owner and paste the block into
   the Giscus composer → *Comment*. (Discussion is not locked — see
   [Moderation posture](#6-moderation-posture-announcement-category) —
   so no unlock/relock dance is needed.)
4. If you need to hard-remove a comment, delete it on GitHub and remove
   the entry from `_data/messages.yml`.
5. For refinements to AI-generated translations, edit both places
   (archive AND posted comment) — neither auto-updates the other.

### GitHub Actions build failing
Check the **Actions** tab. Common causes:
- `Gemfile` changed but `Gemfile.lock` wasn't committed → commit it and push.
- New photos in `originals/` but derivatives weren't regenerated → run
  `./scripts/rebuild-photos.sh` locally, commit the new files under
  `assets/img/photos/`, push. (`originals/` is git-ignored; only the
  derivatives ship.)
- Ruby / Jekyll version drift in the workflow → bump versions in
  [.github/workflows/jekyll.yml](../.github/workflows/jekyll.yml).

### Repo must stay public
Free-tier GitHub Pages requires public. Giscus needs public discussions.
Do not switch to private.

### Collaborators
Add via **Settings → Collaborators**. New collaborators can:
- Push to the repo (edits go live on next Actions build).
- Post in the tribute Discussion (as maintainers of the Announcement
  category, they can create threads and reply freely).
- Manage Discussions settings if given admin role.

### Giscus app
The Giscus app installation is under the repo owner's account. If you
transfer the repo to another owner, re-install the app under the new owner
and update `repo_id` / `category_id` in `_config.yml` (they change with the
transfer).

### Optional: revoke your Giscus OAuth grant

Seeding the tribute thread requires you to grant giscus.app OAuth
access so it can post comments as you (separate from the App
installation above). Once seeding is done, that grant is only needed
if you plan to post more comments as yourself later. To revoke:

1. Visit [github.com/settings/apps/authorizations](https://github.com/settings/apps/authorizations).
2. Find **Giscus** in the list.
3. Click **Revoke**.

Purely cosmetic — the site keeps working either way. Revoking just
tidies your "authorized apps" list. If you ever come back to post
another tribute via the widget, you'll be re-prompted to re-authorize
at that time.

---

## Handoff / disaster recovery

**What is in source control** (safe as long as any clone survives):
- Site layout, CSS, page text
- [_data/messages.yml](../_data/messages.yml) — text backup of every tribute
- Photo derivatives in [assets/img/photos/](../assets/img/photos/)
- [CNAME](../CNAME) — custom domain declaration
- This runbook

**What is NOT in source control** (single points of failure):
- The GitHub repo itself — mirror periodically to somewhere offline:
  `git clone --mirror git@github.com:<owner>/<repo>.git`
- Discussion contents — the tributes as posted (with likes, timestamps,
  reply chain if any). Text is duplicated in `_data/messages.yml`, but
  reactions and metadata aren't. Optional periodic export via
  `gh api graphql` if you care about metadata.
- Repo settings — Pages source, Discussions enabled, Custom Domain string.
  All recoverable manually, but nowhere durable except this doc.
- The Giscus app installation and `category_id` — recoverable via
  giscus.app any time.
- The @owner GitHub account itself. If the account is compromised, deleted,
  or unrecoverable, the discussion contents and the primary attribution
  chain go with it.

**If the primary maintainer becomes unavailable:**
1. A GitHub account with admin rights on the repo can invite a new
   collaborator / transfer ownership (Settings → Transfer ownership).
2. New owner re-installs the Giscus app on the repo and updates
   `_config.yml` with the new IDs (see Step 4).
3. Update `contact_email` and `maintainer` in `_config.yml`.
4. Update the **Recorded values** in this runbook.
5. Confirm DNS/domain access separately (not covered by this runbook — see
   your registrar records).

**Suggested backup ritual** (yearly):
- `git clone --mirror` the repo to offline storage.
- Refresh backup of `originals/` to external drive or cloud.
- Confirm you can still log into the owner GitHub account and access the
  domain registrar.
