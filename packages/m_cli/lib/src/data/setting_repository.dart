import 'dart:convert';

import 'package:m_cli/src/const/prefs_key.dart';
import 'package:m_cli/src/data/data_manager.dart';
import 'package:m_cli/src/data/model/git_setting_data.dart';
import 'package:m_cli/src/data/model/setting_data.dart';
import 'package:m_cli/src/data/model/use.dart';

class SettingRepository {
  final DataManager _manager;

  SettingRepository({required DataManager manager}) : _manager = manager;

  Future<SettingData?> getSettingData({required String name}) async {
    final rawSetting = await _manager.getString(key: name);
    if (rawSetting == null || rawSetting.isEmpty) return null;
    final rawValue = jsonDecode(rawSetting);
    return SettingData.fromJson(rawValue);
  }

  Future<void> saveGitSetting({
    String? name,
    required GitSettingData? value,
  }) async {
    final currentSetting = await getSettingData(name: Keys.getKeyName(name));
    if (currentSetting == null) {
      final rawValue = jsonEncode(SettingData(git: value).toJson());
      return _manager.saveString(key: Keys.getKeyName(name), value: rawValue);
    }
    final rawValue = jsonEncode(currentSetting.copyWith(git: value).toJson());
    return _manager.saveString(key: Keys.getKeyName(name), value: rawValue);
  }

  Future<void> saveSettingZip({
    String? name,
    required String? value,
  }) async {
    final currentSetting = await getSettingData(name: Keys.getKeyName(name));
    if (currentSetting == null) {
      final rawValue = jsonEncode(SettingData(zip: value).toJson());
      return _manager.saveString(key: Keys.getKeyName(name), value: rawValue);
    }
    final rawValue = jsonEncode(currentSetting.copyWith(zip: value).toJson());
    return _manager.saveString(key: Keys.getKeyName(name), value: rawValue);
  }

  Future<void> saveSettingPath({
    String? name = Keys.defaultKey,
    required String? value,
  }) async {
    final currentSetting = await getSettingData(name: Keys.getKeyName(name));
    if (currentSetting == null) {
      final rawValue = jsonEncode(SettingData(path: value).toJson());
      return _manager.saveString(key: Keys.getKeyName(name), value: rawValue);
    }
    final rawValue = jsonEncode(currentSetting.copyWith(path: value).toJson());
    return _manager.saveString(key: Keys.getKeyName(name), value: rawValue);
  }

  Future<GitSettingData?> getGitSetting({
    String? name,
  }) async {
    final dataSetting = await getSettingData(name: Keys.getKeyName(name));
    return dataSetting?.git;
  }

  Future<String?> getSettingZip({
    String? name,
  }) async {
    final dataSetting = await getSettingData(name: Keys.getKeyName(name));
    return dataSetting?.zip;
  }

  Future<String?> getSettingPath({
    String? name,
  }) async {
    final dataSetting = await getSettingData(name: Keys.getKeyName(name));
    return dataSetting?.path;
  }

  Future<void> removeSetting({
    String? name,
  }) async {
    return _manager.delete(key: Keys.getKeyName(name));
  }

  Future<void> removeSettingGit({
    String? name,
  }) async {
    final dataSetting = await getSettingData(name: name ?? Keys.defaultKey);
    if (dataSetting == null) return;
    return saveGitSetting(name: name, value: null);
  }

  Future<void> removeSettingZip({
    String? name,
  }) async {
    final dataSetting = await getSettingData(name: Keys.getKeyName(name));
    if (dataSetting == null) return;
    return saveSettingZip(name: name, value: null);
  }

  Future<void> removeSettingPath({
    String? name,
  }) async {
    final dataSetting = await getSettingData(name: Keys.getKeyName(name));
    if (dataSetting == null) return;
    return saveSettingPath(name: name, value: null);
  }

  Future<void> deleteAll() {
    return _manager.deleteAll();
  }

  Future<Set<String>> getAllNameSettingsSaved() {
    return _manager.getAllKeys();
  }

  Future<Use?> getCurrentUse() async {
    final raw = await _manager.getString(key: Keys.use);
    if (raw == null || raw.isEmpty) return null;
    return Use.fromJson(jsonDecode(raw));
  }

  Future<void> saveUse(Use use) {
    return _manager.saveString(key: Keys.use, value: use.toJson().toString());
  }

  Future<void> removeUse() {
    return _manager.delete(key: Keys.use);
  }
}
