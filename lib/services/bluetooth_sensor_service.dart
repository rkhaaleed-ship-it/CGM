import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../core/sensor_interface.dart';
import '../models/glucose_reading.dart';
import 'libre_oop_service.dart';
import 'libre_sensor_store.dart';

/// Libre 2 / 2+ BLE — Abbott GATT + OOP2 decryption (xDrip-compatible).
class CgmBleUuids {
  static final Guid libreService = Guid('0000fde3-0000-1000-8000-00805f9b34fb');
  static final Guid glucoseNotify = Guid('0000fde1-0000-1000-8000-00805f9b34fb');
  static final Guid glucoseWrite = Guid('0000fde2-0000-1000-8000-00805f9b34fb');
}

class BluetoothSensorService implements SensorInterface {
  BluetoothSensorService();

  final _controller = StreamController<GlucoseReading>.broadcast();
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _charSub;
  LibreSensorContext? _context;
  List<int> _btUnlockPayload = [];
  bool _libreMode = false;

  @override
  Stream<GlucoseReading> get readingsStream => _controller.stream;

  bool get isDeviceConnected => _device != null;
  bool get isLibreMode => _libreMode;

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
    _context = await LibreSensorStore.load();
    if (_context != null) {
      _libreMode = true;
      await _connectLibreFromContext(_context!);
    }
  }

  Future<void> configureLibreSensor({
    required List<int> patchUid,
    required List<int> patchInfo,
    String? deviceName,
    String? bleMac,
    List<int>? btUnlockPayload,
  }) async {
    _libreMode = true;
    _btUnlockPayload = btUnlockPayload ?? [];
    _context = LibreSensorContext(
      patchUid: patchUid,
      patchInfo: patchInfo,
      deviceName: deviceName,
      bleMac: bleMac,
    );
    await LibreSensorStore.save(
      patchUid: patchUid,
      patchInfo: patchInfo,
      deviceName: deviceName,
      bleMac: bleMac,
    );
    await _connectLibreFromContext(_context!);
  }

  Future<void> connectToLibreDevice(String deviceHint, {List<int>? btUnlock}) async {
    if (btUnlock != null) _btUnlockPayload = btUnlock;
    _libreMode = true;
    _context ??= await LibreSensorStore.load();

    try {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 25));

      _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) async {
        for (final r in results) {
          final name = r.device.platformName;
          final adv = r.advertisementData.advName;
          final mac = r.device.remoteId.str.toLowerCase();
          final hint = deviceHint.toLowerCase();
          if (name.toLowerCase().contains(hint) ||
              adv.toLowerCase().contains(hint) ||
              name.toLowerCase().contains('abbott') ||
              adv.toLowerCase().contains('abbott') ||
              (_context?.bleMac != null && mac.contains(_context!.bleMac!.toLowerCase()))) {
            await FlutterBluePlus.stopScan();
            await _connectDevice(r.device);
            break;
          }
        }
      });
    } catch (e) {
      debugPrint('Libre BLE connect error: $e');
    }
  }

  Future<void> _connectLibreFromContext(LibreSensorContext ctx) async {
    if (ctx.bleMac != null && ctx.bleMac!.isNotEmpty) {
      try {
        final device = BluetoothDevice.fromId(ctx.bleMac!);
        await _connectDevice(device);
        return;
      } catch (e) {
        debugPrint('Direct MAC connect failed: $e');
      }
    }
    if (ctx.deviceName != null && ctx.deviceName!.isNotEmpty) {
      await connectToLibreDevice(ctx.deviceName!);
    }
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: true, timeout: const Duration(seconds: 20));
      _device = device;
      _connSub?.cancel();
      _connSub = device.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected) {
          _device = null;
          if (_libreMode && _context != null) {
            Future<void>.delayed(const Duration(seconds: 3), () {
              _connectLibreFromContext(_context!);
            });
          }
        }
      });

      final services = await device.discoverServices();
      BluetoothCharacteristic? notifyChar;
      BluetoothCharacteristic? writeChar;

      for (final service in services) {
        if (service.uuid != CgmBleUuids.libreService &&
            !service.uuid.str.toLowerCase().contains('fde3')) {
          continue;
        }
        for (final char in service.characteristics) {
          if (char.uuid == CgmBleUuids.glucoseNotify ||
              char.uuid.str.toLowerCase().contains('fde1')) {
            notifyChar = char;
          }
          if (char.uuid == CgmBleUuids.glucoseWrite ||
              char.uuid.str.toLowerCase().contains('fde2')) {
            writeChar = char;
          }
        }
      }

      if (_btUnlockPayload.isNotEmpty && writeChar != null) {
        await writeChar.write(_btUnlockPayload, withoutResponse: true);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }

      if (notifyChar != null) {
        await notifyChar.setNotifyValue(true);
        await _charSub?.cancel();
        _charSub = notifyChar.lastValueStream.listen(_onBleData);
        debugPrint('Libre BLE: subscribed to ${notifyChar.uuid}');
      } else {
        for (final service in services) {
          for (final char in service.characteristics) {
            if (char.properties.notify) {
              await char.setNotifyValue(true);
              _charSub = char.lastValueStream.listen(_onBleData);
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('BLE connect error: $e');
    }
  }

  Future<void> _onBleData(List<int> data) async {
    if (data.isEmpty) return;

    if (_libreMode && _context != null && data.length >= 46 && LibreOopService.isSupported) {
      final decoded = await LibreOopService.decodeBle(
        blePacket: data,
        patchUid: _context!.patchUid,
      );
      if (decoded != null && decoded.currentMgDl >= 20 && decoded.currentMgDl <= 500) {
        _emitReading(decoded.currentMgDl);
        return;
      }
    }

    if (data.length >= 2) {
      final mgDl = ((data[0] & 0xFF) << 8 | (data[1] & 0xFF)).toDouble();
      if (mgDl >= 20 && mgDl <= 600) {
        _emitReading(mgDl);
      }
    }
  }

  void _emitReading(double mgDl) {
    _controller.add(GlucoseReading(
      timestamp: DateTime.now(),
      valueMgDl: mgDl,
      source: ReadingSource.bluetooth,
    ));
  }

  @override
  Future<GlucoseReading?> readOnce() async {
    return readingsStream.first.timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException('No BLE reading'),
    );
  }

  @override
  Future<void> stopSession() async {
    await _scanSub?.cancel();
    await _charSub?.cancel();
    await _connSub?.cancel();
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
}
