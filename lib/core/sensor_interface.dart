import '../models/glucose_reading.dart';

/// Abstract contract for all CGM sensor communication channels.
abstract class SensorInterface {
  Future<bool> isAvailable();
  Future<void> startSession();
  Future<void> stopSession();
  Future<GlucoseReading?> readOnce();
  Stream<GlucoseReading> get readingsStream;
  void dispose();
}
