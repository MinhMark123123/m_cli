import 'dart:io';
import 'package:m_cli/src/const/prefs_key.dart';
import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/manager/base_creator.dart';
import 'package:m_cli/src/util/file_utils.dart';
import 'package:m_cli_core/m_cli_core.dart';

class ZipSettingManager extends BaseCreator {
  ZipSettingManager({required SettingRepository settingRepository})
      : super(settingRepository: settingRepository);

  Future<(String?, TextType?)> handleNewSetting({
    String? name,
    String? setting,
  }) async {
    if (setting == null || setting.isEmpty) {
      return (
        "You haven't input you download link. Please try : m setup --source=zip --link=<your download zip file>",
        TextType.warn,
      );
    }
    final currentSetting = await settingRepository.getSettingZip(name: name);
    if (currentSetting != null) {
      var textOverwriteConfig =
          'Do you want to overwrite your old download config : $currentSetting';
      final userConfirm = ConsoleUtils.echoConfirmYnN(
        message: textOverwriteConfig,
      );
      if (!userConfirm) {
        return (
          "Exit setup! The current setting keep using $textOverwriteConfig",
          TextType.normal,
        );
      }
      await deleteSetting(name: name, force: true);
      return insertNewSetting(name: name, setting: setting);
    }
    return insertNewSetting(name: name, setting: setting);
  }

  Future<(String?, TextType?)> insertNewSetting({
    String? name,
    required String setting,
  }) async {
    await settingRepository.saveSettingZip(name: name, value: setting);
    final message = name == null
        ? "Your new setting has saved: $setting"
        : "Your new setting has saved \nname: $name \nconfig:$setting";
    return (message, TextType.success);
  }

  Future<String?> getSetting({String? name}) async {
    final setting = await settingRepository.getSettingZip(name: name);
    return setting;
  }

  Future<void> deleteSetting({String? name, bool force = false}) async {
    if (!force) {
      var text = 'Do you want to delete your old zip config';
      final userConfirm = ConsoleUtils.echoConfirmYnN(
        message: text,
      );
      if (!userConfirm) {
        ConsoleUtils.echoText(message: "The current setting keep using");
        return;
      }
    }
    await settingRepository.removeSettingZip(name: name);
    final dirPath = await FileUtils.getFileDir(
      name: name,
      type: SourceType.zip,
    );
    final zipDir = Directory(dirPath);
    if (!zipDir.existsSync()) {
      zipDir.deleteSync(recursive: true);
    }
    ConsoleUtils.echoLine("Your zip config has been deleted");
  }

  Future<void> sync({String? name}) async {
    final zipSetting = await getSetting(name: name);
    if (!(zipSetting?.isNotEmpty == true) && name != Keys.defaultKey) {
      ConsoleUtils.echoLine("There are no zip config $name");
    }
    if (!(zipSetting?.isNotEmpty == true)) {
      return;
    }
    ConsoleUtils.echoLine("Running sync zip: $zipSetting");
    final dirPath = await FileUtils.getFileDir(
      name: name,
      type: SourceType.zip,
    );
    final zipDir = Directory(dirPath);
    if (zipDir.existsSync()) {
      zipDir.deleteSync(recursive: true);
      ConsoleUtils.echoLine("Create new dir: ${zipDir.path}");
    }
    final fileName = zipSetting!.split("/").last;
    ConsoleUtils.echoLine("Downloading : $zipSetting");
    await FileUtils.downloadFile(
      url: zipSetting,
      path: [zipDir.path, fileName].join(Platform.pathSeparator),
    );
    ConsoleUtils.echoLine("Download completed: ${zipDir.path}");
    ConsoleUtils.echoLineSucceed("Sync zip succeed");
  }
}
