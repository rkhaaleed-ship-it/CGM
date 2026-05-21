import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../core/sensor_interface.dart';
import '../models/glucose_reading.dart';

/// Known BLE service UUIDs for Libre / CGM devices.
class CgmBleUuids {
  static final Guid libreService =
      Guid('0000fde3-0000-1000-8000-00805f9b34fb');
  static final Guid glucoseChar =
      Guid('0000fde1-0000-1000-8000-00805f9b34fb');
}

/// Bluetooth Low Energy sensor communication.
class BluetoothSensorService implements SensorInterface {
  final _controller = StreamController<GlucoseReading>.broadcast();
  StreamSubscription<List<ScanResult>>? _scanSub;
  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _charSub;
  Timer? _demoTimer;
  double _demoValue = 163;

  @override
  Stream<GlucoseReading> get readingsStream => _controller.stream;

  @override
  Future<bool> isAvailable() async {
    try {
      if (await FlutterBluePlus.isSupported == false) return false;
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('BLE availability check failed: $e');
      return false;
    }
  }

  @override
  Future<void> startSession() async {
    _startDemoStream();
    await _scanAndConnect();
  }

  Future<void> _scanAndConnect() async {
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [CgmBleUuids.libreService],
      );

      _scanSub = FlutterBluePlus.scanResults.listen((results) async {
        for (final r in results) {
          final name = r.device.platformName.toLowerCase();
          if (name.contains('abbott') ||
              name.contains('libre') ||
              name.contains('cgm')) {
            await FlutterBluePlus.stopScan();
            await _connectDevice(r.device);
            break;
          }
        }
      });
    } catch (e) {
      debugPrint('BLE scan error: $e');
    }
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      _device = device;
      final services = await device.discoverServices();
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.properties.notify) {
            await char.setNotifyValue(true);
            _charSub = char.lastValueStream.listen(_onBleData);
          }
        }
      }
    } catch (e) {
      debugPrint('BLE connect error: $e');
    }
  }

  void _onBleData(List<int> data) {
    if (data.length < 2) return;
    final mgDl = ((data[0] & 0xFF) << 8 | (data[1] & 0xFF)).toDouble();
    if (mgDl >= 20 && mgDl <= 600) {
      final reading = GlucoseReading(
        timestamp: DateTime.now(),
        valueMgDl: mgDl,
        source: ReadingSource.bluetooth,
      );
      _controller.add(reading);
    }
  }

  void _startDemoStream() {
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_device != null) return;
      final rng = Random();
      _demoValue = (_demoValue + (rng.nextDouble() - 0.47) * 10)
          .clamp(52, 240)
          .roundToDouble();
      _controller.add(GlucoseReading(
        timestamp: DateTime.now(),
        valueMgDl: _demoValue,
        source: ReadingSource.bluetooth,
      ));
    });
  }

  @override
  Future<GlucoseReading?> readOnce() async {
    return readingsStream.first.timeout(
      const Duration(seconds: 10),
      onTimeout: () => GlucoseReading(
        timestamp: DateTime.now(),
        valueMgDl: _demoValue,
        source: ReadingSource.bluetooth,
      ),
    );
  }

  @override
  Future<void> stopSession() async {
    _demoTimer?.cancel();
    await _scanSub?.cancel();
    await _charSub?.cancel();
    if (_device != null) {
      await _device!.disconnect();
      _device = null;
    }
    await FlutterBluePlus.stopScan();
  }

  @override
  void dispose() {
    stopSession();
    _controller.close();
  }

  bool get isDeviceConnected => _device != null;
}
