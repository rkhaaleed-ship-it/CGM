// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CGM Monitor';

  @override
  String get home => 'Home';

  @override
  String get nfc => 'NFC';

  @override
  String get settings => 'Settings';

  @override
  String get nfcReading => 'NFC Reading';

  @override
  String get tapToRead => 'Tap to Read';

  @override
  String get searching => 'Searching...';

  @override
  String get readSuccess => 'Read Successful';

  @override
  String get placePhoneHint =>
      'Place the back of your phone\ndirectly over the sensor';

  @override
  String get libreCompat => 'Libre 1 / Libre 2 (with patch)';

  @override
  String get sendToHome => 'Send to Home';

  @override
  String get readAgain => 'Read Again';

  @override
  String get nfcSuccessLabel => '✓ Successful NFC reading';

  @override
  String get avg24h => 'Average (24h)';

  @override
  String get last3Readings => 'Last 3 readings';

  @override
  String get sensorRemaining => 'Sensor remaining';

  @override
  String get systemRequirements => 'System Requirements:';

  @override
  String get reqAndroid => '• Android 8.0+ with NFC enabled';

  @override
  String get reqIos => '• iOS 14+ with Core NFC';

  @override
  String get reqLibre1 => '• Libre 1: Direct reading ✓';

  @override
  String get reqLibre2 => '• Libre 2: Requires xDrip patch ✓';

  @override
  String get reqPermission => '• Grant NFC permission in settings';

  @override
  String get medicalWarningTitle => '⚠ Medical Notice:';

  @override
  String get medicalWarningBody =>
      'This app is for supportive monitoring only.\nDo not rely on it for treatment decisions.\nAlways consult your doctor.';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get justNowNfc => 'Just now — from NFC 📡';

  @override
  String expectedDropIn(int mins) {
    return 'Expected drop in: $mins min';
  }

  @override
  String expectedRiseIn(int mins) {
    return 'Expected rise in: $mins min';
  }

  @override
  String get inTargetRange => 'In target range ✓';

  @override
  String get lowTrend => 'Low ↓ below range';

  @override
  String get highTrend => 'High ↑ above range';

  @override
  String get inTargetTrend => 'In target range →';

  @override
  String get avg => 'Avg';

  @override
  String get tir => 'TIR%';

  @override
  String get high => 'High';

  @override
  String get low => 'Low';

  @override
  String get hours24 => '24 hours';

  @override
  String get hour1 => '1h';

  @override
  String get hour3 => '3h';

  @override
  String get hour6 => '6h';

  @override
  String get hour12 => '12h';

  @override
  String get hour24 => '24h';

  @override
  String get sensorStatus => 'Sensor Status';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get remaining => 'Remaining';

  @override
  String get lastReading => 'Last reading';

  @override
  String get lastValue => 'Last value';

  @override
  String get signalStrength => 'Signal strength';

  @override
  String get excellent => 'Excellent';

  @override
  String get dataSource => 'Data Source';

  @override
  String get xdripApi => 'xDrip+ API';

  @override
  String get nightscout => 'Nightscout';

  @override
  String get backup => 'Backup';

  @override
  String get notEnabled => 'Not enabled';

  @override
  String get directNfc => 'Direct NFC';

  @override
  String get libre1Only => 'Libre 1 only';

  @override
  String get alertLimits => 'Alert Limits';

  @override
  String get critLow => 'Critical Low 🚨';

  @override
  String get lowAlert => 'Low ⚠️';

  @override
  String get highAlert => 'High ⚠️';

  @override
  String get critHigh => 'Critical High 🚨';

  @override
  String get notifications => 'Notifications';

  @override
  String get alertsEnabled => 'Alerts enabled';

  @override
  String get soundVibrate => 'Sound + vibration';

  @override
  String get nightMode => 'Night mode';

  @override
  String get nightModeSub => '11pm – 7am quieter';

  @override
  String get rapidDrop => 'Rapid drop';

  @override
  String get rapidDropSub => '>2 mg/dL/min';

  @override
  String get rapidRise => 'Rapid rise';

  @override
  String get rapidRiseSub => '>2 mg/dL/min';

  @override
  String get sendToMainApp => 'Send to Main App';

  @override
  String get xdripBroadcast => 'xDrip Broadcast';

  @override
  String get autoSend => 'Auto send';

  @override
  String get nightscoutUrl => 'Nightscout URL';

  @override
  String get configure => 'Configure';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get versionSub => 'CGM Companion v1.0.0';

  @override
  String get flutterFramework => 'Flutter Framework';

  @override
  String get flutterSub => 'Android + iOS';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get bluetoothScan => 'Scan for sensor';

  @override
  String get bluetoothConnected => 'BLE Connected';

  @override
  String alertLowCrit(int val) {
    return 'Critical! Very low glucose: $val mg/dL';
  }

  @override
  String alertLow(int val) {
    return 'Warning: Low glucose $val mg/dL';
  }

  @override
  String alertHighCrit(int val) {
    return 'Critical! Very high glucose: $val mg/dL';
  }

  @override
  String alertHigh(int val) {
    return 'Warning: High glucose $val mg/dL';
  }

  @override
  String daysHours(int days, int hours) {
    return '$days days $hours hours';
  }

  @override
  String nowTime(String time) {
    return 'Now — $time';
  }

  @override
  String get nfcNotAvailable => 'NFC is not available on this device';

  @override
  String get nfcDisabled => 'Please enable NFC in settings';

  @override
  String get scanFailed => 'Scan failed — try again';

  @override
  String get configureUrl => 'Configure ›';

  @override
  String get mgdl => 'mg/dL';

  @override
  String get mmoll => 'mmol/L';

  @override
  String get unit => 'Unit';

  @override
  String get demoMode => 'Demo mode (no sensor)';

  @override
  String get scanningBle => 'Scanning Bluetooth...';

  @override
  String get scanTimeout => 'Scan timed out — hold phone on sensor longer';

  @override
  String get sensorNotActive =>
      'Sensor not active — activate with Libre app first';
}
