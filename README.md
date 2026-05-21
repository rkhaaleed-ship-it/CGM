# CGM Monitor

Companion Flutter app for continuous glucose monitoring (CGM), inspired by xDrip+.

## Features

- **3 screens**: Home dashboard, NFC scan, Settings
- **Arabic & English** with RTL support
- **NFC** reading for FreeStyle Libre sensors
- **Bluetooth LE** for real-time CGM data
- **xDrip+ / Nightscout** API broadcast to main app
- **OOP architecture**: models, services, providers

## Quick start (for colleagues)

### Option A — Install APK (easiest)

1. Download `CGM-Monitor.apk` from [Releases](https://github.com/rkhaaleed-ship-it/CGM/releases) (or ask for the file directly).
2. Enable **Install from unknown sources** on Android.
3. Install and open the app.
4. Activate the Libre sensor with the official app first, then use **NFC** tab to scan.

### Option B — Build from source

```bash
git clone https://github.com/rkhaaleed-ship-it/CGM.git
cd CGM
flutter pub get
flutter gen-l10n
flutter run
```

Release APK:

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Run

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Project Structure

```
lib/
├── core/           # Interfaces & utilities
├── models/         # GlucoseReading, AlertSettings, SensorInfo
├── services/       # NFC, BLE, Data, API, Settings
├── providers/      # CgmProvider (state)
├── screens/        # Home, NFC, Settings
├── widgets/        # Charts, navigation, toggles
├── theme/          # Dark xDrip theme
└── l10n/           # AR / EN translations
```

## Notes

- On emulator/desktop without NFC, demo mode simulates sensor readings.
- Configure xDrip URL in Settings for API broadcast.
- Requires physical device with NFC for real Libre sensor scans.
