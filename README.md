# Ad Data Insights — company website

Static website for the Ad Data Insights application, prepared for a **TikTok Ads (Marketing API) developer
account application**. Deployed on **Cloudflare Pages** at `https://boqin-technology.com`.

Seven HTML pages, no build step, no JavaScript, no external fonts or trackers:

| File | Purpose |
| --- | --- |
| `index.html` | Product homepage: what the app does, how authorization works, what data is accessed, security, company block |
| `about.html` | Company page: legal entity, registration number, registered office, verification documents |
| `contact.html` | Contact routes (general, privacy, security, platform review) and postal address |
| `privacy.html` | Privacy Policy, written around TikTok Marketing API data flows |
| `terms.html` | Terms of Service |
| `data-deletion.html` | How to revoke access and request deletion, with timelines |
| `404.html` | Not-found page (Cloudflare Pages serves it with a 404 status) |
| `assets/` | Shared stylesheet and favicon |
| `_headers` | Security headers + `noindex` for `*.pages.dev` previews |
| `sitemap.xml`, `robots.txt` | Indexing files (domain filled by `fill.ps1`) |

---

## 1. Fill in the company details first

The HTML contains tokens such as `[[COMPANY_NAME]]`. They are replaced from `company-info.json`.

1. Edit `company-info.json` — every value must be **exactly** what appears on your certificate of
   incorporation / business registration certificate. Mismatched names are a documented rejection cause at
   TikTok business verification.
2. Preview: `.\fill.ps1 -WhatIf`
3. Apply: `.\fill.ps1`
4. The script also checks for leftover tokens and broken internal links.

If script execution is blocked:

```powershell
powershell -ExecutionPolicy Bypass -File .\fill.ps1
```

Tokens are consumed on the first run. To start over, `git checkout -- .` restores them.

### What to put in each field

| Key | Notes |
| --- | --- |
| `COMPANY_NAME` | Legal name in English, as registered (e.g. `BOQIN TECHNOLOGY CO., LIMITED`) |
| `COMPANY_NAME_LOCAL` | Legal name in the registration jurisdiction's language |
| `REG_NUMBER` | Company registration / business registration number |
| `JURISDICTION` | `Hong Kong SAR`, `People's Republic of China`, etc. — also used as governing law in the Terms |
| `REG_ADDRESS` | Full registered office address, including country and postal code |
| `EMAIL` | **Must be on the same domain as the website.** Default is `daizhenghui@boqin-technology.com` — create it before submitting (see `DEPLOY-CLOUDFLARE.md` §5) |
| `PHONE` | A reachable business number with country code |
| `DOMAIN` | `boqin-technology.com` |
| `HOSTING_PROVIDER` | `Cloudflare, Inc.` — named in the Privacy Policy subprocessor table |

---

## 2. The domain is the part that usually fails review

TikTok's rules for the company website on a developer profile require a site that is:

- publicly accessible without login,
- functioning and fully developed,
- showing real product **and company** information,
- on a domain **the company owns** — not a social platform, third-party host, ecommerce platform or URL shortener,
- matching the company email domain.

`https://boqin-tech.github.io/ads-data/` fails the "domain the company owns" test, and so does any
`*.pages.dev` URL. The site must be served from `https://boqin-technology.com/`.

## 3. Deploy on Cloudflare Pages

Full steps, DNS records, email routing and verification commands: **[DEPLOY-CLOUDFLARE.md](DEPLOY-CLOUDFLARE.md)**.

Short version:

1. Add `boqin-technology.com` to Cloudflare, change the registrar's nameservers.
2. Workers & Pages → Create → Pages → Connect to Git → repo `boqin-tech/ads-data`, branch `main`.
3. Framework preset **None**, build command **empty**, output directory **`/`**.
4. Custom domains: add `boqin-technology.com` and `www.boqin-technology.com`.
5. SSL/TLS **Full (strict)**, enable **Always Use HTTPS**, redirect `www` → apex with a Redirect Rule.
6. Create `daizhenghui@boqin-technology.com` via Cloudflare Email Routing and test it.

Clean URLs: Cloudflare Pages redirects `/privacy.html` to `/privacy`, so every internal link, canonical URL
and sitemap entry already uses the extension-less form. Local preview therefore needs a server, not `file://`:

```powershell
python -m http.server 8080
# http://localhost:8080/
```

## 4. Before submitting to TikTok

Work through [`TIKTOK-CHECKLIST.md`](TIKTOK-CHECKLIST.md). The short version:

- [ ] Site live on `boqin-technology.com` over HTTPS, no login required.
- [ ] Company name, registration number and address identical on the site, in the developer profile and on the
      business licence.
- [ ] Privacy Policy and Terms of Service in the top navigation on every page (they are).
- [ ] Everything the site claims about the TikTok integration is actually built and demonstrable in the
      sandbox / demo video.
- [ ] A demo video recorded against **this domain**, showing the full OAuth flow and a report being generated.
- [ ] App description in the developer portal names every permission scope you request.

## 5. Statements you must verify before publishing

The copy makes specific commitments. Change them if they are not true of your implementation — an inaccurate
privacy policy is worse than a thin one, and reviewers compare the site against the app.

| Statement | Where | Check |
| --- | --- | --- |
| Read-only: no campaign creation, editing or publishing | index, terms | True? |
| No access to TikTok user profiles, DMs, organic content | index, privacy | True given the scopes you request? |
| Tokens encrypted at rest, never logged | index, privacy | True? |
| Retention: 12 months for reporting data, 90 days logs, 30 days after disconnect | index, privacy | Match your actual jobs/backups? |
| Subprocessor list (`HOSTING_PROVIDER`) | privacy | Complete? Add email, payments, monitoring providers |
| Governing law = `JURISDICTION` | terms | Confirmed by counsel? |
| Data processing on documented instructions (controller/processor split) | privacy, terms | Correct for your contracts? |

This is not legal advice. Have the Privacy Policy and Terms reviewed against your actual architecture and
the jurisdictions you sell into.

## 6. Known limitations

- No cookie banner because the site sets no cookies and loads no third-party resources. If you add analytics,
  update `privacy.html` §6 and `_headers` first.
- The contact page uses `mailto:` links; there is no form backend.
- `fill.ps1` works in Windows PowerShell 5.1 and PowerShell 7.
- `_headers` sets HSTS for one year including subdomains. Remove that line if you are not ready for it.
