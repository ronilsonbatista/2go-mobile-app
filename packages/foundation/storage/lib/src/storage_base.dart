import 'package:shared_preferences/shared_preferences.dart';

/// Generic persistent key-value storage utility for 2GO Mobile.
class TwoGoStorage {
  final SharedPreferences? _prefs;

  TwoGoStorage({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    final prefs = _prefs;
    if (prefs != null) return prefs;
    return await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
