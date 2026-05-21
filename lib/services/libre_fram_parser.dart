import '../models/glucose_reading.dart';
import '../models/libre_read_result.dart';
import '../models/libre_sensor_type.dart';

/// Parses FreeStyle Libre FRAM (344 bytes) into glucose readings.
class LibreFramParser {
  LibreFramParser._();

  static const int framSize = 344;
  static const int trendIndexByte = 26;
  static const int trendDataStart = 28;
  static const int historyIndexByte = 27;
  static const int historyDataStart = 124;
  static const int trendCount = 16;
  static const int historyCount = 32;
  static const int recordSize = 6;
  static const int sensorAgeLo = 316;
  static const int sensorAgeHi = 317;

  static double glucoseFromBytes(int byteHi, int byteLo) {
    final raw = ((byteHi * 256 + byteLo) & 0x0FFF);
    return raw / 10.0;
  }

  static bool _isValidReading(double mgDl) => mgDl >= 20 && mgDl <= 500;

  static int sensorAgeMinutes(List<int> fram) {
    if (fram.length < sensorAgeHi + 1) return 0;
    return fram[sensorAgeLo] + (fram[sensorAgeHi] << 8);
  }

  static LibreReadResult? parse(
    List<int> fram, {
    LibreSensorType sensorType = LibreSensorType.unknown,
    List<int>? patchUid,
    List<int>? patchInfo,
    String? bleDeviceName,
    String? bleMac,
    List<int> btUnlockPayload = const [],
  }) {
    if (fram.length < framSize) return null;

    final age = sensorAgeMinutes(fram);
    if (age <= 0) return null;

    final state = LibreSensorState.fromFram(fram);
    if (state == LibreSensorState.warmingUp) {
      return LibreReadResult.warmingUp(
        sensorType: sensorType,
        sensorAgeMinutes: age,
        sensorState: state,
      );
    }

    final history = _parseTrendHistory(fram, useTrend: false);
    final trend = _parseTrendHistory(fram, useTrend: true);
    final all = [...history, ...trend]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (all.isEmpty) return null;

    return LibreReadResult(
      currentGlucoseMgDl: all.last.valueMgDl,
      sensorAgeMinutes: age,
      trendIndex: fram[trendIndexByte] & 0xFF,
      history: all,
      rawFram: fram,
      sensorType: sensorType.displayName,
      libreSensorType: sensorType,
      patchUid: patchUid ?? [],
      patchInfo: patchInfo ?? [],
      sensorState: state,
      bleDeviceName: bleDeviceName,
      bleMac: bleMac,
      btUnlockPayload: btUnlockPayload,
    );
  }

  static LibreReadResult? parseFromOop({
    required List<int> decryptedFram,
    required List<int> trendBg,
    required List<int> historicBg,
    required LibreSensorType sensorType,
    List<int>? patchUid,
    List<int>? patchInfo,
    String? bleDeviceName,
    String? bleMac,
    List<int> btUnlockPayload = const [],
  }) {
    final fram = decryptedFram;
    final age = sensorAgeMinutes(fram);
    if (age <= 0 && trendBg.isEmpty) return null;

    final now = DateTime.now();
    final readings = <GlucoseReading>[];

    for (var i = 0; i < trendBg.length; i++) {
      final mg = trendBg[i].toDouble();
      if (!_isValidReading(mg)) continue;
      readings.add(GlucoseReading(
        timestamp: now.subtract(Duration(minutes: i)),
        valueMgDl: mg,
        source: ReadingSource.nfc,
      ));
    }

    for (var i = 0; i < historicBg.length; i++) {
      final mg = historicBg[i].toDouble();
      if (!_isValidReading(mg)) continue;
      readings.add(GlucoseReading(
        timestamp: now.subtract(Duration(minutes: 15 * (i + 1))),
        valueMgDl: mg,
        source: ReadingSource.nfc,
      ));
    }

    if (readings.isEmpty) return null;
    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return LibreReadResult(
      currentGlucoseMgDl: readings.last.valueMgDl,
      sensorAgeMinutes: age,
      trendIndex: fram.length > trendIndexByte ? fram[trendIndexByte] & 0xFF : 0,
      history: readings,
      rawFram: fram,
      sensorType: sensorType.displayName,
      libreSensorType: sensorType,
      patchUid: patchUid ?? [],
      patchInfo: patchInfo ?? [],
      sensorState: LibreSensorState.fromFram(fram),
      bleDeviceName: bleDeviceName,
      bleMac: bleMac,
      btUnlockPayload: btUnlockPayload,
      decodedViaOop: true,
    );
  }

  static List<GlucoseReading> _parseTrendHistory(List<int> fram, {required bool useTrend}) {
    final now = DateTime.now();
    final indexByte = useTrend ? trendIndexByte : historyIndexByte;
    final dataStart = useTrend ? trendDataStart : historyDataStart;
    final count = useTrend ? trendCount : historyCount;
    final intervalMin = useTrend ? 1 : 15;

    final ringIndex = fram[indexByte] & 0xFF;
    final readings = <GlucoseReading>[];

    for (var i = 0; i < count; i++) {
      var idx = ringIndex - i - 1;
      if (idx < 0) idx += count;

      final offset = dataStart + idx * recordSize;
      if (offset + 1 >= fram.length) continue;

      final mgDl = glucoseFromBytes(fram[offset + 1], fram[offset]);
      if (!_isValidReading(mgDl)) continue;

      readings.add(GlucoseReading(
        timestamp: now.subtract(Duration(minutes: i * intervalMin)),
        valueMgDl: mgDl,
        source: ReadingSource.nfc,
      ));
    }
    return readings;
  }

  static double? parseGlucose(List<int> data) => parse(data)?.currentGlucoseMgDl;
}
