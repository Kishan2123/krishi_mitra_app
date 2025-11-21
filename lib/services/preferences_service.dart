import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static final PreferencesService instance = PreferencesService._();
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<String> getLanguage() async {
    final prefs = await _ensurePrefs();
    return prefs.getString('language') ?? 'English';
  }

  Future<void> setLanguage(String value) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('language', value);
  }

  Future<String> getRegion() async {
    final prefs = await _ensurePrefs();
    return prefs.getString('region') ?? 'Ranchi';
  }

  Future<void> setRegion(String value) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('region', value);
  }

  Future<String> getUnits() async {
    final prefs = await _ensurePrefs();
    return prefs.getString('units') ?? 'Metric';
  }

  Future<void> setUnits(String value) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('units', value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _ensurePrefs();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('notificationsEnabled', enabled);
  }

  Future<void> clear() async {
    final prefs = await _ensurePrefs();
    await prefs.clear();
  }
}
