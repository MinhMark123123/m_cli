import 'dart:io';
import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/data/model/git_setting_data.dart';
import 'package:m_cli/src/manager/base_creator.dart';
import 'package:m_cli/src/util/file_utils.dart';
import 'package:m_cli_core/m_cli_core.dart';

class GitSettingManager extends BaseCreator {
  GitSettingManager({required SettingRepository settingRepository})
      : super(settingRepository: settingRepository);

  Future<(String?, TextType?)> handleNewSetting({
    String? name,
    required GitSettingData setting,
  }) async {
    if (setting.url == null || setting.url!.isEmpty) {
      return (
        "You haven't input you remote link. Please try : m setup --source=git --link=<your remote link>",
        TextType.warn,
      );
    }
    final currentSetting = await settingRepository.getGitSetting(name: name);
    if (currentSetting != null) {
      String textCurrentConfig = composeTextSetting(currentSetting);
      var textOverwriteConfig =
          'Do you want to overwrite your old git config : $textCurrentConfig';
      final userConfirm = ConsoleUtils.echoConfirmSelection(
        message: textOverwriteConfig,
      );
      if (!userConfirm) {
        return (
          "Exit setup! The current setting keep using $textCurrentConfig",
          TextType.normal,
        );
      }
      return insertNewSetting(name: name, setting: setting);
    }
    return insertNewSetting(name: name, setting: setting);
  }

  Future<(String?, TextType?)> insertNewSetting({
    required String? name,
    required GitSettingData setting,
  }) async {
    await settingRepository.saveGitSetting(name: name, value: setting);
    if (name != null) {
      return (
        "Your new setting has saved \nname: $name \nconfig:${composeTextSetting(setting)}",
        TextType.success,
      );
    }
    return (
      "Your new setting has saved: ${composeTextSetting(setting)}",
      TextType.success,
    );
  }

  String composeTextSetting(GitSettingData textSetting) {
    var textCurrentConfig = "${textSetting.url}";
    if (textSetting.branch != null && textSetting.branch!.isNotEmpty) {
      textCurrentConfig = "$textCurrentConfig , branch: ${textSetting.branch}";
    }
    if (textSetting.commit != null && textSetting.commit!.isNotEmpty) {
      textCurrentConfig = "$textCurrentConfig , commit: ${textSetting.commit}";
    }
    return textCurrentConfig;
  }

  Future<GitSettingData?> getSetting({String? name}) async {
    final setting = settingRepository.getGitSetting(name: name);
    return setting;
  }

  Future<void> deleteSetting({String? name}) async {
    var text = 'Do you want to delete your old git config';
    final userConfirm = ConsoleUtils.echoConfirmSelection(
      message: text,
    );
    if (!userConfirm) {
      ConsoleUtils.echoText(message: "The current setting keep using");
      return;
    }
    await settingRepository.removeSettingGit(name: name);
    final dirPath = await FileUtils.getFileDir(
      name: name,
      type: SourceType.git,
    );
    final gitDir = Directory(dirPath);
    if (!gitDir.existsSync()) {
      gitDir.deleteSync(recursive: true);
    }
    ConsoleUtils.echoText(message: "Your git config has been deleted");
  }

  Future<void> sync({String? name}) async {
    final gitSetting = await getSetting(name: name);
    if (gitSetting == null) {
      ConsoleUtils.echoText(message: "There are no config");
    }
    final dirPath = await FileUtils.getFileDir(
      name: name,
      type: SourceType.git,
    );
    final gitDir = Directory(dirPath);
    bool isFirstTime = false;
    if (!gitDir.existsSync()) {
      gitDir.createSync();
      isFirstTime = true;
    }
    //
    try {
      if (!isFirstTime) {
        final project = await gitDir.list().first;
        //move to path
        Process.runSync("cd", [project.path]);
        ConsoleUtils.echoLine(messageLine: "Sync )}");
        Process.runSync("git", ["fetch", "origin"]);
        Process.runSync(
          "git",
          [
            "pull",
            "origin",
            "\$(git rev-parse --abbrev-ref HEAD)",
          ],
        );
        return;
      }
      Process.runSync("git", ["clone ${gitSetting!.url}"]);
      Process.runSync("git", ["fetch", "origin"]);
      if (gitSetting.commit?.isNotEmpty == true) {
        Process.runSync("git", ["checkout", gitSetting.commit!]);
        return;
      }
      if (gitSetting.branch?.isNotEmpty == true) {
        Process.runSync("git", ["checkout", gitSetting.branch!]);
        Process.runSync("git", ["pull", "origin", gitSetting.branch!]);
      }
    } catch (e) {
      ConsoleUtils.echoText(
        message:
            "Failed execute git command. Please check if you haven't install git cli",
        type: TextType.error,
      );
    }
  }
}
