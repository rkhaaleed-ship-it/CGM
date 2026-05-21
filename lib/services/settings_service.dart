import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_settings.dart';

/// Persists user settings and app preferences.
class SettingsService {
  static const _alertKey = 'alert_settings';
  static const _localeKey = 'locale';
  static const _xdripUrlKey = 'xdrip_url';
  static const _nightscoutUrlKey = 'nightscout_url';
  static const _useMmolKey = 'use_mmol';

  Future<AlertSettings> loadAlertSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_alertKey);
    if (raw == null) return const AlertSettings();
    return AlertSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveAlertSettings(AlertSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alertKey, jsonEncode(settings.toJson()));
  }

  Future<String> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'ar';
  }

  Future<void> saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  Future<String> loadXdripUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_xdripUrlKey) ?? 'http://localhost:17580';
  }

  Future<void> saveXdripUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_xdripUrlKey, url);
  }

  Future<String> loadNightscoutUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nightscoutUrlKey) ?? 'https://your-ns.fly.dev';
  }

  Future<void> saveNightscoutUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nightscoutUrlKey, url);
  }

  Future<bool> loadUseMmol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useMmolKey) ?? false;
  }

  Future<void> saveUseMmol(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useMmolKey, value);
  }
}
