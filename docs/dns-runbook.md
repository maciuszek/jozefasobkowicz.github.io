# DNS + domain runbook — jozefasobkowicz.com

Everything about the custom domain **jozefasobkowicz.com**: DNS records at
GoDaddy, custom-domain wiring on GitHub Pages, the HTTPS certificate, and
ongoing registrar responsibilities. This is the durable record for state
that lives outside the repo.

**Scope:** DNS + domain registration. GitHub repo/Pages/Discussions live
in [github-runbook.md](github-runbook.md). One-time content migration from
WordPress is in [godaddy-migration.md](godaddy-migration.md).

As you complete each step, fill in the **Recorded values** blanks so this
doc becomes an as-built record.

---

## Canonical host invariant

Canonical host = **apex** `jozefasobkowicz.com` (NOT `www`). This must
stay consistent across four places:

1. [`_config.yml`](../_config.yml) → `url: "https://jozefasobkowicz.com"`
2. [`CNAME`](../CNAME) → `jozefasobkowicz.com`
3. GitHub → Settings → Pages → Custom domain → `jozefasobkowicz.com`
4. Emitted `/sitemap.xml` and `/sitemap-images.xml` → all URLs apex

**If any one of the four changes, all four must change together.**
Otherwise search engines see a canonical URL that redirects to a
different served URL — a real SEO wart.

---

## Prerequisites

- Access to the **GoDaddy account** that owns `jozefasobkowicz.com` as
  registrant of record.
- Admin access to the **GitHub repo** hosting the Pages site (see
  [github-runbook.md](github-runbook.md)).
- The site is already live at the temporary `*.github.io` URL and looks
  right. **Don't touch DNS until then** — a bad DNS switch takes the site
  down.

**Recorded values:**
- GoDaddy account (login/email): __________________________________
- Domain: jozefasobkowicz.com
- Domain expiration date: _________________________________________
- Auto-renew enabled: __________ (Y/N)

---

## 1. Pre-flight

Before touching DNS:

- [ ] Temp `*.github.io` URL loads all 4 pages, gallery renders, Giscus
      works.
- [ ] [CNAME](../CNAME) in the repo contains exactly
      `jozefasobkowicz.com` (no trailing whitespace / stray newline).
      GitHub uses this file to set the Pages custom-domain value
      automatically on each deploy.
- [ ] You have a local copy of any `@jozefasobkowicz.com` **email** you
      want to keep. Cancelling GoDaddy hosting later may terminate the
      mailbox depending on your plan — see
      [Email hosting](#email-hosting-jozefasobkowiczcom) below.
- [✓] You know the **current GitHub Pages A records** — GitHub
      occasionally rotates these. Confirm the current values in the
      [GitHub Pages docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)
      before pasting into GoDaddy.

---

## 2. Confirm the custom domain in GitHub Pages

1. **Settings → Pages → Custom domain:** should already show
   `jozefasobkowicz.com` — GitHub auto-populates this from the
   [CNAME](../CNAME) file on the first Pages deploy. If for any reason
   it's blank, enter the value and click Save; on the next deploy it
   re-syncs from `CNAME` (see [CNAME file drift](#cname-file-drift)
   in Ongoing maintenance below).
2. GitHub starts a DNS check that fails until Step 3 completes.
3. Do NOT enable HTTPS yet — it needs DNS working first.

---

## 3. Configure GoDaddy DNS records

Log into GoDaddy → **My Products → Domains → jozefasobkowicz.com → DNS.**

**Remove first:**
- Any `@` (apex) A record pointing to GoDaddy/WordPress hosting.
- Any `www` CNAME pointing to GoDaddy hosting.
- **Keep** MX records for now (see
  [Email hosting](#email-hosting-jozefasobkowiczcom)).

**Then add:**

### Apex A records (four)

| Type | Name | Value               | TTL    |
|------|------|---------------------|--------|
| A    | @    | 185.199.108.153     | 1 hour |
| A    | @    | 185.199.109.153     | 1 hour |
| A    | @    | 185.199.110.153     | 1 hour |
| A    | @    | 185.199.111.153     | 1 hour |

**IMPORTANT:** these IPs can change. Confirm current values in the
GitHub Pages docs (link in Pre-flight) before pasting.

### www CNAME

| Type  | Name | Value                     | TTL    |
|-------|------|---------------------------|--------|
| CNAME | www  | `<owner>.github.io.`      | 1 hour |

(Trailing dot is standard DNS notation. GoDaddy usually accepts either
form.)

**Recorded values:**
- Records confirmed (date): ______________________________________
- GitHub Pages IPs used (paste literally, in case they change later):
  _______________________________________________________________

---

## 4. Wait for propagation

DNS takes minutes to hours to propagate globally. Check with:

```bash
dig +short A jozefasobkowicz.com            # expect the 4 GitHub IPs
dig +short CNAME www.jozefasobkowicz.com    # expect <owner>.github.io.
```

Or use https://dnschecker.org for a global view.

Once propagation is complete, GitHub's **Settings → Pages** DNS check
turns green.

---

## 5. Enforce HTTPS

1. Wait for GitHub to issue the Let's Encrypt certificate (minutes to a
   few hours after DNS resolves).
2. **Settings → Pages → Enforce HTTPS:** tick.
3. Confirm `http://jozefasobkowicz.com` redirects to
   `https://jozefasobkowicz.com`, no browser cert warnings.

Certificates auto-renew — no ongoing action required.

---

## 6. Post-migration cleanup

After the domain resolves cleanly and HTTPS is enforced:

- [ ] **Cancel GoDaddy hosting** — but only the *hosting* plan.
      **Keep the domain registration.** These are separate line items in
      GoDaddy; make sure you cancel the right one.
- [ ] If applicable, cancel WordPress-specific add-ons (Managed
      WordPress, SSL, security scans).
- [ ] Day 1 after cancellation: confirm the domain still resolves and
      the mailbox (if kept) still works.

---

## Live DNS records (as of cutover)

Snapshot of the live GoDaddy zone at the moment `jozefasobkowicz.com`
was cut over from WordPress to GitHub Pages. Records fall into three
groups: GitHub Pages delivery (what serves the site), intentional
WordPress-parking records (`old.*` — see next section), and cleanup
backlog (see below).

### GitHub Pages records (site delivery)

| Type  | Name | Value                                                          | TTL       | Purpose                                                                          |
|-------|------|----------------------------------------------------------------|-----------|----------------------------------------------------------------------------------|
| A     | @    | `185.199.108.153`                                              | 1 hour    | Apex → GitHub Pages anycast IP #1                                                |
| A     | @    | `185.199.109.153`                                              | 1 hour    | Apex → GitHub Pages anycast IP #2                                                |
| A     | @    | `185.199.110.153`                                              | 1 hour    | Apex → GitHub Pages anycast IP #3                                                |
| A     | @    | `185.199.111.153`                                              | 1 hour    | Apex → GitHub Pages anycast IP #4                                                |
| CNAME | www  | `maciuszek.github.io.`                                         | 1 hour    | `www` → GitHub's hostname; GitHub then 301-redirects to apex (see decision)      |
| TXT   | @    | `google-site-verification=BBXElhCWr8xtajC7ULIGthZTlLic9lz3vmzVRvZ3pzg` | 1 hour    | Keeps the Google Search Console domain property verified — **do not delete**     |
| NS    | @    | `ns09.domaincontrol.com.` / `ns10.domaincontrol.com.`          | (default) | GoDaddy registrar nameservers — leave untouched                                  |
| SOA   | @    | `Primary nameserver: ns09.domaincontrol.com.` (+ GoDaddy defaults) | (default) | Zone start-of-authority — leave untouched                                        |

**Before editing any A record, verify current GitHub Pages IPs against
the [GitHub Pages docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site).**
GitHub occasionally rotates them.

The `TXT google-site-verification` token value is recorded verbatim
above so it can be restored if the record is ever accidentally deleted.
The token isn't sensitive — it's already public (DNS is public) and
only functions to verify domain ownership in Google Search Console,
which itself requires GoDaddy account access to change.

### DECISION — `www` CNAME target

Recorded because both options were considered during setup; capturing
the reasoning so this isn't re-litigated later.

- **Decided:** `www CNAME → maciuszek.github.io.`
- **Alternative considered but rejected:**
  `www CNAME → jozefasobkowicz.com` (pointing `www` at our own apex).
- **Reasoning:**
  1. **The apex can't take a CNAME.** DNS spec forbids CNAME at the
     zone apex — it would collide with the required SOA / NS records.
     That's why the apex uses four literal A records and only `www`
     is free to be a CNAME at all.
  2. **Pointing `www` at `maciuszek.github.io` rides GitHub's anycast
     CDN by hostname.** If GitHub rotates its Pages IPs, our `www`
     keeps working automatically — resolution happens on GitHub's
     side. Pointing `www` at our own apex instead would add an extra
     DNS-resolution hop (`www → apex → four literal IPs`) — more
     fragile with no benefit, since the ultimate destination is still
     GitHub's infrastructure either way.
  3. **GitHub Pages performs the `www → apex` HTTP 301 itself** —
     application-layer, based on the Custom Domain = apex setting.
     The redirect is not a DNS-layer concept. The chosen CNAME target
     just gets requests *to* GitHub; GitHub then decides where to
     redirect based on its own knowledge of the canonical host.
- **Expected behavior post-cert issuance:**
  `https://www.jozefasobkowicz.com/anything/` →
  HTTP 301 →
  `https://jozefasobkowicz.com/anything/`.

---

## Intentional legacy records (WordPress backup at `old.` subdomain)

**Two-site setup during migration window:**

- **Main site** → `jozefasobkowicz.com` (apex, GitHub Pages) — the
  new Jekyll site (see [GitHub Pages records](#github-pages-records-site-delivery)
  above).
- **Backup path** → `old.jozefasobkowicz.com` (also
  `www.old.jozefasobkowicz.com`) — the original WordPress site, still
  served from GoDaddy cPanel at `107.180.26.81`. HTTP-only (no TLS
  cert for the `old.` subdomain).

The `.old` records below exist purely to keep the WordPress backup
reachable — for stale bookmarks, in-flight search-engine indexes, or
anyone who prefers the old presentation while search engines re-index
to the new site. They are NOT part of the new site's delivery.

**Context:** the GoDaddy cPanel hosting's *primary domain* was
changed to `old.jozefasobkowicz.com` as part of the cutover. That
change auto-provisioned all the subdomain records under the `.old`
prefix and updated the WordPress site's own URL config to
`http://www.old.jozefasobkowicz.com`. So every legacy record below has
a `.old` suffix, and they all resolve/chain to the cPanel box at
`107.180.26.81`.

| Type  | Name                | Value                        | Purpose                                                                           |
|-------|---------------------|------------------------------|-----------------------------------------------------------------------------------|
| A     | `old`               | `107.180.26.81`              | Points `old.jozefasobkowicz.com` at the GoDaddy cPanel/WordPress box              |
| A     | `admin.old`         | `107.180.26.81`              | WordPress admin subdomain (`admin.old.jozefasobkowicz.com`)                       |
| A     | `mail.old`          | `107.180.26.81`              | Mail subdomain for WordPress-era email routing                                    |
| CNAME | `cpanel.old`        | `old.jozefasobkowicz.com.`   | cPanel admin panel access                                                         |
| CNAME | `webdisk.old`       | `old.jozefasobkowicz.com.`   | cPanel WebDisk feature                                                            |
| CNAME | `webdisk.admin.old` | `old.jozefasobkowicz.com.`   | WebDisk sub-endpoint under the admin subdomain                                    |
| CNAME | `whm.old`           | `old.jozefasobkowicz.com.`   | WHM (Web Host Manager) admin panel                                                |
| CNAME | `www.admin.old`     | `old.jozefasobkowicz.com.`   | `www.` variant of the admin subdomain                                             |
| CNAME | `www.old`           | `old.jozefasobkowicz.com.`   | `www.` variant — WordPress site is configured at `http://www.old.jozefasobkowicz.com` |

Plus one GoDaddy service record that isn't WordPress-specific but is
part of the same cleanup batch:

| Type  | Name             | Value                                    | Purpose                                                            |
|-------|------------------|------------------------------------------|--------------------------------------------------------------------|
| CNAME | `_domainconnect` | `_domainconnect.gd.domaincontrol.com.`   | GoDaddy Domain Connect service helper — used for automated setup wizards; not currently in use |

Users hitting `old.` or `www.old.` in a browser still see the
WordPress content untouched. Once we're satisfied the new site is
fully indexed and nobody is missing content on the old one, the whole
block gets pruned (see next section).

**Note on scheme:** the old WordPress site serves over `http://`
(no valid TLS cert for the `old.` subdomain). Modern browsers may show
a "Not secure" warning; that's expected for the migration window.

---

## Cleanup backlog (post-WordPress-decommission)

Records that become dead once GoDaddy **hosting** is cancelled AND
`old.jozefasobkowicz.com` is retired. **Do NOT prune before both of
those events** — currently they serve real WordPress-era
functionality.

Note: cancelling GoDaddy **hosting** is a separate line-item from the
**domain registration**, which stays at GoDaddy indefinitely.

**Records to remove at cleanup time** (all captured in the Intentional
legacy records table above):

- `A old → 107.180.26.81`
- `A admin.old → 107.180.26.81`
- `A mail.old → 107.180.26.81` — **keep** if you're still routing
  `@jozefasobkowicz.com` email through this record; see
  [Email hosting](#email-hosting-jozefasobkowiczcom)
- `CNAME cpanel.old → old.jozefasobkowicz.com.`
- `CNAME webdisk.old → old.jozefasobkowicz.com.`
- `CNAME webdisk.admin.old → old.jozefasobkowicz.com.`
- `CNAME whm.old → old.jozefasobkowicz.com.`
- `CNAME www.admin.old → old.jozefasobkowicz.com.`
- `CNAME www.old → old.jozefasobkowicz.com.`
- `CNAME _domainconnect → _domainconnect.gd.domaincontrol.com.`
  (GoDaddy service helper; not needed once hosting is gone)

**Records to keep after cleanup:**

- The GitHub Pages block (4 apex A records + `www` CNAME → `maciuszek.github.io.`)
- `TXT @ google-site-verification=BBXElhCWr8xtajC7ULIGthZTlLic9lz3vmzVRvZ3pzg`
- NS / SOA (registrar defaults)

After pruning, the zone should have exactly **7 non-legacy records**:
4 apex A + 1 www CNAME + 1 TXT + NS/SOA (counted as one registrar
default set).

---

## Cutover verification checklist

Go/no-go before cancelling GoDaddy hosting. Everything below should be
green:

- [ ] GitHub Pages: site live at `https://jozefasobkowicz.com/`,
      "DNS check successful" in **Settings → Pages**,
      Source = **GitHub Actions**.
- [ ] **Enforce HTTPS** available + enabled (Let's Encrypt cert
      issuance may take minutes to hours after DNS resolves —
      transient; the checkbox appearing means DNS is green).
- [ ] `https://jozefasobkowicz.com` serves the new site with no
      browser cert warning.
- [ ] `https://www.jozefasobkowicz.com/…` HTTP 301-redirects to the
      apex (see [Decision — www CNAME target](#decision--www-cname-target)
      for why this works).
- [ ] `http://old.jozefasobkowicz.com` (or `http://www.old.jozefasobkowicz.com`
      — WordPress's canonical URL is the `www.old.` form) still
      serves WordPress. Note the `http://` scheme — the old subdomain
      has no valid TLS cert; that's expected. Browsers will flag
      "Not secure"; that's fine for the migration window.
- [ ] `sitemap.xml` and `sitemap-images.xml` emit apex URLs (no
      `www`), matching the [Canonical host invariant](#canonical-host-invariant).

**Only after all six are green:** cancel GoDaddy **hosting** (keep
the **domain registration**). See
[§ 6. Post-migration cleanup](#6-post-migration-cleanup) above for the
exact cancellation steps.

---

## Ongoing maintenance

### Annual domain renewal

The domain registration is the **only recurring cost** for this site
(GitHub Pages is free; hosting is cancelled). GoDaddy renews annually.
Enable **auto-renew** — losing a memorial domain would be irreversible
if a squatter grabbed it during a lapse.

- [ ] Auto-renew enabled: Y/N (record above)
- [ ] Payment method on file is valid: last checked ______________

### Email hosting (@jozefasobkowicz.com)

If email was in use through GoDaddy or Microsoft 365 via GoDaddy, you
have three options:

- **Keep at GoDaddy** — buy the Email/Workspace add-on standalone,
  separate from the (now-cancelled) hosting. MX records stay put.
- **Move to another provider** — Fastmail, Google Workspace, Proton,
  etc. Update MX records in GoDaddy DNS after the new provider is set
  up.
- **Turn it off** — remove MX records; incoming mail bounces.

Decide **before** cancelling hosting; some GoDaddy email plans are
bundled with the hosting plan and terminate on cancellation.

**Recorded values:**
- Email decision: _______________________________________________
- Provider (if kept): ___________________________________________

### GitHub Pages IP changes

GitHub occasionally rotates the apex A records. Symptoms: HTTPS still
works but **Settings → Pages** DNS check goes yellow/red. Fix: look up
the current IPs in the GitHub Pages docs and update the four A records
at GoDaddy. HTTPS re-issues automatically.

### CNAME file drift

If someone edits **Settings → Pages → Custom domain** in the GitHub UI
without also updating [CNAME](../CNAME) in the repo, the next Actions
deploy overwrites the UI value from the file. Rule of thumb: change
[CNAME](../CNAME) in a commit; don't fight the UI.

---

## Handoff / disaster recovery

**What's in source control:**
- [CNAME](../CNAME) — declares the custom domain.

**What's NOT in source control** (single points of failure):
- **GoDaddy account** owning `jozefasobkowicz.com`. If the account is
  lost, so is the domain (barring registrar transfer paperwork). Keep
  the login credentials somewhere durable — password manager, sealed
  envelope, whatever.
- **DNS records at GoDaddy** — the four A records + www CNAME. If lost,
  re-add per Step 3.
- **Domain payment method** — if the card expires and auto-renew fails,
  the domain lapses.
- **Any MX records + third-party email account.**

**If you need to transfer the domain to another registrar:**
1. Unlock the domain at GoDaddy (Domain settings → Domain lock).
2. Request the authorization / EPP code.
3. Initiate transfer at the new registrar with the EPP code.
4. Approve the transfer confirmation GoDaddy emails you.
5. After transfer, re-create the DNS records at the new registrar
   (they don't move automatically). Use the values in Step 3.

**Suggested yearly backup ritual** (around renewal time):
- Confirm the domain isn't near expiry and auto-renew is still on.
- Verify DNS still resolves to the current GitHub Pages IPs.
- Verify HTTPS is enforced and the cert is valid.
- Confirm access to the GoDaddy account (log in).
