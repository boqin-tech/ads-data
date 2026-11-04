# Fill company details and check the site before publishing.
# Usage (Windows PowerShell 5.1 or PowerShell 7+):
#   1. Edit company-info.json
#   2. .\fill.ps1 -WhatIf     (preview)
#   3. .\fill.ps1             (apply)
# If script execution is blocked: powershell -ExecutionPolicy Bypass -File .\fill.ps1
#
# The script rewrites the .html files in place. If you need to start over,
# run: git checkout -- .   (the tokens are restored)

[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'company-info.json'),
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
$required = @(
    'COMPANY_NAME',
    'COMPANY_NAME_LOCAL',
    'REG_NUMBER',
    'JURISDICTION',
    'REG_ADDRESS',
    'EMAIL',
    'PHONE',
    'DOMAIN',
    'HOSTING_PROVIDER'
)

$missing = @()
foreach ($key in $required) {
    $value = $config.$key
    if ([string]::IsNullOrWhiteSpace([string]$value)) { $missing += $key }
}
if ($missing.Count -gt 0) {
    Write-Host 'Missing values in company-info.json:' -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" }
    Write-Host ''
    Write-Host 'Fill them in and run the script again. Nothing was changed.'
    exit 1
}

$files = @()
$files += Get-ChildItem -LiteralPath $root -Filter '*.html' -File
foreach ($name in @('sitemap.xml', 'robots.txt')) {
    $path = Join-Path $root $name
    if (Test-Path -LiteralPath $path) { $files += Get-Item -LiteralPath $path }
}
$changed = 0

foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $original = $text

    foreach ($key in $required) {
        $text = $text.Replace("[[$key]]", [string]$config.$key)
    }

    if ($text -ne $original) {
        if ($WhatIf) {
            Write-Host "[what-if] would update $($file.Name)"
        }
        else {
            $utf8 = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($file.FullName, $text, $utf8)
            Write-Host "[updated] $($file.Name)"
        }
        $changed++
    }
}

Write-Host ''
Write-Host "Files changed: $changed"

# --- Post-checks -----------------------------------------------------------

$scanPaths = @(Join-Path $root '*.html') + @(Join-Path $root 'sitemap.xml') + @(Join-Path $root 'robots.txt')
$tokensLeft = Select-String -Path $scanPaths -Pattern '\[\[[A-Z0-9_]+\]\]' -AllMatches -ErrorAction SilentlyContinue
if ($tokensLeft) {
    Write-Host ''
    Write-Host 'Unreplaced tokens remain:' -ForegroundColor Red
    foreach ($m in $tokensLeft) {
        Write-Host "  $($m.Filename):$($m.LineNumber)  $($m.Matches.Value -join ', ')"
    }
}
else {
    Write-Host 'No unreplaced tokens.' -ForegroundColor Green
}

$broken = @()
$htmlFiles = Get-ChildItem -LiteralPath $root -Filter '*.html' -File
foreach ($file in $htmlFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($text, 'href="([^"]+)"')) {
        $href = $match.Groups[1].Value
        if ($href -match '^(https?:|mailto:|tel:|#)') { continue }
        if ($href -eq '' -or $href -eq './') { continue }
        $target = ($href -split '#')[0]
        if ($target -eq '' -or $target -eq './' -or $target -eq '/') { continue }
        $target = $target.TrimStart('/') -replace '/', '\'
        # Clean URLs on Cloudflare Pages: "privacy" is served from privacy.html
        if ($target -notmatch '\.(html|css|svg|png|jpg|jpeg|webp|xml|txt)$') { $target = "$target.html" }
        if (-not (Test-Path -LiteralPath (Join-Path $root $target))) {
            $broken += "$($file.Name) -> $href"
        }
    }
    if ($text -notmatch 'href="/?privacy"' -or $text -notmatch 'href="/?terms"') {
        $broken += "$($file.Name) -> missing Privacy Policy or Terms link"
    }
}
if ($broken.Count -gt 0) {
    Write-Host ''
    Write-Host 'Link problems:' -ForegroundColor Red
    $broken | Sort-Object -Unique | ForEach-Object { Write-Host "  - $_" }
}
else {
    Write-Host 'Internal links OK (Privacy and Terms present on every page).' -ForegroundColor Green
}
