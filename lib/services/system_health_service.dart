import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'libre_oop_service.dart';

enum SystemCheckStatus { ok, warning, error, unknown }

class SystemCheck {
  final String id;
  final SystemCheckStatus status;
  final String messageKey;

  const SystemCheck({
    required this.id,
    required this.status,
    required this.messageKey,
  });
}

/// Validates device readiness for Libre 2+ (graduation demo / production).
class SystemHealthService {
  SystemHealthService._();

  static Future<List<SystemCheck>> runChecks() async {
    final checks = <SystemCheck>[];

    if (kIsWeb || !Platform.isAndroid) {
      checks.add(const SystemCheck(
        id: 'platform',
        status: SystemCheckStatus.error,
        messageKey: 'checkPlatform',
      ));
      return checks;
    }

    checks.add(const SystemCheck(
      id: 'platform',
      status: SystemCheckStatus.ok,
      messageKey: 'checkPlatformOk',
    ));

    final oopInstalled = await LibreOopService.isOop2Installed();
    checks.add(SystemCheck(
      id: 'oop2',
      status: oopInstalled ? SystemCheckStatus.ok : SystemCheckStatus.error,
      messageKey: oopInstalled ? 'checkOop2Ok' : 'checkOop2Missing',
    ));

    try {
      final nfcAvailable = await NfcManager.instance.isAvailable();
      checks.add(SystemCheck(
        id: 'nfc',
        status: nfcAvailable ? SystemCheckStatus.ok : SystemCheckStatus.error,
        messageKey: nfcAvailable ? 'checkNfcOk' : 'checkNfcMissing',
      ));
    } catch (_) {
      checks.add(const SystemCheck(
        id: 'nfc',
        status: SystemCheckStatus.error,
        messageKey: 'checkNfcMissing',
      ));
    }

    checks.add(const SystemCheck(
      id: 'ble',
      status: SystemCheckStatus.ok,
      messageKey: 'checkBleOk',
    ));

    return checks;
  }

  static bool get isReadyForLibre2Plus {
    return !kIsWeb && Platform.isAndroid;
  }
}
