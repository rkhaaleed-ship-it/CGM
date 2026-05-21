import '../models/glucose_reading.dart';
import '../models/libre_read_result.dart';

/// Parses FreeStyle Libre FRAM (344 bytes) into glucose readings.
/// Compatible with Libre 1 / Libre 2 / Libre 2+ NFC FRAM layout.
class LibreFramParser {
  LibreFramParser._();

  static const int framSize = 344;
  static const int trendIndexByte = 26;
  static const int trendDataStart = 124;
  static const int trendCount = 32;
  static const int trendIntervalMin = 15;
  static const int sensorAgeLo = 316;
  static const int sensorAgeHi = 317;

  /// Raw 12-bit glucose → mg/dL (scaling factor 10).
  static double glucoseFromBytes(int byteHi, int byteLo) {
    final raw = ((byteHi * 256 + byteLo) & 0x0FFF);
    return raw / 10.0;
  }

  static bool _isValidReading(double mgDl) =>
      mgDl >= 20 && mgDl <= 500;

  static LibreReadResult? parse(List<int> fram) {
    if (fram.length < framSize) return null;

    final sensorAgeMinutes = fram[sensorAgeLo] + (fram[sensorAgeHi] << 8);
    if (sensorAgeMinutes <= 0) return null;

    final trendIndex = fram[trendIndexByte] & 0xFF;
    final now = DateTime.now();

    final history = <GlucoseReading>[];
    for (var i = 0; i < trendCount; i++) {
      var idx = trendIndex - i - 1;
      if (idx < 0) idx += trendCount;

      final offset = trendDataStart + idx * 6;
      if (offset + 1 >= fram.length) continue;

      final mgDl = glucoseFromBytes(fram[offset + 1], fram[offset]);
      if (!_isValidReading(mgDl)) continue;

      final minutesAgo = i * trendIntervalMin;
      history.add(GlucoseReading(
        timestamp: now.subtract(Duration(minutes: minutesAgo)),
        valueMgDl: mgDl,
        source: ReadingSource.nfc,
      ));
    }

    if (history.isEmpty) return null;

    history.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final current = history.last.valueMgDl;
    final sensorType = fram.length >= 344 ? 'FreeStyle Libre 2/2+' : 'FreeStyle Libre';

    return LibreReadResult(
      currentGlucoseMgDl: current,
      sensorAgeMinutes: sensorAgeMinutes,
      trendIndex: trendIndex,
      history: history,
      rawFram: fram,
      sensorType: sensorType,
    );
  }

  /// Legacy single-value parse (fallback).
  static double? parseGlucose(List<int> data) {
    final result = parse(data);
    return result?.currentGlucoseMgDl;
  }
}
