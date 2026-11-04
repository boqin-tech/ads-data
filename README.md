# Ad Data Insights — company website

Static website for the Ad Data Insights application, prepared for a **TikTok Ads (Marketing API) developer
account application**. Deployed on **GitHub Pages** at `https://adsd.boqin-tech.com`.

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
| `COMPANY_NAME` | Registered company name. Currently `播琴科技有限公司` — switch to the English registered name if the licence has one |
| `COMPANY_NAME_LOCAL` | Local-language name; same value here |
| `EMAIL` | **Must share the registrable domain with the website.** `daizhenghui@boqin-tech.com` and `adsd.boqin-tech.com` both sit on `boqin-tech.com`, so the existing Tencent Exmail mailbox is fine |
| `DOMAIN` | `adsd.boqin-tech.com` |
| `HOSTING_PROVIDER` | `GitHub, Inc.` — named in the Privacy Policy subprocessor table |

Registration number, registered office, jurisdiction and telephone were deliberately removed from every page
(minimal mode). TikTok may reject the profile for missing company details; if that happens, add the rows back
to `about.html`, `contact.html`, `privacy.html` and `terms.html` and put the values in `company-info.json`.

---

## 2. The domain is the part that usually fails review

TikTok's rules for the company website on a developer profile require a site that is:

- publicly accessible without login,
- functioning and fully developed,
- showing real product **and company** information,
- on a domain **the company owns** — not a social platform, third-party host, ecommerce platform or URL shortener,
- matching the company email domain.

`https://boqin-tech.github.io/ads-data/` fails the "domain the company owns" test, and so does any
`*.pages.dev` URL. The site is served from `https://adsd.boqin-tech.com/` — a subdomain of a domain the
company owns and the same registrable domain as the company email.

## 3. Deploy on GitHub Pages

The repo is already wired for Pages: `CNAME` contains `adsd.boqin-tech.com`, and `.nojekyll` turns off Jekyll
processing. To redeploy:

1. Push to `main`; Pages rebuilds on every push.
2. Repo → **Settings → Pages → Build and deployment**: **Deploy from a branch**, branch `main`, folder `/ (root)`.
3. **Custom domain** `adsd.boqin-tech.com` — the same value as the `CNAME` file.
4. At GoDaddy: **DNS → Add record**, type **CNAME**, name `adsd`, value `boqin-tech.github.io`, TTL 1 hour.
   Delete any existing A record for `adsd` first. Do not touch MX, SPF or TXT — those serve the Tencent
   Exmail mailbox on `boqin-tech.com`.
5. Wait for GitHub's DNS check to pass, then enable **Enforce HTTPS**. Certificate issuance can take up to
   24 hours.

GitHub Pages serves plain files, so every internal link, canonical URL and sitemap entry uses `.html`
(`/about.html`, `/privacy.html`). It does **not** rewrite `/about` to `/about.html`; that is why the earlier
extension-less links returned 404. `_headers` is a Cloudflare-only file and is ignored here, so the security
headers it defines do not apply on GitHub Pages. If you later move to Cloudflare Pages, the `.html` links
still work (Cloudflare 301s them to the clean form).

## 4. Before submitting to TikTok

Work through [`TIKTOK-CHECKLIST.md`](TIKTOK-CHECKLIST.md). The short version:

- [ ] Site live on `adsd.boqin-tech.com` over HTTPS, no login required.
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
| Governing law now reads "the jurisdiction in which the company is registered" | terms | Acceptable until the jurisdiction is confirmed? |
| Data processing on documented instructions (controller/processor split) | privacy, terms | Correct for your contracts? |

This is not legal advice. Have the Privacy Policy and Terms reviewed against your actual architecture and
the jurisdictions you sell into.

## 6. Known limitations

- No cookie banner because the site sets no cookies and loads no third-party resources. If you add analytics,
  update `privacy.html` §6 first.
- The contact page uses `mailto:` links; there is no form backend.
- `fill.ps1` works in Windows PowerShell 5.1 and PowerShell 7.
- `_headers` only takes effect on Cloudflare; GitHub Pages ignores it, so no HSTS/CSP there. If TikTok or a
  customer requires those headers, put Cloudflare in front of GitHub Pages or host on Cloudflare Pages.
