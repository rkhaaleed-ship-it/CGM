import 'glucose_reading.dart';

/// Result of a real Libre NFC FRAM read.
class LibreReadResult {
  final double currentGlucoseMgDl;
  final int sensorAgeMinutes;
  final int trendIndex;
  final List<GlucoseReading> history;
  final List<int> rawFram;
  final String sensorType;

  const LibreReadResult({
    required this.currentGlucoseMgDl,
    required this.sensorAgeMinutes,
    required this.trendIndex,
    required this.history,
    required this.rawFram,
    this.sensorType = 'FreeStyle Libre',
  });

  bool get isValid =>
      currentGlucoseMgDl >= 20 &&
      currentGlucoseMgDl <= 500 &&
      sensorAgeMinutes > 0;
}
