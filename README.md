# CGM Monitor

Flutter app for **FreeStyle Libre 2+** continuous glucose monitoring — xDrip-style UI with NFC scan and BLE streaming. Uses **OOP2** for Abbott-encrypted sensor data (same approach as xDrip+).

## Features

- **2 screens**: Home dashboard + NFC auto-scan
- **Arabic & English** with RTL support
- **Libre 2+**: NFC read (ISO15693) + BLE streaming every ~5 min
- **OOP2 bridge** on Android for FRAM decrypt and BLE unlock
- **Auto NFC**: open NFC tab → hold phone on sensor (no tap)
- **Auto home**: successful scan sends readings to dashboard
- Dark xDrip-inspired UI

## Requirements (real sensor)

| Requirement | Why |
|-------------|-----|
| Android phone with **NFC** | Emulator/desktop cannot scan sensors |
| **OOP2** app installed | Libre 2+ data is encrypted by Abbott |
| Sensor activated in **Libre official app** | Must be started before third-party read |
| Sensor past **warm-up** (~60 min) | Readings unavailable during warm-up |
| **Bluetooth** enabled | Continuous updates after first NFC scan |

Recommended OOP2 package: `com.hg4.oopalgorithm.oopalgorithm2`  
Setup guide: [AndroidAPS Libre 2 docs](https://androidaps.readthedocs.io/en/latest/CompatibleCgms/Libre2.html)

## Quick start

### Install APK

1. Download `app-release.apk` from [Releases](https://github.com/rkhaaleed-ship-it/CGM/releases)
2. Enable **Install from unknown sources** on Android
3. Install **OOP2** on the same phone
4. Activate sensor with Libre app, wait for warm-up
5. Open CGM Monitor → **NFC** tab → hold phone on sensor 5–8 seconds

### Build from source

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

## How it works

1. **NFC tab** — continuous scan while tab is open
2. **OOP2** decrypts FRAM + provides BLE unlock payload
3. **BLE** connects to Abbott GATT (`fde3` / `fde1` / `fde2`) for live readings
4. **Home** shows glucose, chart, TIR stats (no fake demo data)

## Project structure

```
lib/
├── core/              # Glucose colors, sensor interfaces
├── models/            # Readings, Libre sensor types, FRAM results
├── services/          # NFC, BLE, OOP2, glucose data
├── providers/         # CgmProvider (app state)
├── screens/           # Home, NFC
├── widgets/           # Charts, bottom nav, top bar
├── theme/             # Dark theme
└── l10n/              # AR / EN

android/.../LibreOopBridge.kt   # OOP2 MethodChannel (xDrip broadcasts)
```

## Troubleshooting

| Message | Fix |
|---------|-----|
| Install OOP2 app | Install OOP2 decoder on Android |
| Sensor warming up | Wait until Libre app shows active readings |
| Sensor not active | Activate with official Libre app first |
| NFC unavailable | Enable NFC in phone settings |
| Scan failed | Hold phone longer; retry NFC tab |

## Notes

- **Android only** for Libre 2+ + OOP2 (iOS not supported for this flow)
- App is **not** a medical device — supportive monitoring only
- Not tested on every regional Libre 2+ variant; report issues on GitHub

## License

Graduation / personal project — use at your own risk.
