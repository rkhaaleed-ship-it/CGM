/// Represents a single glucose measurement from the CGM sensor.
class GlucoseReading {
  final DateTime timestamp;
  final double valueMgDl;
  final ReadingSource source;

  const GlucoseReading({
    required this.timestamp,
    required this.valueMgDl,
    this.source = ReadingSource.simulated,
  });

  double get valueMmolL => valueMgDl / 18.0182;

  GlucoseReading copyWith({
    DateTime? timestamp,
    double? valueMgDl,
    ReadingSource? source,
  }) {
    return GlucoseReading(
      timestamp: timestamp ?? this.timestamp,
      valueMgDl: valueMgDl ?? this.valueMgDl,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'value': valueMgDl,
        'source': source.name,
      };

  factory GlucoseReading.fromJson(Map<String, dynamic> json) {
    return GlucoseReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      valueMgDl: (json['value'] as num).toDouble(),
      source: ReadingSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ReadingSource.simulated,
      ),
    );
  }
}

enum ReadingSource { nfc, bluetooth, simulated, api }
