# Cloudflare Pages 部署与域名配置

面向 `boqin-technology.com` + Cloudflare Pages。按顺序做，每一步都有验证方法。

---

## 0. 先确认现状

| 项目 | 现状 | 影响 |
| --- | --- | --- |
| 网站域名 | `boqin-technology.com`（新购） | 提审时填 `https://boqin-technology.com` |
| 现有邮箱 | `boqin-tech.com` → 腾讯企业邮（MX `mxbiz1/2.qq.com`） | **不要动 `boqin-tech.com` 的 NS**，否则邮箱会断 |
| 代码仓库 | `boqin-tech/ads-data`（GitHub） | Cloudflare Pages 直接连这个仓库 |
| 页面 | 6 个 HTML + `_headers` + `404.html` + `sitemap.xml` | Pages 根目录直接托管，无需构建 |

关键取舍：**TikTok 要求开发者资料里的邮箱域名和公司网站域名一致**。所以本站的联系邮箱默认改成了
`daizhenghui@boqin-technology.com`，需要你在第 5 步把它建出来。如果坚持用 `@boqin-tech.com`，见第 5 步方案 C。

---

## 1. 把域名接入 Cloudflare

1. Cloudflare Dashboard → **Add a site** → 输入 `boqin-technology.com` → 选 Free 计划。
2. Cloudflare 会分配两个 NS，例如 `ada.ns.cloudflare.com` / `bob.ns.cloudflare.com`。
3. 到域名注册商把 NS 改成这两个。**只改 `boqin-technology.com`，不要改 `boqin-tech.com`。**
4. 等待 Cloudflare 显示 **Active**（通常几分钟到 24 小时）。

验证：

```powershell
Resolve-DnsName boqin-technology.com -Type NS -Server 1.1.1.1
```

新域名一般没有历史记录，Cloudflare 扫描后可能是空的，这是正常的。

---

## 2. 创建 Pages 项目

1. Dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**。
2. 授权 GitHub，选择 `boqin-tech/ads-data`，分支 `main`。
3. 构建配置：
   - Framework preset: **None**
   - Build command: **留空**
   - Build output directory: **`/`**
4. **Save and Deploy**，等待第一次部署完成。
5. 打开 `https://<project-name>.pages.dev` 检查页面。这个地址只用于预览，**不要提交给 TikTok**。

说明：仓库根目录的 `_headers`、`404.html`、`sitemap.xml` 会被 Pages 自动识别；`_headers` 里的
`https://:project.pages.dev/*` 规则会给预览域名加 `noindex`。

---

## 3. 绑定自定义域名

1. Pages 项目 → **Custom domains** → **Set up a custom domain**。
2. 输入 `boqin-technology.com`，确认。因为域名已经在 Cloudflare，CNAME 会自动创建。
3. 再添加 `www.boqin-technology.com`。
4. 等待状态变成 **Active**，证书自动签发（通常几分钟）。

验证：

```powershell
curl.exe -I https://boqin-technology.com/
curl.exe -I https://www.boqin-technology.com/
```

---

## 4. 强制 HTTPS 与 www 跳转

1. **SSL/TLS → Overview**：模式选 **Full (strict)**。
2. **SSL/TLS → Edge Certificates**：打开 **Always Use HTTPS**。
3. **Rules → Redirect Rules → Create rule**：
   - 名称：`www to apex`
   - 匹配：`Custom filter expression` → `http.host eq "www.boqin-technology.com"`
   - 目标：`concat("https://boqin-technology.com", http.request.uri.path)`
   - 状态码：`301`，保留查询串。

验证 `www` 应该 301 到主域，而不是 200 重复内容。

---

## 5. 邮箱（这一步决定提审能不能过）

TikTok 的开发者资料邮箱必须能收验证码，而且域名要和网站一致。

### 方案 A — Cloudflare Email Routing（推荐，免费，5 分钟）

1. 域名 zone → **Email → Email Routing** → **Enable**。
2. Cloudflare 会自动写入 MX（`route1/2/3.mx.cloudflare.net`）。新域名没有其他邮件服务，不冲突。
3. **Destination addresses**：添加你现有的收件邮箱并完成验证。
4. **Custom addresses**：创建 `daizhenghui@boqin-technology.com`，转发到上面的收件箱。
5. 从外部邮箱发一封测试邮件，确认能收到。

注意：Email Routing 只能收、不能以该地址主动发信。回复时会显示你的真实发件地址，对 TikTok 审核通常够用；
如果要能“以公司域名发信”，用方案 B。

### 方案 B — 腾讯企业邮加别名域

在腾讯企业邮后台把 `boqin-technology.com` 添加为别名域（是否支持取决于套餐），按提示配置 MX/TXT/SPF/DKIM。
可以正常收发，但配置步骤多。

### 方案 C — 继续用 `@boqin-tech.com`

页面能跑，但网站域名（`boqin-technology.com`）和资料邮箱域名（`boqin-tech.com`）不一致，审核可能被问。
如果选这条，至少在 `about.html` 里说明两个域名的关系，并在提审描述里主动解释。

**无论选哪个方案，提审前都做一次真实收发测试。** 收不到验证邮件的申请等于白做。

---

## 6. 上线前验证清单

```powershell
# 1) 主域 200，HTTP 跳 HTTPS
curl.exe -I http://boqin-technology.com/
curl.exe -I https://boqin-technology.com/

# 2) 法律页可访问（clean URL，不要带 .html）
curl.exe -I https://boqin-technology.com/privacy
curl.exe -I https://boqin-technology.com/terms
curl.exe -I https://boqin-technology.com/data-deletion

# 3) 404 页面走自定义页
curl.exe -I https://boqin-technology.com/no-such-page

# 4) 安全头是否生效
curl.exe -sI https://boqin-technology.com/ | Select-String -Pattern "content-security-policy|x-frame-options|strict-transport-security"

# 5) 移动网络访问（手机开 4G，不要用公司 Wi-Fi）
```

浏览器里再确认：

- 每页顶部导航都能直接看到 **Privacy Policy** 和 **Terms of Service**，不需要点开菜单。
- 页面没有 “coming soon / beta / in review” 字样。
- 公司名、注册号、地址、电话在首页、About、Contact、页脚四处一致。
- 用无痕窗口打开，确认不需要登录。

---

## 7. 提交 TikTok 时填什么

| 字段 | 填 |
| --- | --- |
| Company website | `https://boqin-technology.com` |
| 开发者资料邮箱 | `daizhenghui@boqin-technology.com`（或你在第 5 步建好的地址） |
| App name | `Ad Data Insights`（与网站标题一致） |
| Advertiser redirect URL | `https://boqin-technology.com/oauth/callback`（必须与代码里完全一致） |
| Demo video | 对着 `https://boqin-technology.com` 录制，地址栏要可见 |

不要填 `*.pages.dev`，也不要填 GitHub Pages 地址。

---

## 8. 常见问题

**Pages 会把 `/privacy.html` 跳转到 `/privacy`。**
这是 Cloudflare Pages 的默认行为。站内链接已经全部改成 clean URL，canonical 和 sitemap 也是 clean URL，
所以不用额外处理；旧链接仍会 301 到新地址。

**改了 `company-info.json` 之后要重新部署吗？**
`fill.ps1` 是在本地把值写进 HTML 的，写完要 commit + push，Pages 才会重新构建。token 用掉后想重来：
`git checkout -- .`。

**能不能直接用 Cloudflare 的“直接上传”？**
可以（`npx wrangler pages deploy .`），但以后每次改都要手动上传。Git 集成更省事。

**HSTS 开了以后能关吗？**
`_headers` 里是 `max-age=31536000; includeSubDomains`，没有 preload。上线初期如果证书有问题，尽快修；
浏览器会记住一年。不确定的话先把这行删掉，稳定后再加。
