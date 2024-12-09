import 'dart:convert';

import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/data/data_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingRepository {
  final DataManager manager;

  SettingRepository({required this.manager});

  Future<String?> getSettingDownload() async {
    return manager.getString(key: PrefsKeys.linkDownload);
  }

  Future<void> saveSettingDownload(String value) async {
    return manager.saveString(key: PrefsKeys.linkDownload, value: value);
  }

  Future<GitSettingData?> getGitSetting() async {
    final dataRaw = await manager.getString(key: PrefsKeys.gitSetting);
    if (dataRaw == null || dataRaw.isEmpty) return null;
    return GitSettingData.fromJson(jsonDecode(dataRaw));
  }

  Future<void> saveGitSetting(GitSettingData value) async {
    final rawValue = jsonEncode(value.toJson());
    return manager.saveString(key: PrefsKeys.gitSetting, value: rawValue);
  }

  Future<String?> getSettingPath() async {
    return manager.getString(key: PrefsKeys.pathFile);
  }

  Future<void> saveSettingPath(String value) async {
    return manager.saveString(key: PrefsKeys.pathFile, value: value);
  }
}
