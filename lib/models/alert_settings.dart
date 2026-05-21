/// User-configurable glucose alert thresholds.
class AlertSettings {
  final double critLow;
  final double low;
  final double high;
  final double critHigh;
  final bool alertsEnabled;
  final bool nightMode;
  final bool rapidDropAlert;
  final bool rapidRiseAlert;
  final bool nfcDirectEnabled;
  final bool xdripBroadcastEnabled;
  final bool nightscoutEnabled;

  const AlertSettings({
    this.critLow = 55,
    this.low = 70,
    this.high = 180,
    this.critHigh = 250,
    this.alertsEnabled = true,
    this.nightMode = true,
    this.rapidDropAlert = true,
    this.rapidRiseAlert = false,
    this.nfcDirectEnabled = true,
    this.xdripBroadcastEnabled = true,
    this.nightscoutEnabled = false,
  });

  AlertSettings copyWith({
    double? critLow,
    double? low,
    double? high,
    double? critHigh,
    bool? alertsEnabled,
    bool? nightMode,
    bool? rapidDropAlert,
    bool? rapidRiseAlert,
    bool? nfcDirectEnabled,
    bool? xdripBroadcastEnabled,
    bool? nightscoutEnabled,
  }) {
    return AlertSettings(
      critLow: critLow ?? this.critLow,
      low: low ?? this.low,
      high: high ?? this.high,
      critHigh: critHigh ?? this.critHigh,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      nightMode: nightMode ?? this.nightMode,
      rapidDropAlert: rapidDropAlert ?? this.rapidDropAlert,
      rapidRiseAlert: rapidRiseAlert ?? this.rapidRiseAlert,
      nfcDirectEnabled: nfcDirectEnabled ?? this.nfcDirectEnabled,
      xdripBroadcastEnabled:
          xdripBroadcastEnabled ?? this.xdripBroadcastEnabled,
      nightscoutEnabled: nightscoutEnabled ?? this.nightscoutEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'critLow': critLow,
        'low': low,
        'high': high,
        'critHigh': critHigh,
        'alertsEnabled': alertsEnabled,
        'nightMode': nightMode,
        'rapidDropAlert': rapidDropAlert,
        'rapidRiseAlert': rapidRiseAlert,
        'nfcDirectEnabled': nfcDirectEnabled,
        'xdripBroadcastEnabled': xdripBroadcastEnabled,
        'nightscoutEnabled': nightscoutEnabled,
      };

  factory AlertSettings.fromJson(Map<String, dynamic> json) {
    return AlertSettings(
      critLow: (json['critLow'] as num?)?.toDouble() ?? 55,
      low: (json['low'] as num?)?.toDouble() ?? 70,
      high: (json['high'] as num?)?.toDouble() ?? 180,
      critHigh: (json['critHigh'] as num?)?.toDouble() ?? 250,
      alertsEnabled: json['alertsEnabled'] as bool? ?? true,
      nightMode: json['nightMode'] as bool? ?? true,
      rapidDropAlert: json['rapidDropAlert'] as bool? ?? true,
      rapidRiseAlert: json['rapidRiseAlert'] as bool? ?? false,
      nfcDirectEnabled: json['nfcDirectEnabled'] as bool? ?? true,
      xdripBroadcastEnabled: json['xdripBroadcastEnabled'] as bool? ?? true,
      nightscoutEnabled: json['nightscoutEnabled'] as bool? ?? false,
    );
  }
}
