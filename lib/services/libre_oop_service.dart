import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android bridge to OOP2 for Libre 2 / 2+ FRAM decryption and BLE unlock.
class LibreOopService {
  LibreOopService._();

  static const _channel = MethodChannel('com.cgm.cgm_monitor/libre_oop');

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<bool> isOop2Installed() async {
    if (!isSupported) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isOop2Installed');
      return result ?? false;
    } catch (e) {
      debugPrint('LibreOopService.isOop2Installed: $e');
      return false;
    }
  }

  static Future<List<String>> installedOopPackages() async {
    if (!isSupported) return [];
    try {
      final result = await _channel.invokeMethod<List<Object?>>('installedOopPackages');
      return result?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('LibreOopService.installedOopPackages: $e');
      return [];
    }
  }

  /// Decrypt Libre 2/2+ FRAM via OOP2. Returns glucose arrays or null on failure.
  static Future<OopDecodeResult?> decodeFram({
    required List<int> fram,
    required List<int> patchUid,
    required List<int> patchInfo,
  }) async {
    if (!isSupported || fram.length < 344) return null;
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('decodeFram', {
        'fram': Uint8List.fromList(fram),
        'patchUid': Uint8List.fromList(patchUid),
        'patchInfo': Uint8List.fromList(patchInfo),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      if (result == null) return null;
      return OopDecodeResult.fromMap(result);
    } catch (e) {
      debugPrint('LibreOopService.decodeFram: $e');
      return null;
    }
  }

  /// Decrypt Libre 2/2+ BLE packet (46 bytes) via OOP2.
  static Future<OopBleDecodeResult?> decodeBle({
    required List<int> blePacket,
    required List<int> patchUid,
  }) async {
    if (!isSupported || blePacket.length < 46) return null;
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('decodeBle', {
        'blePacket': Uint8List.fromList(blePacket),
        'patchUid': Uint8List.fromList(patchUid),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      if (result == null) return null;
      return OopBleDecodeResult.fromMap(result);
    } catch (e) {
      debugPrint('LibreOopService.decodeBle: $e');
      return null;
    }
  }

  /// Request NFC/BT unlock payloads from OOP2 before reading FRAM (Libre 2/2+).
  static Future<OopBleUnlock?> requestBleUnlock({
    required List<int> patchUid,
    required List<int> patchInfo,
  }) async {
    if (!isSupported) return null;
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('requestBleUnlock', {
        'patchUid': Uint8List.fromList(patchUid),
        'patchInfo': Uint8List.fromList(patchInfo),
      });
      if (result == null) return null;
      return OopBleUnlock.fromMap(result);
    } catch (e) {
      debugPrint('LibreOopService.requestBleUnlock: $e');
      return null;
    }
  }
}

class OopDecodeResult {
  final List<int> decryptedFram;
  final List<int> trendBg;
  final List<int> historicBg;
  final int sensorAgeMinutes;

  const OopDecodeResult({
    required this.decryptedFram,
    required this.trendBg,
    required this.historicBg,
    required this.sensorAgeMinutes,
  });

  factory OopDecodeResult.fromMap(Map<String, dynamic> map) {
    return OopDecodeResult(
      decryptedFram: _toIntList(map['decryptedFram']),
      trendBg: _toIntList(map['trendBg']),
      historicBg: _toIntList(map['historicBg']),
      sensorAgeMinutes: map['sensorAgeMinutes'] as int? ?? 0,
    );
  }

  static List<int> _toIntList(dynamic value) {
    if (value is Uint8List) return value.toList();
    if (value is List) return value.cast<int>();
    return [];
  }
}

class OopBleUnlock {
  final List<int> nfcUnlockPayload;
  final List<int> btUnlockPayload;
  final String deviceName;

  const OopBleUnlock({
    required this.nfcUnlockPayload,
    required this.btUnlockPayload,
    required this.deviceName,
  });

  factory OopBleUnlock.fromMap(Map<String, dynamic> map) {
    return OopBleUnlock(
      nfcUnlockPayload: OopDecodeResult._toIntList(map['nfcUnlockPayload']),
      btUnlockPayload: OopDecodeResult._toIntList(map['btUnlockPayload']),
      deviceName: map['deviceName'] as String? ?? '',
    );
  }
}

class OopBleDecodeResult {
  final double currentMgDl;
  final List<int> trendBg;
  final List<int> historicBg;

  const OopBleDecodeResult({
    required this.currentMgDl,
    required this.trendBg,
    required this.historicBg,
  });

  factory OopBleDecodeResult.fromMap(Map<String, dynamic> map) {
    final trend = OopDecodeResult._toIntList(map['trendBg']);
    final current = map['currentMgDl'] as num? ??
        (trend.isNotEmpty ? trend.first : 0);
    return OopBleDecodeResult(
      currentMgDl: current.toDouble(),
      trendBg: trend,
      historicBg: OopDecodeResult._toIntList(map['historicBg']),
    );
  }
}
