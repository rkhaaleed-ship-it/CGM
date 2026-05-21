import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CGM Monitor'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @nfc.
  ///
  /// In en, this message translates to:
  /// **'NFC'**
  String get nfc;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @nfcReading.
  ///
  /// In en, this message translates to:
  /// **'NFC Scan'**
  String get nfcReading;

  /// No description provided for @waitingForSensor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for sensor…'**
  String get waitingForSensor;

  /// No description provided for @autoScanHint.
  ///
  /// In en, this message translates to:
  /// **'Hold phone on sensor — auto scan'**
  String get autoScanHint;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @readSuccess.
  ///
  /// In en, this message translates to:
  /// **'Read Successful'**
  String get readSuccess;

  /// No description provided for @placePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Place the back of your phone on the Libre 2+ sensor'**
  String get placePhoneHint;

  /// No description provided for @sendToHome.
  ///
  /// In en, this message translates to:
  /// **'Send to Home'**
  String get sendToHome;

  /// No description provided for @readAgain.
  ///
  /// In en, this message translates to:
  /// **'Read Again'**
  String get readAgain;

  /// No description provided for @nfcSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'✓ Successful NFC reading'**
  String get nfcSuccessLabel;

  /// No description provided for @avg24h.
  ///
  /// In en, this message translates to:
  /// **'Average (24h)'**
  String get avg24h;

  /// No description provided for @last3Readings.
  ///
  /// In en, this message translates to:
  /// **'Last 3 readings'**
  String get last3Readings;

  /// No description provided for @sensorRemaining.
  ///
  /// In en, this message translates to:
  /// **'Sensor remaining'**
  String get sensorRemaining;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @justNowNfc.
  ///
  /// In en, this message translates to:
  /// **'Just now — from NFC 📡'**
  String get justNowNfc;

  /// No description provided for @expectedDropIn.
  ///
  /// In en, this message translates to:
  /// **'Expected drop in: {mins} min'**
  String expectedDropIn(int mins);

  /// No description provided for @expectedRiseIn.
  ///
  /// In en, this message translates to:
  /// **'Expected rise in: {mins} min'**
  String expectedRiseIn(int mins);

  /// No description provided for @inTargetRange.
  ///
  /// In en, this message translates to:
  /// **'In target range ✓'**
  String get inTargetRange;

  /// No description provided for @lowTrend.
  ///
  /// In en, this message translates to:
  /// **'Low ↓ below range'**
  String get lowTrend;

  /// No description provided for @highTrend.
  ///
  /// In en, this message translates to:
  /// **'High ↑ above range'**
  String get highTrend;

  /// No description provided for @inTargetTrend.
  ///
  /// In en, this message translates to:
  /// **'In target range →'**
  String get inTargetTrend;

  /// No description provided for @avg.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get avg;

  /// No description provided for @tir.
  ///
  /// In en, this message translates to:
  /// **'TIR%'**
  String get tir;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @hours24.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get hours24;

  /// No description provided for @hour1.
  ///
  /// In en, this message translates to:
  /// **'1h'**
  String get hour1;

  /// No description provided for @hour3.
  ///
  /// In en, this message translates to:
  /// **'3h'**
  String get hour3;

  /// No description provided for @hour6.
  ///
  /// In en, this message translates to:
  /// **'6h'**
  String get hour6;

  /// No description provided for @hour12.
  ///
  /// In en, this message translates to:
  /// **'12h'**
  String get hour12;

  /// No description provided for @hour24.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get hour24;

  /// No description provided for @sensorStatus.
  ///
  /// In en, this message translates to:
  /// **'Sensor Status'**
  String get sensorStatus;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @lastReading.
  ///
  /// In en, this message translates to:
  /// **'Last reading'**
  String get lastReading;

  /// No description provided for @lastValue.
  ///
  /// In en, this message translates to:
  /// **'Last value'**
  String get lastValue;

  /// No description provided for @signalStrength.
  ///
  /// In en, this message translates to:
  /// **'Signal strength'**
  String get signalStrength;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Data Source'**
  String get dataSource;

  /// No description provided for @xdripApi.
  ///
  /// In en, this message translates to:
  /// **'xDrip+ API'**
  String get xdripApi;

  /// No description provided for @nightscout.
  ///
  /// In en, this message translates to:
  /// **'Nightscout'**
  String get nightscout;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @notEnabled.
  ///
  /// In en, this message translates to:
  /// **'Not enabled'**
  String get notEnabled;

  /// No description provided for @directNfc.
  ///
  /// In en, this message translates to:
  /// **'NFC + BLE'**
  String get directNfc;

  /// No description provided for @nfcDirectSub.
  ///
  /// In en, this message translates to:
  /// **'Libre 2+'**
  String get nfcDirectSub;

  /// No description provided for @alertLimits.
  ///
  /// In en, this message translates to:
  /// **'Alert Limits'**
  String get alertLimits;

  /// No description provided for @critLow.
  ///
  /// In en, this message translates to:
  /// **'Critical Low 🚨'**
  String get critLow;

  /// No description provided for @lowAlert.
  ///
  /// In en, this message translates to:
  /// **'Low ⚠️'**
  String get lowAlert;

  /// No description provided for @highAlert.
  ///
  /// In en, this message translates to:
  /// **'High ⚠️'**
  String get highAlert;

  /// No description provided for @critHigh.
  ///
  /// In en, this message translates to:
  /// **'Critical High 🚨'**
  String get critHigh;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @alertsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Alerts enabled'**
  String get alertsEnabled;

  /// No description provided for @soundVibrate.
  ///
  /// In en, this message translates to:
  /// **'Sound + vibration'**
  String get soundVibrate;

  /// No description provided for @nightMode.
  ///
  /// In en, this message translates to:
  /// **'Night mode'**
  String get nightMode;

  /// No description provided for @nightModeSub.
  ///
  /// In en, this message translates to:
  /// **'11pm – 7am quieter'**
  String get nightModeSub;

  /// No description provided for @rapidDrop.
  ///
  /// In en, this message translates to:
  /// **'Rapid drop'**
  String get rapidDrop;

  /// No description provided for @rapidDropSub.
  ///
  /// In en, this message translates to:
  /// **'>2 mg/dL/min'**
  String get rapidDropSub;

  /// No description provided for @rapidRise.
  ///
  /// In en, this message translates to:
  /// **'Rapid rise'**
  String get rapidRise;

  /// No description provided for @rapidRiseSub.
  ///
  /// In en, this message translates to:
  /// **'>2 mg/dL/min'**
  String get rapidRiseSub;

  /// No description provided for @sendToMainApp.
  ///
  /// In en, this message translates to:
  /// **'Send to Main App'**
  String get sendToMainApp;

  /// No description provided for @xdripBroadcast.
  ///
  /// In en, this message translates to:
  /// **'xDrip Broadcast'**
  String get xdripBroadcast;

  /// No description provided for @autoSend.
  ///
  /// In en, this message translates to:
  /// **'Auto send'**
  String get autoSend;

  /// No description provided for @nightscoutUrl.
  ///
  /// In en, this message translates to:
  /// **'Nightscout URL'**
  String get nightscoutUrl;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @versionSub.
  ///
  /// In en, this message translates to:
  /// **'CGM Companion v1.0.0'**
  String get versionSub;

  /// No description provided for @flutterFramework.
  ///
  /// In en, this message translates to:
  /// **'Flutter Framework'**
  String get flutterFramework;

  /// No description provided for @flutterSub.
  ///
  /// In en, this message translates to:
  /// **'Android + iOS'**
  String get flutterSub;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @bluetoothScan.
  ///
  /// In en, this message translates to:
  /// **'Scan for sensor'**
  String get bluetoothScan;

  /// No description provided for @bluetoothConnected.
  ///
  /// In en, this message translates to:
  /// **'BLE Connected'**
  String get bluetoothConnected;

  /// No description provided for @alertLowCrit.
  ///
  /// In en, this message translates to:
  /// **'Critical! Very low glucose: {val} mg/dL'**
  String alertLowCrit(int val);

  /// No description provided for @alertLow.
  ///
  /// In en, this message translates to:
  /// **'Warning: Low glucose {val} mg/dL'**
  String alertLow(int val);

  /// No description provided for @alertHighCrit.
  ///
  /// In en, this message translates to:
  /// **'Critical! Very high glucose: {val} mg/dL'**
  String alertHighCrit(int val);

  /// No description provided for @alertHigh.
  ///
  /// In en, this message translates to:
  /// **'Warning: High glucose {val} mg/dL'**
  String alertHigh(int val);

  /// No description provided for @daysHours.
  ///
  /// In en, this message translates to:
  /// **'{days} days {hours} hours'**
  String daysHours(int days, int hours);

  /// No description provided for @nowTime.
  ///
  /// In en, this message translates to:
  /// **'Now — {time}'**
  String nowTime(String time);

  /// No description provided for @nfcNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'NFC is not available on this device'**
  String get nfcNotAvailable;

  /// No description provided for @nfcDisabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable NFC in settings'**
  String get nfcDisabled;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed — try again'**
  String get scanFailed;

  /// No description provided for @configureUrl.
  ///
  /// In en, this message translates to:
  /// **'Configure ›'**
  String get configureUrl;

  /// No description provided for @mgdl.
  ///
  /// In en, this message translates to:
  /// **'mg/dL'**
  String get mgdl;

  /// No description provided for @mmoll.
  ///
  /// In en, this message translates to:
  /// **'mmol/L'**
  String get mmoll;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @scanningBle.
  ///
  /// In en, this message translates to:
  /// **'Scanning Bluetooth...'**
  String get scanningBle;

  /// No description provided for @scanTimeout.
  ///
  /// In en, this message translates to:
  /// **'Scan timed out — hold phone on sensor longer'**
  String get scanTimeout;

  /// No description provided for @sensorNotActive.
  ///
  /// In en, this message translates to:
  /// **'Sensor not active — activate with Libre app first'**
  String get sensorNotActive;

  /// No description provided for @sensorWarmingUp.
  ///
  /// In en, this message translates to:
  /// **'Sensor warming up — wait until ready (≈60 min for 2+)'**
  String get sensorWarmingUp;

  /// No description provided for @oop2Required.
  ///
  /// In en, this message translates to:
  /// **'Install OOP2 app'**
  String get oop2Required;

  /// No description provided for @systemReadiness.
  ///
  /// In en, this message translates to:
  /// **'System check'**
  String get systemReadiness;

  /// No description provided for @checkPlatformOk.
  ///
  /// In en, this message translates to:
  /// **'Android device OK'**
  String get checkPlatformOk;

  /// No description provided for @checkPlatform.
  ///
  /// In en, this message translates to:
  /// **'Libre 2+ requires Android phone'**
  String get checkPlatform;

  /// No description provided for @checkOop2Ok.
  ///
  /// In en, this message translates to:
  /// **'OOP2 decoder installed'**
  String get checkOop2Ok;

  /// No description provided for @checkOop2Missing.
  ///
  /// In en, this message translates to:
  /// **'OOP2 not installed — required for Libre 2+'**
  String get checkOop2Missing;

  /// No description provided for @checkNfcOk.
  ///
  /// In en, this message translates to:
  /// **'NFC available'**
  String get checkNfcOk;

  /// No description provided for @checkNfcMissing.
  ///
  /// In en, this message translates to:
  /// **'NFC unavailable — enable in settings'**
  String get checkNfcMissing;

  /// No description provided for @checkBleOk.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth ready'**
  String get checkBleOk;

  /// No description provided for @refreshChecks.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshChecks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
