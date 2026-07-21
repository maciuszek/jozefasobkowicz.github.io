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
- [ ] You know the **current GitHub Pages A records** — GitHub
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
