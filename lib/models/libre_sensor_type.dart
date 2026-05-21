/// FreeStyle Libre sensor variants detected from patchInfo bytes.
enum LibreSensorType {
  libre1,
  libre1New,
  libreUs14Day,
  libre2,
  libre2Plus,
  libreProH,
  libre3,
  unknown;

  bool get needsOopDecryption =>
      this == LibreSensorType.libreUs14Day ||
      this == LibreSensorType.libre2 ||
      this == LibreSensorType.libre2Plus;

  bool get supportsBleStreaming =>
      this == LibreSensorType.libre2 || this == LibreSensorType.libre2Plus;

  String get displayName => switch (this) {
        LibreSensorType.libre1 => 'FreeStyle Libre 1',
        LibreSensorType.libre1New => 'FreeStyle Libre 1',
        LibreSensorType.libreUs14Day => 'FreeStyle Libre US',
        LibreSensorType.libre2 => 'FreeStyle Libre 2',
        LibreSensorType.libre2Plus => 'FreeStyle Libre 2+',
        LibreSensorType.libreProH => 'FreeStyle Libre Pro',
        LibreSensorType.libre3 => 'FreeStyle Libre 3',
        LibreSensorType.unknown => 'FreeStyle Libre',
      };

  /// Detect sensor from Abbott patchInfo (response to 0xA1 command).
  static LibreSensorType fromPatchInfo(List<int> patchInfo) {
    if (patchInfo.isEmpty) return LibreSensorType.unknown;
    if (patchInfo.length == 24) return LibreSensorType.libre3;

    if (patchInfo.length < 3) return LibreSensorType.unknown;
    final sensorNum =
        ((patchInfo[0] & 0xff) << 16) | ((patchInfo[1] & 0xff) << 8) | (patchInfo[2] & 0xff);

    return switch (sensorNum) {
      0xdf0000 => LibreSensorType.libre1,
      0xa20800 => LibreSensorType.libre1New,
      0xe50003 || 0xe60003 => LibreSensorType.libreUs14Day,
      0x9d0830 || 0xc50930 || 0x7f0e30 => LibreSensorType.libre2,
      0xc60931 || 0x7f0e31 => LibreSensorType.libre2Plus,
      0x700010 => LibreSensorType.libreProH,
      _ => LibreSensorType.unknown,
    };
  }
}

enum LibreSensorState {
  notStarted(0x01),
  warmingUp(0x02),
  active(0x03),
  expired(0x04),
  shutdown(0x05),
  failure(0x06),
  unknown(0x00);

  const LibreSensorState(this.code);
  final int code;

  static LibreSensorState fromFram(List<int> fram) {
    if (fram.length < 5) return LibreSensorState.unknown;
    final state = fram[4] & 0xff;
    for (final s in LibreSensorState.values) {
      if (s.code == state) return s;
    }
    return LibreSensorState.unknown;
  }
}
