import 'package:flutter/material.dart';

/// Utility for glucose value color coding (xDrip-style).
class GlucoseColor {
  GlucoseColor._();

  static const double critLow = 55;
  static const double low = 70;
  static const double high = 180;
  static const double critHigh = 250;

  static Color dotColor(double mgDl) {
    if (mgDl < critLow) return const Color(0xFFEF5350);
    if (mgDl < low) return const Color(0xFFFF8A65);
    if (mgDl > critHigh) return const Color(0xFFE53935);
    if (mgDl > high) return const Color(0xFFF5A623);
    return const Color(0xFFF5A623);
  }

  static Color textColor(double mgDl) {
    if (mgDl < low) return const Color(0xFFEF5350);
    if (mgDl > high) return const Color(0xFFF5A623);
    return Colors.white;
  }

  static Color statColor(double mgDl, {required bool isAverage}) {
    if (isAverage) {
      if (mgDl < low) return const Color(0xFFEF5350);
      if (mgDl > high) return const Color(0xFFF5A623);
      return const Color(0xFF4CAF50);
    }
    if (mgDl > high) return const Color(0xFFF5A623);
    if (mgDl < low) return const Color(0xFFEF5350);
    return const Color(0xFFAAAAAA);
  }
}
