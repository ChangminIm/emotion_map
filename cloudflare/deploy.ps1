# 「공주를 걷다」 홈페이지 -> Cloudflare Worker 배포
#   1) html·이미지를 cloudflare/dist/emotion_map/ 으로 복사 (APK·node_modules 제외)
#   2) wrangler deploy (wrangler.jsonc: changminim.com/emotion_map* 라우트)
# 사용:  powershell -ExecutionPolicy Bypass -File cloudflare\deploy.ps1
#        -BuildOnly 를 주면 dist 만 만들고 배포는 생략
# APK를 새로 올릴 때는 GitHub Release 로:  gh release create vX.Y.Z gongju_walk_vX.Y.Z.apk  후 worker.js 의 APK 표 갱신
param([switch]$BuildOnly)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $PSScriptRoot "dist\emotion_map"

if (Test-Path (Join-Path $PSScriptRoot "dist")) { Remove-Item -Recurse -Force (Join-Path $PSScriptRoot "dist") }
New-Item -ItemType Directory -Force $dist | Out-Null
Get-ChildItem $root -File | Where-Object { $_.Extension -in ".html", ".jpg", ".png", ".ico", ".txt" } |
  ForEach-Object { Copy-Item $_.FullName $dist }
Write-Host "dist 준비 완료: $dist ($((Get-ChildItem $dist -File).Count) files)"

if (-not $BuildOnly) {
  Push-Location $root
  try { npx wrangler deploy } finally { Pop-Location }
}
