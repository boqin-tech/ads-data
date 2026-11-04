# TikTok Ads developer application — checklist

Prepared for the Ad Data Insights site. Sources: TikTok's App Review Guidelines, TikTok for Developers
business verification docs, and TikTok API for Business developer-registration requirements. TikTok decides
all outcomes; this is a preparation aid, not a guarantee.

---

## 1. Company profile (developer registration) — reviewed before you can create an app

The profile is reviewed on its own. A rejected profile blocks app creation entirely.

| Requirement | Status / action |
| --- | --- |
| Communication email on a verified **company domain** | `daizhenghui@boqin-tech.com` — existing Tencent Exmail mailbox. A role alias (`dev@`, `ads-api@`) is stronger; use the same address in the profile, the Accounts API form (if applicable) and the site. |
| Company website: publicly reachable, no login, fully developed, real product **and** company info | Seven-page site in this repo, hosted on `www.boqin-tech.com` via GitHub Pages. |
| Website on a domain **the company owns** — no social platform, third-party host, ecommerce platform, URL shortener, personal site | GitHub Pages is fine **behind a custom subdomain**; `boqin-tech.github.io/ads-data` and `<project>.pages.dev` are not. |
| Website matches the email domain | `www.boqin-tech.com` and `@boqin-tech.com` share the registrable domain `boqin-tech.com`. |
| Company name matches the email domain and website | `BOQIN TECHNOLOGY CO., LIMITED` / `boqin-tech.com`. |
| User type matches reality | Technology Company (software vendor), not Agency, unless you mainly run ads for clients. |
| Primary developer location = where the dev team sits | Fill accurately. |
| Thin answer on how you will use TikTok data | Use the description in §3 plus the site's "What data we access" table. |

## 2. Company homepage — what the reviewer looks for

| Requirement | Where it is satisfied | Status |
| --- | --- | --- |
| Valid, official-looking site about the product and services | `index.html` | ✅ |
| Not a landing page, login page or "coming soon" | Full product page + about + contact + legal pages | ✅ |
| Privacy Policy **and** Terms of Service visible in the top navigation (not hidden in a hamburger menu) | Every page's header and footer | ✅ |
| Both legal links active | `privacy.html`, `terms.html` | ✅ |
| Privacy Policy covers the actual platform integration | TikTok Marketing API named, data categories and retention tables | ✅ |
| Real company information: legal name, registration number, registered office, contact | `about.html`, `contact.html`, footer | ⚠️ minimal mode: name + email only; registration number/address/phone intentionally omitted |
| Reachable contact: email on company domain, phone, postal address | `contact.html` | ⚠️ email only; phone/postal address deferred |
| Description of how the app uses TikTok data and which permissions | `index.html` §"How it works" and §"What data we access" | ✅ (verify against real scopes) |
| No claim of TikTok affiliation or endorsement | Footer disclaimer + `about.html` | ✅ |
| No "in review", "coming soon", "beta" language that implies the integration is not live | Checked | ✅ |
| HTTPS | GitHub Pages + Enforce HTTPS | ⬜ after DNS |
| Site reachable from outside your network / another country | Test with a VPN or external checker | ⬜ |

## 3. Developer app configuration

| Field | Limit | Suggested value |
| --- | --- | --- |
| App name | 50 chars | `Ad Data Insights` — must match the site name |
| App description | 500 chars | See draft below |
| Advertiser redirect URL | 100 chars | `https://www.boqin-tech.com/oauth/callback` (must match the code you send, exactly) |
| Scopes | — | Request only what is built today; every category must be named in the description |
| Demo video | ≤ 5 files, 50 MB each | Record against `https://www.boqin-tech.com`, not localhost |

### Draft app description (fill the client line if you are an agency)

> Ad Data Insights is a reporting app for advertisers and agencies. Through the TikTok API for Business it
> reads advertiser account structure, campaign, ad group and ad metadata, and performance reporting metrics
> for accounts that authorize it via OAuth. Access is limited to accounts the customer owns or manages; data
> is isolated per account and activity is logged. Data is used only to generate reports and exports, never
> resold. Scopes requested: Ad Account Management (read), Ads Management (read), Reporting.
> Cooperative client: [CLIENT NAME], advertiser ID [ID].

TikTok's in-product help asks for four things, and reviewers check all four:

1. the main business scope of the company;
2. the permission scopes requested and the scenarios they serve;
3. whether you access only your own accounts or third-party client accounts;
4. a cooperative client with advertiser account ID and name (if you manage third-party accounts).

Delete the client sentence if it does not apply, and remove any scope you have not implemented.

## 4. Demo video shot list

Record one continuous flow, with the browser address bar visible:

1. Open `https://www.boqin-tech.com` and navigate to the product / connect entry point.
2. Start the TikTok authorization; show TikTok's consent screen and the scopes listed.
3. Select an advertiser account and approve.
4. Land back on `https://www.boqin-tech.com/...` — the domain must match the website URL in the application.
5. Show the connected account and a generated report with real metrics.
6. Show disconnecting / revoking access.
7. Optionally open `https://www.boqin-tech.com/data-deletion.html`.

If the app is not approved yet, use the sandbox environment and a test advertiser account.

## 5. Common rejection causes and the fix

| Rejection | Cause | Fix |
| --- | --- | --- |
| Invalid website URL | Landing page, login page, `github.io` / `*.pages.dev` / `*.vercel.app`, thin content, links to Privacy/Terms only in the footer or a menu | This repo + `www.boqin-tech.com` on GitHub Pages + legal links in the top nav |
| Company name unrelated to email/website | Legal name differs from the brand and domain | Use the registered name on the site; if the brand differs, explain the relationship on `about.html` |
| Profile rejected: personal/temporary email | Gmail, QQ, 163, personal-name mailbox on a shared domain | Role alias on the company domain |
| Description does not align with scopes | A requested permission category is not mentioned or justified | Name every scope in the 500-char description, or drop the scope |
| App still in development | Site says "coming soon" / "beta" / "in review" | Remove such language only when the feature is actually live |
| Accounts scope without the form | Requested `TikTok Accounts` but no Accounts API Access Application Form | Submit the form with the same email, or drop the scope |
| Business verification fails | Name on the licence differs from the profile, blurry scan, expired document | Match exactly; re-upload a clean colour scan |

## 6. Business Center verification (separate from the developer profile)

- Company information step: official registration document, legal name in English and local language,
  registration number, registered address, expiry date.
- Legal representative step: government photo ID, name, ID number, date of birth.
- The name entered must match the document **exactly**. If the company was renamed, upload the certificate of
  change of name as well.
- The website's company block, the Business Center record and the licence should all show the same entity.

## 7. After approval

- Store the App Secret in a secrets manager, never in this repository.
- Keep the site's Privacy Policy and Terms current; TikTok re-reviews apps and can suspend access.
- Keep the demo environment and the production domain in sync — reviewers revisit the site.
