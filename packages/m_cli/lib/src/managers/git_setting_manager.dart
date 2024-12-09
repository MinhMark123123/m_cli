import 'package:m_cli/src/data/data.dart';

class GitSettingManager {
  final SettingRepository settingRepository;

  GitSettingManager({required this.settingRepository});

  Future<String> handleNewSetting(GitSettingData setting) async {
    final currentSetting = await settingRepository.getGitSetting();
    if (currentSetting != null) {

    }
    return "";
  }
}
