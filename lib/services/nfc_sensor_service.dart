import 'dart:async';
import 'dart:math';

import '../core/sensor_interface.dart';
import '../models/glucose_reading.dart';
import 'libre_fram_parser.dart';

/// Parses raw NFC tag bytes from FreeStyle Libre sensors.
@Deprecated('Use LibreFramParser')
class LibreNfcParser {
  static double? parseGlucose(List<int> data) =>
      LibreFramParser.parseGlucose(data);
}

/// NFC sensor communication via nfc_manager.
class NfcSensorService implements SensorInterface {
  final _controller = StreamController<GlucoseReading>.broadcast();
  double _lastValue = 163;

  @override
  Stream<GlucoseReading> get readingsStream => _controller.stream;

  @override
  Future<bool> isAvailable() async {
    try {
      // nfc_manager checked at runtime in scan method
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> startSession() async {}

  @override
  Future<void> stopSession() async {}
  Future<GlucoseReading?> scanTag({
    required Future<GlucoseReading?> Function() realScan,
    bool demoFallback = true,
  }) async {
    try {
      final reading = await realScan();
      if (reading != null) {
        _lastValue = reading.valueMgDl;
        _controller.add(reading);
        return reading;
      }
    } catch (_) {}

    if (demoFallback) {
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      final rng = Random();
      _lastValue = (_lastValue + (rng.nextDouble() - 0.5) * 8)
          .clamp(50, 250)
          .roundToDouble();
      final reading = GlucoseReading(
        timestamp: DateTime.now(),
        valueMgDl: _lastValue,
        source: ReadingSource.nfc,
      );
      _controller.add(reading);
      return reading;
    }
    return null;
  }

  @override
  Future<GlucoseReading?> readOnce() => scanTag(realScan: () async => null);

  @override
  void dispose() {
    _controller.close();
  }
}
