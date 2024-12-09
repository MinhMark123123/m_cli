import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  Future<void> saveString({required String key, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString({required String key, String? defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }
}
