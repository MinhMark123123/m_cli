import 'package:m_cli/src/const/prefs_key.dart';

class SettingUtils {
  SettingUtils._();

  static bool isUsingDefaultSetting({required List<String> keysSetting}) {
    return keysSetting.length == 1 && keysSetting.first == Keys.defaultKey;
  }
}
