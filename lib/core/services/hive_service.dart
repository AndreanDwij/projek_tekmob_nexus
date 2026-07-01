import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String _userBoxName = 'user_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _cacheBoxName = 'cache_box';

  late Box _userBox;
  late Box _settingsBox;
  late Box _cacheBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(_userBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _cacheBox = await Hive.openBox(_cacheBoxName);
  }

  // User Box
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _userBox.putAll(data);
  }

  dynamic getUserData(String key) {
    return _userBox.get(key);
  }

  Map<dynamic, dynamic> getAllUserData() {
    return _userBox.toMap();
  }

  Future<void> clearUserData() async {
    await _userBox.clear();
  }

  bool get isLoggedIn => _userBox.containsKey('userId');

  // Settings Box
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key) {
    return _settingsBox.get(key);
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  // Cache Box
  Future<void> cacheData(String key, dynamic data) async {
    await _cacheBox.put(key, data);
  }

  dynamic getCachedData(String key) {
    return _cacheBox.get(key);
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  Future<void> close() async {
    await _userBox.close();
    await _settingsBox.close();
    await _cacheBox.close();
  }
}
