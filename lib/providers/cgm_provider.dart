import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/alert_settings.dart';
import '../models/glucose_reading.dart';
import '../models/glucose_trend.dart';
import '../models/libre_read_result.dart';
import '../models/libre_sensor_type.dart';
import '../models/sensor_info.dart';
import '../services/bluetooth_sensor_service.dart';
import '../services/glucose_data_service.dart' show ApiBroadcastService, GlucoseDataService;
import '../services/libre_nfc_reader.dart';
import '../services/nfc_sensor_service.dart';
import '../services/settings_service.dart';
import '../services/system_health_service.dart';

enum NfcScanState { idle, scanning, success, error }

const int _nfcTabIndex = 1;

/// Central app state — orchestrates all CGM services (OOP composition).
class CgmProvider extends ChangeNotifier {
  CgmProvider({
    GlucoseDataService? glucoseService,
    NfcSensorService? nfcService,
    BluetoothSensorService? bleService,
    SettingsService? settingsService,
    ApiBroadcastService? apiService,
  })  : _glucose = glucoseService ?? GlucoseDataService(),
        _nfc = nfcService ?? NfcSensorService(),
        _ble = bleService ?? BluetoothSensorService(),
        _settings = settingsService ?? SettingsService(),
        _api = apiService ?? ApiBroadcastService();

  final GlucoseDataService _glucose;
  final NfcSensorService _nfc;
  final BluetoothSensorService _ble;
  final SettingsService _settings;
  final ApiBroadcastService _api;

  AlertSettings _alerts = const AlertSettings();
  SensorInfo _sensor = const SensorInfo(isConnected: false);
  Locale _locale = const Locale('ar');
  int _activeTab = 0;
  int _chartHours = 3;
  bool _useMmol = false;
  bool _xdripConnected = false;
  String? _alertMessage;
  NfcScanState _nfcState = NfcScanState.idle;
  GlucoseReading? _lastNfcReading;
  LibreReadResult? _lastLibreResult;
  String? _nfcErrorMessage;
  double _nfcProgress = 0;
  bool _fromNfcJustNow = false;
  bool _realSensorActive = false;
  List<SystemCheck> _systemChecks = [];
  final int _heartRate = 87;
  StreamSubscription<GlucoseReading>? _bleSub;
  StreamSubscription<GlucoseReading>? _nfcSub;
  bool _autoNfcEnabled = false;
  bool _nfcLoopRunning = false;

  List<GlucoseReading> get readings => _glucose.readings;
  double get currentValue => _glucose.currentValue;
  AlertSettings get alerts => _alerts;
  SensorInfo get sensor => _sensor;
  Locale get locale => _locale;
  int get activeTab => _activeTab;
  int get chartHours => _chartHours;
  bool get useMmol => _useMmol;
  bool get xdripConnected => _xdripConnected;
  String? get alertMessage => _alertMessage;
  NfcScanState get nfcState => _nfcState;
  GlucoseReading? get lastNfcReading => _lastNfcReading;
  LibreReadResult? get lastLibreResult => _lastLibreResult;
  String? get nfcErrorMessage => _nfcErrorMessage;
  double get nfcProgress => _nfcProgress;
  bool get fromNfcJustNow => _fromNfcJustNow;
  bool get realSensorActive => _realSensorActive;
  List<SystemCheck> get systemChecks => _systemChecks;
  bool get isSystemReady =>
      _systemChecks.every((c) => c.status != SystemCheckStatus.error);
  int get heartRate => _heartRate;
  GlucoseDataService get glucoseService => _glucose;
  ApiBroadcastService get apiService => _api;

  GlucoseTrend get trend => GlucoseTrend.fromSlope(_glucose.calculateSlope());
  double get deltaPer5Min => (_glucose.calculateSlope() * 5).roundToDouble();

  String displayValue(double mgDl) {
    if (_useMmol) return (mgDl / 18.0182).toStringAsFixed(1);
    return mgDl.round().toString();
  }

  String get unitLabel => _useMmol ? 'mmol/L' : 'mg/dL';

  Future<void> initialize() async {
    _alerts = await _settings.loadAlertSettings();
    _locale = Locale(await _settings.loadLocale());
    _useMmol = await _settings.loadUseMmol();
    _api.xdripUrl = await _settings.loadXdripUrl();
    _api.nightscoutUrl = await _settings.loadNightscoutUrl();

    await _requestPermissions();
    await refreshSystemChecks();
    await _glucose.initialize();
    _updateAlert();
    _glucose.readingsStream.listen((_) {
      _updateAlert();
      _maybeBroadcast(_glucose.latest);
      notifyListeners();
    });

    if (_alerts.nfcDirectEnabled) {
      await _ble.startSession();
      _bleSub = _ble.readingsStream.listen(_onBleReading);
      _sensor = _sensor.copyWith(bleConnected: _ble.isDeviceConnected);
    }

    _nfcSub = _nfc.readingsStream.listen((r) {
      _lastNfcReading = r;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> refreshSystemChecks() async {
    _systemChecks = await SystemHealthService.runChecks();
    notifyListeners();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  void _onBleReading(GlucoseReading reading) {
    if (reading.source != ReadingSource.simulated) {
      _realSensorActive = true;
      _glucose.setSimulationEnabled(false);
    }
    _glucose.addReading(reading);
    _sensor = _sensor.copyWith(isConnected: true, bleConnected: _ble.isDeviceConnected);
    notifyListeners();
  }

  void _maybeBroadcast(GlucoseReading? reading) {
    if (reading == null) return;
    if (_alerts.xdripBroadcastEnabled) {
      _api.sendToXdrip(reading).then((ok) {
        _xdripConnected = ok;
        notifyListeners();
      });
    }
    if (_alerts.nightscoutEnabled) {
      _api.sendToNightscout(reading);
    }
  }

  void _updateAlert() {
    final v = currentValue;
    if (v < _alerts.critLow) {
      _alertMessage = 'crit_low';
    } else if (v < _alerts.low) {
      _alertMessage = 'low';
    } else if (v > _alerts.critHigh) {
      _alertMessage = 'crit_high';
    } else if (v > _alerts.high) {
      _alertMessage = 'high';
    } else {
      _alertMessage = null;
    }
  }

  void setTab(int index) {
    _activeTab = index;
    if (index == _nfcTabIndex) {
      unawaited(enableAutoNfcScan());
    } else {
      unawaited(disableAutoNfcScan());
    }
    notifyListeners();
  }

  void setChartHours(int hours) {
    _chartHours = hours;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _settings.saveLocale(locale.languageCode);
    notifyListeners();
  }

  Future<void> updateAlerts(AlertSettings alerts) async {
    _alerts = alerts;
    await _settings.saveAlertSettings(alerts);
    _updateAlert();
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    await setLocale(Locale(_locale.languageCode == 'ar' ? 'en' : 'ar'));
  }

  Future<void> setUseMmol(bool value) async {
    _useMmol = value;
    await _settings.saveUseMmol(value);
    notifyListeners();
  }

  /// Starts continuous NFC listening while the NFC tab is open.
  Future<void> enableAutoNfcScan() async {
    if (kIsWeb || _autoNfcEnabled) return;
    _autoNfcEnabled = true;
    if (!_nfcLoopRunning) {
      unawaited(_nfcAutoScanLoop());
    }
  }

  Future<void> disableAutoNfcScan() async {
    _autoNfcEnabled = false;
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  Future<void> _nfcAutoScanLoop() async {
    _nfcLoopRunning = true;
    while (_autoNfcEnabled) {
      if (_nfcState == NfcScanState.success) {
        await Future<void>.delayed(const Duration(seconds: 6));
        if (!_autoNfcEnabled) break;
      }

      await _runOneNfcSession();

      if (!_autoNfcEnabled) break;

      if (_nfcState == NfcScanState.error) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (_autoNfcEnabled) {
          _nfcErrorMessage = null;
          notifyListeners();
        }
      }
    }
    _nfcLoopRunning = false;
  }

  /// Manual restart (e.g. "Read again" button).
  Future<void> startNfcScan() async {
    if (_autoNfcEnabled) {
      resetNfcState();
      return;
    }
    await _runOneNfcSession();
  }

  Future<void> _runOneNfcSession() async {
    _nfcState = NfcScanState.scanning;
    _nfcProgress = 0;
    if (_nfcState != NfcScanState.success) {
      _lastNfcReading = null;
      _lastLibreResult = null;
    }
    _nfcErrorMessage = null;
    notifyListeners();

    final available = await NfcManager.instance.isAvailable();
    if (!available) {
      _nfcState = NfcScanState.error;
      _nfcErrorMessage = 'nfcNotAvailable';
      notifyListeners();
      return;
    }

    var completed = false;
    Timer? progressTimer;
    progressTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!completed && _nfcState == NfcScanState.scanning) {
        _nfcProgress = (_nfcProgress + 0.015).clamp(0.0, 0.95);
        notifyListeners();
      }
    });

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          if (completed) return;
          try {
            final result = await LibreNfcReader.readTag(tag);
            progressTimer?.cancel();
            completed = true;

            if (result != null && result.isValid) {
              _lastLibreResult = result;
              _lastNfcReading = GlucoseReading(
                timestamp: DateTime.now(),
                valueMgDl: result.currentGlucoseMgDl,
                source: ReadingSource.nfc,
              );
              _nfcProgress = 1.0;
              _nfcState = NfcScanState.success;
              _applySensorResult(result);
              sendNfcToHome();
              if (result.patchUid.isNotEmpty) {
                unawaited(_ble.configureLibreSensor(
                  patchUid: result.patchUid,
                  patchInfo: result.patchInfo,
                  deviceName: result.bleDeviceName,
                  bleMac: result.bleMac,
                  btUnlockPayload: result.btUnlockPayload,
                ));
              }
            } else if (result != null && result.isWarmingUp) {
              _nfcState = NfcScanState.error;
              _nfcErrorMessage = 'sensorWarmingUp';
              _sensor = _sensor.copyWith(
                name: result.sensorType,
                model: 'Libre 2+',
                isConnected: false,
              );
            } else if (result != null && result.isInactive) {
              _nfcState = NfcScanState.error;
              _nfcErrorMessage = 'sensorNotActive';
            } else {
              _nfcState = NfcScanState.error;
              _nfcErrorMessage = result == null ? 'scanFailed' : 'oop2Required';
            }
            notifyListeners();
            await NfcManager.instance.stopSession();
          } catch (e) {
            progressTimer?.cancel();
            completed = true;
            _nfcState = NfcScanState.error;
            _nfcErrorMessage = 'scanFailed';
            notifyListeners();
            await NfcManager.instance.stopSession(errorMessage: e.toString());
          }
        },
      );

      // Keep listening until tag found or user leaves NFC tab.
      while (!completed && _autoNfcEnabled) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      if (!completed) {
        progressTimer.cancel();
        await NfcManager.instance.stopSession();
      } else if (!_autoNfcEnabled) {
        progressTimer.cancel();
      }
    } catch (e) {
      progressTimer.cancel();
      if (_autoNfcEnabled) {
        _nfcState = NfcScanState.error;
        _nfcErrorMessage = 'scanFailed';
        notifyListeners();
      }
    }
  }

  void _applySensorResult(LibreReadResult result) {
    _realSensorActive = true;
    _glucose.setSimulationEnabled(false);
    for (final r in result.history) {
      _glucose.addReading(r);
    }
    _sensor = _sensor.copyWith(
      name: result.sensorType,
      model: result.libreSensorType == LibreSensorType.libre2Plus
          ? 'Libre 2+'
          : result.libreSensorType.displayName,
      isConnected: true,
      activatedAt: DateTime.now().subtract(Duration(minutes: result.sensorAgeMinutes)),
      signalStrength: 4,
      bleConnected: result.bleDeviceName != null,
    );
  }

  void sendNfcToHome() {
    if (_lastNfcReading == null) return;
    _fromNfcJustNow = true;
    _maybeBroadcast(_lastNfcReading);
    setTab(0);
    Future<void>.delayed(const Duration(seconds: 30), () {
      _fromNfcJustNow = false;
      notifyListeners();
    });
  }

  void resetNfcState() {
    _nfcState = NfcScanState.scanning;
    _nfcProgress = 0;
    _lastNfcReading = null;
    _lastLibreResult = null;
    _nfcErrorMessage = null;
    notifyListeners();
  }

  String timeAgoText(int minutes, String justNow, String minutesAgoFn) {
    if (_fromNfcJustNow) return justNow;
    if (minutes <= 0) return justNow;
    return minutesAgoFn;
  }

  int get minutesSinceLastReading {
    final latest = _glucose.latest;
    if (latest == null) return 0;
    return DateTime.now().difference(latest.timestamp).inMinutes;
  }

  @override
  void dispose() {
    unawaited(disableAutoNfcScan());
    _bleSub?.cancel();
    _nfcSub?.cancel();
    _glucose.dispose();
    _nfc.dispose();
    _ble.dispose();
    super.dispose();
  }
}
