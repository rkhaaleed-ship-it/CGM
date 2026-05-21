import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../models/libre_read_result.dart';
import 'libre_fram_parser.dart';

/// Reads FreeStyle Libre sensors via ISO15693 (NfcV).
class LibreNfcReader {
  LibreNfcReader._();

  static const int totalBlocks = 43;
  static const int blockSize = 8;

  /// Full FRAM read + parse from discovered tag.
  static Future<LibreReadResult?> readTag(NfcTag tag) async {
    try {
      final fram = await _readFram(tag);
      if (fram == null || fram.length < LibreFramParser.framSize) {
        debugPrint('LibreNfcReader: FRAM too short (${fram?.length})');
        return null;
      }
      return LibreFramParser.parse(fram);
    } catch (e, st) {
      debugPrint('LibreNfcReader error: $e\n$st');
      return null;
    }
  }

  static Future<List<int>?> _readFram(NfcTag tag) async {
    final nfcV = NfcV.from(tag);
    if (nfcV == null) {
      debugPrint('LibreNfcReader: tag is not NfcV');
      return _readFramIsoDep(tag);
    }

    final uid = nfcV.identifier;
    final buffer = <int>[];

    // Abbott activation (Libre 1 / 2 / 2+)
    await _transceive(nfcV, _abbottActivate(uid));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    var block = 0;
    while (block < totalBlocks) {
      final remaining = totalBlocks - block;
      if (remaining == 1) {
        final resp = await _transceive(
          nfcV,
          _readBlocks(uid, block, 0),
        );
        buffer.addAll(_dataFromResponse(resp));
        block += 1;
      } else {
        final count = remaining >= 3 ? 2 : remaining - 1; // 0=1 block, 2=3 blocks
        final resp = await _transceive(
          nfcV,
          _readBlocks(uid, block, count),
        );
        buffer.addAll(_dataFromResponse(resp));
        block += count + 1;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    if (buffer.length >= LibreFramParser.framSize) {
      return buffer.sublist(0, LibreFramParser.framSize);
    }
    return buffer.isEmpty ? null : buffer;
  }

  /// Fallback for tags exposing IsoDep only.
  static Future<List<int>?> _readFramIsoDep(NfcTag tag) async {
    final iso = IsoDep.from(tag);
    if (iso == null) return null;
    final hist = iso.historicalBytes;
    if (hist != null && hist.length >= 46) {
      return hist.toList();
    }
    return null;
  }

  static Uint8List _abbottActivate(Uint8List uid) {
    if (uid.isEmpty) return Uint8List.fromList([0x02, 0xA1, 0x07]);
    return Uint8List.fromList([0x22, 0xA1, 0x07, ...uid]);
  }

  /// ISO15693 Read Multiple Block (0x23).
  static Uint8List _readBlocks(Uint8List uid, int startBlock, int blockCountMinusOne) {
    if (uid.isEmpty) {
      return Uint8List.fromList([0x02, 0x23, startBlock, blockCountMinusOne]);
    }
    return Uint8List.fromList([
      0x22,
      0x23,
      ...uid,
      startBlock,
      blockCountMinusOne,
    ]);
  }

  static Future<Uint8List> _transceive(NfcV nfcV, Uint8List cmd) async {
    try {
      return await nfcV.transceive(data: cmd);
    } catch (_) {
      // Retry non-addressed if addressed fails
      if (cmd.length > 2 && cmd[0] == 0x22) {
        final simple = cmd[1] == 0xA1
            ? Uint8List.fromList([0x02, 0xA1, 0x07])
            : Uint8List.fromList([0x02, 0x23, cmd[cmd.length - 2], cmd.last]);
        return await nfcV.transceive(data: simple);
      }
      rethrow;
    }
  }

  static List<int> _dataFromResponse(Uint8List response) {
    if (response.isEmpty) return [];
    // First byte = response flags; rest = block data
    return response.sublist(1).toList();
  }
}
