import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../models/libre_read_result.dart';
import '../models/libre_sensor_type.dart';
import 'libre_fram_parser.dart';
import 'libre_oop_service.dart';

class _BleEnableResult {
  const _BleEnableResult({
    this.deviceName,
    this.bleMac,
    this.btUnlock = const [],
  });

  final String? deviceName;
  final String? bleMac;
  final List<int> btUnlock;
}

/// Reads FreeStyle Libre sensors via ISO15693 (NfcV) — xDrip-compatible protocol.
class LibreNfcReader {
  LibreNfcReader._();

  static const int totalBlocks = 43;
  static const int framSize = 344;

  static Future<LibreReadResult?> readTag(NfcTag tag) async {
    try {
      final nfcV = NfcV.from(tag);
      if (nfcV == null) {
        debugPrint('LibreNfcReader: tag is not NfcV');
        return null;
      }

      final patchUid = nfcV.identifier.toList();
      if (patchUid.length < 8) {
        debugPrint('LibreNfcReader: invalid UID length ${patchUid.length}');
        return null;
      }

      final manufacturerCode = patchUid[6] & 0xff;
      final patchInfo = await _readPatchInfo(nfcV, manufacturerCode);
      if (patchInfo == null || patchInfo.isEmpty) {
        debugPrint('LibreNfcReader: failed to read patchInfo');
        return null;
      }

      final sensorType = LibreSensorType.fromPatchInfo(patchInfo);
      debugPrint('LibreNfcReader: detected ${sensorType.displayName}');

      _BleEnableResult? bleEnable;
      if (sensorType.supportsBleStreaming && LibreOopService.isSupported) {
        bleEnable = await _enableBleStreaming(nfcV, patchUid, patchInfo, manufacturerCode);
      }

      final fram = await _readFramBlocks(nfcV, sensorType);
      if (fram == null || fram.length < framSize) {
        debugPrint('LibreNfcReader: FRAM too short (${fram?.length})');
        return null;
      }

      final sensorState = LibreSensorState.fromFram(fram);
      if (sensorState == LibreSensorState.notStarted) {
        return LibreReadResult.inactive(sensorType: sensorType, sensorState: sensorState);
      }
      if (sensorState == LibreSensorState.warmingUp) {
        return LibreReadResult.warmingUp(
          sensorType: sensorType,
          sensorAgeMinutes: _sensorAgeMinutes(fram),
          sensorState: sensorState,
        );
      }

      final bleExtras = (
        deviceName: bleEnable?.deviceName,
        bleMac: bleEnable?.bleMac,
        btUnlock: bleEnable?.btUnlock ?? const <int>[],
      );

      if (sensorType.needsOopDecryption && LibreOopService.isSupported) {
        final oop = await LibreOopService.decodeFram(
          fram: fram,
          patchUid: patchUid,
          patchInfo: patchInfo,
        );
        if (oop != null && oop.trendBg.isNotEmpty) {
          return LibreFramParser.parseFromOop(
            decryptedFram: oop.decryptedFram.isNotEmpty ? oop.decryptedFram : fram,
            trendBg: oop.trendBg,
            historicBg: oop.historicBg,
            sensorType: sensorType,
            patchUid: patchUid,
            patchInfo: patchInfo,
            bleDeviceName: bleExtras.deviceName,
            bleMac: bleExtras.bleMac,
            btUnlockPayload: bleExtras.btUnlock,
          );
        }
        if (sensorType == LibreSensorType.libre2Plus || sensorType == LibreSensorType.libre2) {
          debugPrint('LibreNfcReader: OOP2 decode failed — install OOP2 app');
          return null;
        }
      }

      return LibreFramParser.parse(
        fram,
        sensorType: sensorType,
        patchUid: patchUid,
        patchInfo: patchInfo,
        bleDeviceName: bleExtras.deviceName,
        bleMac: bleExtras.bleMac,
        btUnlockPayload: bleExtras.btUnlock,
      );
    } catch (e, st) {
      debugPrint('LibreNfcReader error: $e\n$st');
      return null;
    }
  }

  static Future<List<int>?> _readPatchInfo(NfcV nfcV, int manufacturerCode) async {
    final resp = await _transceiveWithRetry(
      nfcV,
      Uint8List.fromList([0x02, 0xA1, manufacturerCode]),
    );
    if (resp == null || resp.isEmpty) return null;
    return resp.sublist(1).toList();
  }

  static Future<_BleEnableResult?> _enableBleStreaming(
    NfcV nfcV,
    List<int> patchUid,
    List<int> patchInfo,
    int manufacturerCode,
  ) async {
    final unlock = await LibreOopService.requestBleUnlock(
      patchUid: patchUid,
      patchInfo: patchInfo,
    );
    if (unlock == null || unlock.nfcUnlockPayload.isEmpty) {
      debugPrint('LibreNfcReader: BLE unlock unavailable (OOP2 required)');
      return null;
    }

    final cmd = Uint8List.fromList([
      0x02,
      0xA1,
      manufacturerCode,
      ...unlock.nfcUnlockPayload,
    ]);

    final resp = await _transceiveWithRetry(nfcV, cmd);
    String? mac;
    if (resp != null && resp.length == 7) {
      final macBytes = resp.sublist(1, 7).reversed.toList();
      mac = macBytes.map((b) => (b & 0xff).toRadixString(16).padLeft(2, '0')).join(':');
      debugPrint('LibreNfcReader: BLE enabled MAC=$mac name=${unlock.deviceName}');
    } else {
      debugPrint('LibreNfcReader: BLE enable response length ${resp?.length}');
    }

    return _BleEnableResult(
      deviceName: unlock.deviceName.isNotEmpty ? unlock.deviceName : mac,
      bleMac: mac,
      btUnlock: unlock.btUnlockPayload,
    );
  }

  static Future<List<int>?> _readFramBlocks(NfcV nfcV, LibreSensorType sensorType) async {
    final buffer = <int>[];

    for (var i = 0; i < totalBlocks; i += 3) {
      var readBlocks = 3;
      if (i == 42 && sensorType.supportsBleStreaming) {
        readBlocks = 1;
      }

      final resp = await _transceiveWithRetry(
        nfcV,
        Uint8List.fromList([0x02, 0x23, i, readBlocks - 1]),
      );
      if (resp == null || resp.isEmpty) return null;
      buffer.addAll(resp.sublist(1));
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }

    if (buffer.length >= framSize) {
      return buffer.sublist(0, framSize);
    }
    return buffer.isEmpty ? null : buffer;
  }

  static int _sensorAgeMinutes(List<int> fram) {
    if (fram.length < 318) return 0;
    return fram[316] + (fram[317] << 8);
  }

  static Future<Uint8List?> _transceiveWithRetry(NfcV nfcV, Uint8List cmd) async {
    for (var attempt = 0; attempt < 20; attempt++) {
      try {
        return await nfcV.transceive(data: cmd);
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    return null;
  }
}
