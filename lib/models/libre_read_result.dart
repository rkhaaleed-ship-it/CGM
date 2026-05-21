import 'glucose_reading.dart';

import 'libre_sensor_type.dart';



/// Result of a real Libre NFC FRAM read.

class LibreReadResult {

  final double currentGlucoseMgDl;

  final int sensorAgeMinutes;

  final int trendIndex;

  final List<GlucoseReading> history;

  final List<int> rawFram;

  final String sensorType;

  final LibreSensorType libreSensorType;

  final List<int> patchUid;

  final List<int> patchInfo;

  final LibreSensorState sensorState;

  final String? bleDeviceName;
  final String? bleMac;
  final List<int> btUnlockPayload;

  final bool decodedViaOop;

  final bool isWarmingUp;

  final bool isInactive;



  const LibreReadResult({

    required this.currentGlucoseMgDl,

    required this.sensorAgeMinutes,

    required this.trendIndex,

    required this.history,

    required this.rawFram,

    this.sensorType = 'FreeStyle Libre 2+',

    this.libreSensorType = LibreSensorType.libre2Plus,

    this.patchUid = const [],

    this.patchInfo = const [],

    this.sensorState = LibreSensorState.active,

    this.bleDeviceName,
    this.bleMac,
    this.btUnlockPayload = const [],

    this.decodedViaOop = false,

    this.isWarmingUp = false,

    this.isInactive = false,

  });



  factory LibreReadResult.warmingUp({

    required LibreSensorType sensorType,

    required int sensorAgeMinutes,

    required LibreSensorState sensorState,

  }) {

    return LibreReadResult(

      currentGlucoseMgDl: 0,

      sensorAgeMinutes: sensorAgeMinutes,

      trendIndex: 0,

      history: const [],

      rawFram: const [],

      sensorType: sensorType.displayName,

      libreSensorType: sensorType,

      sensorState: sensorState,

      isWarmingUp: true,

    );

  }



  factory LibreReadResult.inactive({

    required LibreSensorType sensorType,

    required LibreSensorState sensorState,

  }) {

    return LibreReadResult(

      currentGlucoseMgDl: 0,

      sensorAgeMinutes: 0,

      trendIndex: 0,

      history: const [],

      rawFram: const [],

      sensorType: sensorType.displayName,

      libreSensorType: sensorType,

      sensorState: sensorState,

      isInactive: true,

    );

  }



  bool get isValid =>

      !isInactive &&

      !isWarmingUp &&

      currentGlucoseMgDl >= 20 &&

      currentGlucoseMgDl <= 500 &&

      sensorAgeMinutes > 0;

}


