# Publish CGM Monitor to GitHub (run after: gh auth login)
$ErrorActionPreference = "Stop"

gh auth status | Out-Null

Write-Host "Creating public repo and pushing..."
gh repo create rkhaaleed-ship-it/cgm-monitor --public --source=. --remote=origin --push --description "Flutter CGM companion app for FreeStyle Libre (NFC + BLE, AR/EN)"

$apk = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apk)) {
    $apk = "..\..\CGM-Monitor.apk"
}
if (-not (Test-Path $apk)) {
    $apk = "$env:USERPROFILE\Downloads\CGM-Monitor.apk"
}

if (Test-Path $apk) {
    Write-Host "Creating release with APK..."
    gh release create v1.0.0 $apk --title "CGM Monitor v1.0.0" --notes "Install APK on Android. Activate Libre sensor with official app first, then scan via NFC tab."
} else {
    Write-Host "APK not found — skip release or build with: flutter build apk --release"
}

Write-Host "Done: https://github.com/rkhaaleed-ship-it/cgm-monitor"
