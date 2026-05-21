# Publish CGM Monitor to GitHub (run after: gh auth login)
$ErrorActionPreference = "Stop"

gh auth status | Out-Null

Write-Host "Creating public repo and pushing..."
git remote set-url origin https://github.com/rkhaaleed-ship-it/CGM.git
git push -u origin main

$apk = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apk)) {
    $apk = "..\..\CGM-Monitor.apk"
}
if (-not (Test-Path $apk)) {
    $apk = "$env:USERPROFILE\Downloads\CGM-Monitor.apk"
}

if (Test-Path $apk) {
    Write-Host "Creating release with APK..."
    gh release create v1.1.0 $apk --title "CGM Monitor v1.1.0" --notes "Libre 2+ support, OOP2 bridge, auto NFC scan, simplified UI (Home + NFC). Requires OOP2 on Android."
} else {
    Write-Host "APK not found — skip release or build with: flutter build apk --release"
}

Write-Host "Done: https://github.com/rkhaaleed-ship-it/CGM"
