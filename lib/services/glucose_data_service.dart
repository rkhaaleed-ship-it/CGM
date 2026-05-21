import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/glucose_reading.dart';

/// Manages glucose reading history, statistics, and live updates.
class GlucoseDataService {
  static const _storageKey = 'glucose_readings';
  static const intervalMs = 5 * 60 * 1000;
  static const maxReadings = 289;

  final _readingsController = StreamController<List<GlucoseReading>>.broadcast();
  List<GlucoseReading> _readings = [];
  Timer? _liveTimer;
  double _currentValue = 0;
  bool _simulationEnabled = false;

  Stream<List<GlucoseReading>> get readingsStream => _readingsController.stream;
  List<GlucoseReading> get readings => List.unmodifiable(_readings);
  double get currentValue => _currentValue;
  bool get hasReadings => _readings.isNotEmpty;
  GlucoseReading? get latest => _readings.isEmpty ? null : _readings.last;

  Future<void> initialize() async {
    await _loadFromStorage();
    if (_readings.isNotEmpty) {
      _currentValue = _readings.last.valueMgDl;
    }
    _notify();
    if (_simulationEnabled) _startLiveUpdates();
  }

  void setSimulationEnabled(bool enabled) {
    _simulationEnabled = enabled;
    if (!enabled) {
      _liveTimer?.cancel();
      _liveTimer = null;
    } else if (_liveTimer == null) {
      _startLiveUpdates();
    }
  }

  void _startLiveUpdates() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_simulationEnabled) return;
      final rng = Random();
      _currentValue = (_currentValue + (rng.nextDouble() - 0.47) * 10)
          .clamp(50, 250)
          .roundToDouble();
      addReading(GlucoseReading(
        timestamp: DateTime.now(),
        valueMgDl: _currentValue,
        source: ReadingSource.simulated,
      ));
    });
  }

  void addReading(GlucoseReading reading) {
    _currentValue = reading.valueMgDl;
    _readings.add(reading);
    if (_readings.length > maxReadings) {
      _readings.removeAt(0);
    }
    _notify();
    _saveToStorage();
  }

  List<GlucoseReading> readingsForHours(int hours) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return _readings.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }

  double calculateSlope({int points = 4}) {
    if (_readings.length < 2) return 0;
    final recent = _readings.length >= points
        ? _readings.sublist(_readings.length - points)
        : _readings;
    if (recent.length < 2) return 0;
    return (recent.last.valueMgDl - recent.first.valueMgDl) /
        (recent.length - 1);
  }

  Map<String, dynamic> statsForHours(int hours, {double low = 70, double high = 180}) {
    final slice = readingsForHours(hours);
    if (slice.isEmpty) {
      return {'avg': 0.0, 'tir': 0, 'high': 0.0, 'low': 0.0};
    }
    final vals = slice.map((r) => r.valueMgDl).toList();
    final avg = vals.reduce((a, b) => a + b) / vals.length;
    final inRange = vals.where((v) => v >= low && v <= high).length;
    return {
      'avg': avg.roundToDouble(),
      'tir': (inRange / vals.length * 100).round(),
      'high': vals.reduce((a, b) => a > b ? a : b),
      'low': vals.reduce((a, b) => a < b ? a : b),
    };
  }

  List<double> predictValues({int steps = 12}) {
    final vals = _readings.map((r) => r.valueMgDl).toList();
    if (vals.length < 2) return List.filled(steps, _currentValue);
    final n = vals.length >= 6 ? 6 : vals.length;
    final recent = vals.sublist(vals.length - n);
    final slope = (recent.last - recent.first) / (n - 1);
    return List.generate(steps, (i) {
      final v = recent.last + slope * (i + 1) * (1 - i * 0.08).clamp(0.1, 1.0);
      return v.clamp(40, 300).roundToDouble();
    });
  }

  void _notify() => _readingsController.add(_readings);

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = _readings.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(json));
    } catch (_) {}
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _readings = list
            .map((e) => GlucoseReading.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _readings = [];
    }
  }

  void dispose() {
    _liveTimer?.cancel();
    _readingsController.close();
  }
}

/// Broadcasts glucose readings to xDrip+ / Nightscout / main app API.
class ApiBroadcastService {
  String xdripUrl;
  String nightscoutUrl;
  String apiSecret;

  ApiBroadcastService({
    this.xdripUrl = 'http://localhost:17580',
    this.nightscoutUrl = 'https://your-ns.fly.dev',
    this.apiSecret = '',
  });

  Future<bool> sendToXdrip(GlucoseReading reading) async {
    try {
      final response = await http
          .post(
            Uri.parse('$xdripUrl/api/v1/entries'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sgv': reading.valueMgDl.round(),
              'date': reading.timestamp.millisecondsSinceEpoch,
              'direction': 'Flat',
              'type': 'sgv',
            }),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendToNightscout(GlucoseReading reading) async {
    if (nightscoutUrl.isEmpty) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$nightscoutUrl/api/v1/entries.json'),
            headers: {
              'Content-Type': 'application/json',
              if (apiSecret.isNotEmpty) 'api-secret': apiSecret,
            },
            body: jsonEncode({
              'sgv': reading.valueMgDl.round(),
              'date': reading.timestamp.millisecondsSinceEpoch,
              'type': 'sgv',
            }),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<void> broadcast(GlucoseReading reading,
      {bool xdrip = true, bool nightscout = false}) async {
    if (xdrip) await sendToXdrip(reading);
    if (nightscout) await sendToNightscout(reading);
  }
}
