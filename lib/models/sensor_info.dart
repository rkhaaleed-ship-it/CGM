/// Information about the connected CGM sensor.
class SensorInfo {
  final String name;
  final String model;
  final bool isConnected;
  final DateTime? activatedAt;
  final int lifeDays;
  final int signalStrength;
  final bool bleConnected;

  const SensorInfo({
    this.name = 'FreeStyle Libre 2+',
    this.model = 'Libre 2+',
    this.isConnected = true,
    this.activatedAt,
    this.lifeDays = 14,
    this.signalStrength = 4,
    this.bleConnected = false,
  });

  Duration get remaining {
    if (activatedAt == null) {
      return const Duration(days: 12, hours: 4);
    }
    final end = activatedAt!.add(Duration(days: lifeDays));
    final rem = end.difference(DateTime.now());
    return rem.isNegative ? Duration.zero : rem;
  }

  double get lifeProgress {
    if (activatedAt == null) return 0.86;
    final total = Duration(days: lifeDays);
    final elapsed = DateTime.now().difference(activatedAt!);
    return (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  SensorInfo copyWith({
    String? name,
    String? model,
    bool? isConnected,
    DateTime? activatedAt,
    int? lifeDays,
    int? signalStrength,
    bool? bleConnected,
  }) {
    return SensorInfo(
      name: name ?? this.name,
      model: model ?? this.model,
      isConnected: isConnected ?? this.isConnected,
      activatedAt: activatedAt ?? this.activatedAt,
      lifeDays: lifeDays ?? this.lifeDays,
      signalStrength: signalStrength ?? this.signalStrength,
      bleConnected: bleConnected ?? this.bleConnected,
    );
  }
}
