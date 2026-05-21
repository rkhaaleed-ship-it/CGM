# CGM Monitor

Companion Flutter app for continuous glucose monitoring (CGM), inspired by xDrip+.

## Features

- **3 screens**: Home dashboard, NFC scan, Settings
- **Arabic & English** with RTL support
- **NFC** reading for FreeStyle Libre sensors
- **Bluetooth LE** for real-time CGM data
- **xDrip+ / Nightscout** API broadcast to main app
- **OOP architecture**: models, services, providers

## Run

```bash
cd cgm_monitor
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
