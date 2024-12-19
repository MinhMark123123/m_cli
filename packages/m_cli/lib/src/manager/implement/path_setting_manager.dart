import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/data/setting_repository.dart';
import 'package:m_cli/src/manager/base_creator.dart';
import 'package:m_cli_core/m_cli_core.dart';

class PathSettingManager extends BaseCreator {
  PathSettingManager({required SettingRepository settingRepository})
      : super(settingRepository: settingRepository);

  Future<(String?, TextType?)> handleNewSetting({
    String? name,
    String? setting,
  }) async {
    if (setting == null || setting.isEmpty) {
      return (
        "You haven't input you download link. Please try : m setup --source=path --path=<your path folder>",
        TextType.warn,
      );
    }
    final currentSetting = await settingRepository.getSettingPath(name: name);
    if (currentSetting != null) {
      var textOverwriteConfig =
          'Do you want to overwrite your old path config : $currentSetting';
      final userConfirm = ConsoleUtils.echoConfirmSelection(
        message: textOverwriteConfig,
      );
      if (!userConfirm) {
        (
          "Exit setup! The current setting keep using $textOverwriteConfig",
          TextType.normal,
        );
      }
      return insertNewSetting(name: name, setting: setting);
    }
    return insertNewSetting(name: name, setting: setting);
  }

  Future<(String?, TextType?)> insertNewSetting({
    String? name,
    required String setting,
  }) async {
    await settingRepository.saveSettingPath(name: name, value: setting);
    final message = name == null
        ? "Your new setting has saved: $setting"
        : "Your new setting has saved \nname: $name \nconfig:$setting";
    return (message, TextType.success);
  }

  Future<String?> getSetting({String? name}) async {
    final setting = await settingRepository.getSettingPath(name: name);
    return setting;
  }

  Future<void> deleteSetting({String? name}) async {
    var text = 'Do you want to delete your old path config';
    final userConfirm = ConsoleUtils.echoConfirmSelection(
      message: text,
    );
    if (!userConfirm) {
      ConsoleUtils.echoText(message: "The current setting keep using");
      return;
    }
    await settingRepository.removeSettingPath();
    ConsoleUtils.echoText(message: "Your path config has been deleted");
  }
}
