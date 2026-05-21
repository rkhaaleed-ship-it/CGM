// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CGM Monitor';

  @override
  String get home => 'الرئيسية';

  @override
  String get nfc => 'NFC';

  @override
  String get settings => 'الإعدادات';

  @override
  String get nfcReading => 'قراءة NFC';

  @override
  String get tapToRead => 'اضغط للقراءة';

  @override
  String get searching => 'جاري البحث...';

  @override
  String get readSuccess => 'تمت القراءة ✓';

  @override
  String get placePhoneHint =>
      'ضع الجانب الخلفي من الموبايل\nفوق السيسنور مباشرة';

  @override
  String get libreCompat => 'Libre 1 / Libre 2 (with patch)';

  @override
  String get sendToHome => 'إرسال للرئيسية';

  @override
  String get readAgain => 'قراءة مجدداً';

  @override
  String get nfcSuccessLabel => '✓ قراءة ناجحة من NFC';

  @override
  String get avg24h => 'المتوسط (24س)';

  @override
  String get last3Readings => 'آخر 3 قراءات';

  @override
  String get sensorRemaining => 'متبقي للسيسنور';

  @override
  String get systemRequirements => 'متطلبات النظام:';

  @override
  String get reqAndroid => '• Android 8.0+ مع NFC مفعّل';

  @override
  String get reqIos => '• iOS 14+ مع Core NFC';

  @override
  String get reqLibre1 => '• Libre 1: قراءة مباشرة ✓';

  @override
  String get reqLibre2 => '• Libre 2: تحتاج xDrip patch ✓';

  @override
  String get reqPermission => '• امنح إذن NFC من الإعدادات';

  @override
  String get medicalWarningTitle => '⚠️ تنبيه طبي:';

  @override
  String get medicalWarningBody =>
      'هذا التطبيق للمراقبة المساعدة فقط.\nلا تعتمد عليه لأي قرارات علاجية.\nاستشر طبيبك دائماً.';

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقائق';
  }

  @override
  String get justNow => 'الآن';

  @override
  String get justNowNfc => 'للتو — من NFC 📡';

  @override
  String expectedDropIn(int mins) {
    return 'انخفاض متوقع في: $mins دقيقة';
  }

  @override
  String expectedRiseIn(int mins) {
    return 'ارتفاع متوقع في: $mins دقيقة';
  }

  @override
  String get inTargetRange => 'في النطاق المستهدف ✓';

  @override
  String get lowTrend => 'منخفض ↓ تحت النطاق';

  @override
  String get highTrend => 'مرتفع ↑ فوق النطاق';

  @override
  String get inTargetTrend => 'في النطاق المستهدف →';

  @override
  String get avg => 'متوسط';

  @override
  String get tir => 'TIR%';

  @override
  String get high => 'أعلى';

  @override
  String get low => 'أقل';

  @override
  String get hours24 => '24 ساعة';

  @override
  String get hour1 => '1س';

  @override
  String get hour3 => '3س';

  @override
  String get hour6 => '6س';

  @override
  String get hour12 => '12س';

  @override
  String get hour24 => '24س';

  @override
  String get sensorStatus => 'حالة السيسنور';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get remaining => 'المتبقي';

  @override
  String get lastReading => 'آخر قراءة';

  @override
  String get lastValue => 'آخر قيمة';

  @override
  String get signalStrength => 'قوة الإشارة';

  @override
  String get excellent => 'ممتاز';

  @override
  String get dataSource => 'مصدر البيانات';

  @override
  String get xdripApi => 'xDrip+ API';

  @override
  String get nightscout => 'Nightscout';

  @override
  String get backup => 'نسخة احتياطية';

  @override
  String get notEnabled => 'غير مفعّل';

  @override
  String get directNfc => 'NFC مباشر';

  @override
  String get libre1Only => 'Libre 1 فقط';

  @override
  String get alertLimits => 'حدود التنبيه';

  @override
  String get critLow => 'منخفض خطر 🚨';

  @override
  String get lowAlert => 'منخفض ⚠️';

  @override
  String get highAlert => 'مرتفع ⚠️';

  @override
  String get critHigh => 'مرتفع خطر 🚨';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get alertsEnabled => 'تنبيهات مفعّلة';

  @override
  String get soundVibrate => 'صوت + اهتزاز';

  @override
  String get nightMode => 'وضع الليل';

  @override
  String get nightModeSub => '11م – 7ص أهدى';

  @override
  String get rapidDrop => 'انخفاض سريع';

  @override
  String get rapidDropSub => '>2 mg/dL/min';

  @override
  String get rapidRise => 'ارتفاع سريع';

  @override
  String get rapidRiseSub => '>2 mg/dL/min';

  @override
  String get sendToMainApp => 'الإرسال للتطبيق الأساسي';

  @override
  String get xdripBroadcast => 'xDrip Broadcast';

  @override
  String get autoSend => 'إرسال تلقائي';

  @override
  String get nightscoutUrl => 'Nightscout URL';

  @override
  String get configure => 'ضبط';

  @override
  String get about => 'عن التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get versionSub => 'CGM Companion v1.0.0';

  @override
  String get flutterFramework => 'Flutter Framework';

  @override
  String get flutterSub => 'Android + iOS';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get bluetooth => 'بلوتوث';

  @override
  String get bluetoothScan => 'بحث عن السيسنور';

  @override
  String get bluetoothConnected => 'BLE متصل';

  @override
  String alertLowCrit(int val) {
    return 'خطر! جلوكوز منخفض جداً: $val mg/dL';
  }

  @override
  String alertLow(int val) {
    return 'تحذير: جلوكوز منخفض $val mg/dL';
  }

  @override
  String alertHighCrit(int val) {
    return 'خطر! جلوكوز مرتفع جداً: $val mg/dL';
  }

  @override
  String alertHigh(int val) {
    return 'تحذير: جلوكوز مرتفع $val mg/dL';
  }

  @override
  String daysHours(int days, int hours) {
    return '$days يوم $hours ساعة';
  }

  @override
  String nowTime(String time) {
    return 'الآن — $time';
  }

  @override
  String get nfcNotAvailable => 'NFC غير متاح على هذا الجهاز';

  @override
  String get nfcDisabled => 'يرجى تفعيل NFC من الإعدادات';

  @override
  String get scanFailed => 'فشلت القراءة — حاول مجدداً';

  @override
  String get configureUrl => 'ضبط ›';

  @override
  String get mgdl => 'mg/dL';

  @override
  String get mmoll => 'mmol/L';

  @override
  String get unit => 'الوحدة';

  @override
  String get demoMode => 'وضع تجريبي (بدون سيسنور)';

  @override
  String get scanningBle => 'جاري البحث عبر Bluetooth...';

  @override
  String get scanTimeout => 'انتهى الوقت — أبقي الموبايل على السيسنور أطول';

  @override
  String get sensorNotActive =>
      'السيسنور غير مفعّل — فعّليه من تطبيق Libre أولاً';
}
