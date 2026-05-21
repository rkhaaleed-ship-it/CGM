import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists Libre 2/2+ sensor context between NFC scan and BLE sessions.
class LibreSensorStore {
  LibreSensorStore._();

  static const _keyPatchUid = 'libre_patch_uid';
  static const _keyPatchInfo = 'libre_patch_info';
  static const _keyDeviceName = 'libre_ble_device_name';
  static const _keyBleMac = 'libre_ble_mac';
  static const _keySensorType = 'libre_sensor_type';

  static Future<void> save({
    required List<int> patchUid,
    required List<int> patchInfo,
    String? deviceName,
    String? bleMac,
    String? sensorType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPatchUid, base64Encode(patchUid));
    await prefs.setString(_keyPatchInfo, base64Encode(patchInfo));
    if (deviceName != null) await prefs.setString(_keyDeviceName, deviceName);
    if (bleMac != null) await prefs.setString(_keyBleMac, bleMac);
    if (sensorType != null) await prefs.setString(_keySensorType, sensorType);
  }

  static Future<LibreSensorContext?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final uidB64 = prefs.getString(_keyPatchUid);
    final infoB64 = prefs.getString(_keyPatchInfo);
    if (uidB64 == null || infoB64 == null) return null;
    return LibreSensorContext(
      patchUid: base64Decode(uidB64),
      patchInfo: base64Decode(infoB64),
      deviceName: prefs.getString(_keyDeviceName),
      bleMac: prefs.getString(_keyBleMac),
      sensorType: prefs.getString(_keySensorType) ?? 'FreeStyle Libre 2+',
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPatchUid);
    await prefs.remove(_keyPatchInfo);
    await prefs.remove(_keyDeviceName);
    await prefs.remove(_keyBleMac);
    await prefs.remove(_keySensorType);
  }
}

class LibreSensorContext {
  final List<int> patchUid;
  final List<int> patchInfo;
  final String? deviceName;
  final String? bleMac;
  final String sensorType;

  const LibreSensorContext({
    required this.patchUid,
    required this.patchInfo,
    this.deviceName,
    this.bleMac,
    this.sensorType = 'FreeStyle Libre 2+',
  });
}
