# 「공주를 걷다」 홈페이지 -> Cloudflare Worker 배포
#   1) html·이미지·APK 를 cloudflare/dist/emotion_map/ 으로 복사 (node_modules 제외)
#   2) wrangler deploy (wrangler.jsonc: changminim.com/emotion_map* 라우트)
# 사용:  powershell -ExecutionPolicy Bypass -File cloudflare\deploy.ps1
#        -BuildOnly 를 주면 dist 만 만들고 배포는 생략
# APK는 정적 자산 한도(파일당 25MiB) 때문에 ABI별 분리 빌드를 쓴다:
#   flutter build apk --release --split-per-abi --flavor emotion -t lib/main_emotion.dart
#   arm64-v8a → 공주를걷다_vX.Y.Z.apk, armeabi-v7a → 공주를걷다_vX.Y.Z_32bit.apk (통합 APK 59MB는 못 올린다)
param([switch]$BuildOnly)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $PSScriptRoot "dist\emotion_map"

if (Test-Path (Join-Path $PSScriptRoot "dist")) { Remove-Item -Recurse -Force (Join-Path $PSScriptRoot "dist") }
New-Item -ItemType Directory -Force $dist | Out-Null
Get-ChildItem $root -File | Where-Object { $_.Extension -in ".html", ".jpg", ".png", ".ico", ".txt", ".apk" } |
  ForEach-Object {
    if ($_.Length -gt 25MB) { throw "$($_.Name) 은 25MiB 를 넘어 Worker 자산으로 올릴 수 없습니다 (ABI 분리 빌드 사용)" }
    Copy-Item $_.FullName $dist
  }
Write-Host "dist 준비 완료: $dist ($((Get-ChildItem $dist -File).Count) files)"

if (-not $BuildOnly) {
  Push-Location $root
  try { npx wrangler deploy } finally { Pop-Location }
}
